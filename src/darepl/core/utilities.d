module darepl.core.utilities;

import std.algorithm,
       std.math,
       std.traits;

T limitTo(T)(T value, size_t n)
    if (isUnsigned!T)
{
    return min(value, 2 ^^ n - 1);
}
