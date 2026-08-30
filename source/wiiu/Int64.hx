package wiiu;

#if wiiu
import haxe.Int32;

@:coreType
@:native("int64_t")
@:include("cstdint", true)
@:valueType
abstract NativeInt64 {
	@:from public static inline function fromInt(x:Int):NativeInt64 {
		return cast x;
	}

	@:to public inline function toInt():Int {
		return cast this;
	}
}
#end
