#!/usr/bin/env python

import os, shutil, sys, tarfile, tempfile
from waflib import Build, Context, Scripting, Utils

APPNAME = 'DAREPL'
VERSION = '1.0'

TOP = os.curdir
OUT = 'build'

def options(opt):
    opt.load('compiler_d')

    opt.add_option('--lp64', action = 'store', default = 'true', help = 'compile for 64-bit CPUs (true/false)')
    opt.add_option('--mode', action = 'store', default = 'debug', help = 'the mode to compile in (debug/release)')

def configure(conf):
    conf.load('compiler_d')

    def add_option(option):
        conf.env.append_value('DFLAGS', option)

    if conf.env.COMPILER_D == 'dmd':
        add_option('-w')
        add_option('-ignore')
        add_option('-property')
        add_option('-gc')

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
        add_option('-fdebug-c')

        if conf.options.mode == 'debug':
            add_option('-fdebug')
        elif conf.options.mode == 'release':
            add_option('-frelease')
            add_option('-O3')
        else:
            conf.fatal('--mode must be either debug or release.')

        conf.env.append_value('LINKFLAGS', '-lpthread')
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

def build(bld):
    def search_paths(path):
        return [os.path.join(path, '*.d'), os.path.join(path, '**', '*.d')]

    includes = ['src']
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

    stlib('core', 'darepl.core')
    stlib('x86', 'darepl.x86')
    stlib('arm', 'darepl.arm')
    stlib('ppc', 'darepl.ppc')
    stlib('ia64', 'darepl.ia64')
    stlib('mips', 'darepl.mips')

    deps = ['darepl.x86',
            'darepl.core']

    program('cli', 'darepl', deps)

def dist(dst):
    '''makes a tarball for redistributing the sources'''

    with open('.gitignore', 'r') as f:
        dst.excl = ' '.join(l.strip() for l in f if l.strip())

class DistCheckContext(Scripting.Dist):
    cmd = 'distcheck'
    fun = 'distcheck'

    def execute(self):
        self.recurse([os.path.dirname(Context.g_module.root_path)])
        self.archive()
        self.check()

    def check(self):
        with tarfile.open(self.get_arch_name()) as t:
            for x in t:
                t.extract(x)

        instdir = tempfile.mkdtemp('.inst', self.get_base_name())
        cfg = [x for x in sys.argv if x.startswith('-')]

        ret = Utils.subprocess.Popen([sys.argv[0],
                                      'configure',
                                      'install',
                                      'uninstall',
                                      '--destdir=' + instdir] + cfg, cwd = self.get_base_name()).wait()

        if ret:
            self.fatal('distcheck failed with code {0}'.format(ret))

        if os.path.exists(instdir):
            self.fatal('distcheck succeeded, but files were left in {0}'.format(instdir))

        shutil.rmtree(self.get_base_name())

def distcheck(ctx):
    '''checks if the project compiles (tarball from 'dist')'''

    pass

class PackageContext(Build.InstallContext):
    cmd = 'package'
    fun = 'build'

    def init_dirs(self, *k, **kw):
        super(PackageContext, self).init_dirs(*k, **kw)

        self.tmp = self.bldnode.make_node('package_tmp_dir')

        try:
            shutil.rmtree(self.tmp.abspath())
        except:
            pass

        if os.path.exists(self.tmp.abspath()):
            self.fatal('Could not remove the temporary directory {0}'.format(self.tmp))

        self.tmp.mkdir()
        self.options.destdir = self.tmp.abspath()

    def execute(self, *k, **kw):
        back = self.options.destdir

        try:
            super(PackageContext, self).execute(*k, **kw)
        finally:
            self.options.destdir = back

        files = self.tmp.ant_glob('**')

        appname = getattr(Context.g_module, Context.APPNAME, 'noname')
        version = getattr(Context.g_module, Context.VERSION, '1.0')

        ctx = Scripting.Dist()
        ctx.arch_name = '{0}-{1}-bin.tar.bz2'.format(appname, version)
        ctx.files = files
        ctx.tar_prefix = ''
        ctx.base_path = self.tmp
        ctx.archive()

        shutil.rmtree(self.tmp.abspath())

def package(ctx):
    '''packages built binaries into a tarball'''

    pass
