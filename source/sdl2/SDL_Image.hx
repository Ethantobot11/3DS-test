package sdl2;

import cpp.Pointer;
import cpp.ConstCharStar;
import cpp.Int32;

@:include("SDL2/SDL_image.h")
extern class SDL_Image {
    @:native("IMG_Init")
    extern public static function IMG_Init(flags:Int):Int;

    @:native("IMG_Quit")
    extern public static function IMG_Quit():Void;

    @:native("IMG_Load")
    extern public static function IMG_Load(file:ConstCharStar):Pointer<SDL_Surface>;

    @:native("IMG_LoadTexture")
    extern public static function IMG_LoadTexture(renderer:Pointer<SDL_Renderer>, file:ConstCharStar):Pointer<SDL_Texture>;
}
