#!/usr/bin/env python

import os
from waflib import Utils

APPNAME = 'DAREPL'
VERSION = '1.0'

TOP = os.curdir
OUT = 'build'

def options(opt):
    opt.recurse('libffi-d')

def configure(conf):
    conf.recurse('libffi-d')

    def add_option(option, flags = 'DFLAGS'):
        if option not in conf.env[flags]:
            conf.env.append_value(flags, option)

    if conf.env.COMPILER_D == 'dmd':
        add_option('-w')
        add_option('-ignore')
        add_option('-property')
        add_option('-g')

        if conf.options.mode == 'debug':
            add_option('-debug')
        elif conf.options.mode == 'release':
            add_option('-release')
            add_option('-O')
            add_option('-inline')
        else:
            conf.fatal('--mode must be either debug or release.')
    elif conf.env.COMPILER_D == 'gdc':
        add_option('-Wall')
        add_option('-Werror')
        add_option('-fignore-unknown-pragmas')
        add_option('-fproperty')
        add_option('-g')
        add_option('-ggdb')

        if conf.options.mode == 'debug':
            add_option('-fdebug')
        elif conf.options.mode == 'release':
            add_option('-frelease')
            add_option('-O3')
        else:
            conf.fatal('--mode must be either debug or release.')

        add_option('-rdynamic', 'LINKFLAGS')
    elif conf.env.COMPILER_D == 'ldc2':
        add_option('-w')
        add_option('-wi')
        add_option('-ignore')
        add_option('-property')
        add_option('-check-printf-calls')
        add_option('-g')

        if conf.options.mode == 'debug':
            add_option('-d-debug')
        elif conf.options.mode == 'release':
            add_option('-release')
            add_option('-O3')
            add_option('--enable-inlining')
        else:
            conf.fatal('--mode must be either debug or release.')
    else:
        conf.fatal('Unsupported D compiler.')

    if conf.options.lp64 == 'true':
        add_option('-m64')
        conf.env.append_value('LINKFLAGS', '-m64')
    elif conf.options.lp64 == 'false':
        add_option('-m32')
        conf.env.append_value('LINKFLAGS', '-m32')
    else:
        conf.fatal('--lp64 must be either true or false.')

    conf.env.LIB_FFI = ['ffi']
    conf.env.LIB_EDIT = ['edit']

    if not Utils.unversioned_sys_platform().lower().endswith('bsd'):
        conf.env.LIB_DL = ['dl']

def build(bld):
    bld.recurse('libffi-d')

    def search_paths(path):
        return [os.path.join(path, '*.d'), os.path.join(path, '**', '*.d')]

    includes = ['src', 'libffi-d']
    src = os.path.join('src', 'darepl')

    def stlib(path, target, dflags = [], install = '${PREFIX}/lib'):
        bld.stlib(source = bld.path.ant_glob(search_paths(os.path.join(src, path))),
                  target = target,
                  includes = includes,
                  install_path = install,
                  dflags = dflags)

    def program(path, target, deps, dflags = [], install = '${PREFIX}/bin'):
        bld.program(source = bld.path.ant_glob(search_paths(os.path.join(src, path))),
                    target = target,
                    use = deps,
                    includes = includes,
                    install_path = install,
                    dflags = dflags)

    stlib('core', 'darepl.core', install = None)
    stlib('arm', 'darepl.arm', install = None)
    stlib('epiphany', 'darepl.epiphany', install = None)
    stlib('ia64', 'darepl.ia64', install = None)
    stlib('mips', 'darepl.mips', install = None)
    stlib('ppc', 'darepl.ppc', install = None)
    stlib('x86', 'darepl.x86', install = None)

    deps = ['darepl.x86',
            'darepl.ppc',
            'darepl.mips',
            'darepl.ia64',
            'darepl.epiphany',
            'darepl.arm',
            'darepl.core',
            'ffi-d',
            'FFI',
            'EDIT']

    if not Utils.unversioned_sys_platform().lower().endswith('bsd'):
        deps += ['DL']

    program('cli', 'darepl', deps)

def dist(dst):
    '''makes a tarball for redistributing the sources'''

    with open('.gitignore', 'r') as f:
        dst.excl = ' '.join(l.strip() for l in f if l.strip())
        dst.excl += ' .git/* .gitignore .arcconfig'
