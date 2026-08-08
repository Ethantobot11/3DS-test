
package haxe._Int64;

@:native("int64_t")
@:include("cstdint", true)
extern class NativeInt64 {
    public var high(get, never):Int32;
    public var low(get, never):Int32;
    public function new(high:Int32, low:Int32);
}
