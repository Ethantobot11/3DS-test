
package haxe;

@:native("int64_t")
@:include("cstdint", true)
class NativeInt64 {
    public var high:Int32;
    public var low:Int32;

    public inline function new(high:Int32, low:Int32) {
        this.high = high;
        this.low = low;
    }
}
