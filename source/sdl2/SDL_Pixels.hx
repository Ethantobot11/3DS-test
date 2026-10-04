package sdl2;

import cpp.Pointer;
import cpp.NativeArray;
import cpp.Char;
import cpp.UInt8;
import cpp.UInt32;

@:native("SDL_Color")
@:structAccess
extern class SDL_Color {
    public var r:UInt8;
    public var g:UInt8;
    public var b:UInt8;
    public var a:UInt8;
    public function new() {}
}

@:native("SDL_Palette")
@:structAccess
extern class SDL_Palette {
    public var ncolors:Int;
    public var colors:Pointer<SDL_Color>;
    public var version:UInt32;
    public var refcount:Int;
    public function new() {}
}

@:native("SDL_PixelFormat")
@:structAccess
extern class SDL_PixelFormat {
    public var format:UInt32;
    public var palette:Pointer<SDL_Palette>;
    public var BitsPerPixel:UInt8;
    public var BytesPerPixel:UInt8;
    public var padding:NativeArray<Char>;
    public var Rmask:UInt32;
    public var Gmask:UInt32;
    public var Bmask:UInt32;
    public var Amask:UInt32;
    public var Rloss:UInt8;
    public var Gloss:UInt8;
    public var Bloss:UInt8;
    public var Aloss:UInt8;
    public var Rshift:UInt8;
    public var Gshift:UInt8;
    public var Bshift:UInt8;
    public var Ashift:UInt8;
    public var refcount:Int;
    public var next:Pointer<SDL_PixelFormat>;

    public function new() {}
}

extern class SDL_PixelsClass {
    @:native("SDL_PIXELFORMAT_RGBA8888") extern public static var SDL_PIXELFORMAT_RGBA8888:UInt32;
    @:native("SDL_MapRGBA") extern public static function SDL_MapRGBA(format:Pointer<SDL_PixelFormat>, r:UInt8, g:UInt8, b:UInt8, a:UInt8):UInt32;
}