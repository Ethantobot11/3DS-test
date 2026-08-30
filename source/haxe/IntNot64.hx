package haxe;

@:coreType
@:native("int64_t")
@:include("cstdint", true)
@:valueType
abstract Int64 to Int64 from Int64 {
    @:op(-A) private static inline function negate(a:Int64):Int64
        return -a;

    @:op(A + B) private static inline function add(a:Int64, b:Int64):Int64
        return a + b;

    @:op(A - B) private static inline function sub(a:Int64, b:Int64):Int64
        return a - b;

    @:op(A * B) private static inline function mul(a:Int64, b:Int64):Int64
        return a * b;

    @:op(A / B) private static inline function div(a:Int64, b:Int64):Int64
        return a / b;

    @:op(A == B) private static inline function eq(a:Int64, b:Int64):Bool
        return a == b;

    @:op(A != B) private static inline function neq(a:Int64, b:Int64):Bool
        return a != b;

    @:op(A < B) private static inline function lt(a:Int64, b:Int64):Bool
        return a < b;

    @:op(A <= B) private static inline function lte(a:Int64, b:Int64):Bool
        return a <= b;

    @:op(A > B) private static inline function gt(a:Int64, b:Int64):Bool
        return a > b;

    @:op(A >= B) private static inline function gte(a:Int64, b:Int64):Bool
        return a >= b;
}
