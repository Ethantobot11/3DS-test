package sdl2;

import cpp.RawPointer;
import cpp.Void;
import cpp.SizeT;

@:cppInclude("SDL2/SDL_stdinc.h") @:include("SDL2/SDL_stdinc.h")

extern class SDL_Stdinc {
    @:native("SDL_memset")
    @:include("SDL2/SDL_stdinc.h")
    extern public static function SDL_memset(dst:RawPointer<Void>, c:Int, len:SizeT):RawPointer<Void>;

    @:native("SDL_memcpy")
    @:include("SDL2/SDL_stdinc.h")
    extern public static function SDL_memcpy(dst:RawPointer<Void>, src:RawPointer<Void>, len:SizeT):RawPointer<Void>;

    @:native("SDL_malloc")
    @:include("SDL2/SDL_stdinc.h")
    extern public static function SDL_malloc(size:SizeT):RawPointer<Void>;

    @:native("SDL_zero")
    @:include("SDL2/SDL_stdinc.h")
    extern public static function SDL_zero(dst:RawPointer<Void>):RawPointer<Void>;
}

@:cppInclude("SDL2/SDL_stdinc.h")
@:include("SDL2/SDL_stdinc.h")
@:native("SDL_bool")
extern enum SDL_bool {
    @:native("SDL_FALSE")
    SDL_FALSE;
    @:native("SDL_TRUE")
    SDL_TRUE;
}