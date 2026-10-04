package sdl2;

import cpp.Pointer;
import cpp.RawPointer;
import cpp.Void;
import cpp.UInt32;
import sdl2.SDL_Pixels.SDL_PixelFormat;
import sdl2.SDL_Rect.SDL_Rect;

@:cppInclude("SDL2/SDL_surface.h") @:include("SDL2/SDL_surface.h")

@:native("SDL_BlitMap")
@:structAccess
extern class SDL_BlitMap {
    public function new() {}
}

@:include("SDL2/SDL_surface.h")
@:native("SDL_Surface")
@:structAccess
extern class SDL_Surface {
    @:include("SDL2/SDL_surface.h")
	public var flags:UInt32;
    @:include("SDL2/SDL_surface.h")
    public var format:Pointer<SDL_PixelFormat>;
    @:include("SDL2/SDL_surface.h")
    public var w:UInt32;
    @:include("SDL2/SDL_surface.h")
    public var h:UInt32;
    @:include("SDL2/SDL_surface.h")
    public var pitch:UInt32;
    @:include("SDL2/SDL_surface.h")
    public var pixels:RawPointer<Void>;
    @:include("SDL2/SDL_surface.h")
    public var userdata:RawPointer<Void>;
    @:include("SDL2/SDL_surface.h")
    public var locked:UInt32;
    @:include("SDL2/SDL_surface.h")
    public var lock_data:RawPointer<Void>;
    @:include("SDL2/SDL_surface.h")
    public var clip_rect:SDL_Rect;
    @:include("SDL2/SDL_surface.h")
    public var map:Pointer<SDL_BlitMap>;
    @:include("SDL2/SDL_surface.h")
    public var refcount:Int;

    public function new() {}
}

@:cppInclude("SDL2/SDL_surface.h") 
@:include("SDL2/SDL_surface.h")
extern class SDL_SurfaceClass {
    @:native("SDL_FreeSurface")
    @:include("SDL2/SDL_surface.h")
    extern public static function SDL_FreeSurface(surface:Pointer<SDL_Surface>):Int;

    @:native("SDL_CreateRGBSurface")
    @:include("SDL2/SDL_surface.h")
    extern public static function SDL_CreateRGBSurface(flags:UInt32, width:UInt32, height:UInt32, depth:UInt32, Rmask:UInt32, Gmask:UInt32, Bmask:UInt32, Amask:UInt32):Pointer<SDL_Surface>;

    @:native("SDL_FillRect")
    @:include("SDL2/SDL_surface.h")
    extern public static function SDL_FillRect(dst:Pointer<SDL_Surface>, rect:Pointer<SDL_Rect>, color:UInt32):Int;
}