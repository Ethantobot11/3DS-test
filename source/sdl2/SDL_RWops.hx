package sdl2;

import cpp.Pointer;
import cpp.Int64;
import cpp.SizeT;
import cpp.ConstCharStar;

@:cppInclude("SDL2/SDL_rwops.h") @:include("SDL2/SDL_rwops.h")

@:include("SDL2/SDL_rwops.h")
@:native("SDL_RWops")
extern typedef SDL_RWops = {
    @:native("size") var size:cpp.Pointer<cpp.Int64>;
    @:native("seek") var seek:cpp.Pointer<cpp.Int64>;
    @:native("read") var read:cpp.Pointer<cpp.SizeT>;
    @:native("write") var write:cpp.Pointer<cpp.SizeT>;
    @:native("close") var close:cpp.Pointer<cpp.SizeT>;
}

@:cppInclude("SDL2/SDL_rwops.h") 
@:include("SDL2/SDL_rwops.h")
extern class SDL_RWopsClass {
	@:native("RW_SEEK_END")
	@:include("SDL2/SDL_rwops.h")
	extern public static var RW_SEEK_END:Int;

	@:native("SDL_RWFromFile")
	@:include("SDL2/SDL_rwops.h")
    extern public static function SDL_RWFromFile(file:ConstCharStar, mode:ConstCharStar):cpp.Pointer<SDL_RWops>;

	@:native("SDL_RWseek")
    @:include("SDL2/SDL_rwops.h")
    extern public static function SDL_RWseek(ptr:cpp.Pointer<SDL_RWops>, offset:cpp.Int64, whence:Int):cpp.Int64;

    @:native("SDL_RWclose")
    @:include("SDL2/SDL_rwops.h")
    extern public static function SDL_RWclose(ptr:cpp.Pointer<SDL_RWops>):Int;
}