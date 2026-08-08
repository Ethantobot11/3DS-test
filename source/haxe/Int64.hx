package haxe;

@:transitive
abstract Int64(haxe._Int64.NativeInt64) from haxe._Int64.NativeInt64 to haxe._Int64.NativeInt64 {
    public inline function new(high:Int32, low:Int32) {
        this = new haxe._Int64.NativeInt64(high, low);
    }

    public static inline function make(high:Int32, low:Int32):Int64 {
        return new Int64(high, low);
    }

    @:from public static inline function ofInt(x:Int):Int64 {
        return new Int64(x >> 31, x);
    }

    public var high(get, never):Int32;
    private inline function get_high():Int32 return this.high;

    public var low(get, never):Int32;
    private inline function get_low():Int32 return this.low;
}

package haxe._Int64;

@:native("int64_t")
@:include("cstdint", true)
extern class NativeInt64 {
    public var high(get, never):Int32;
    public var low(get, never):Int32;
    public function new(high:Int32, low:Int32);
}
