package sdl2;

import cpp.Pointer;
import cpp.RawPointer;
import cpp.Void;
import cpp.Int32;
import cpp.UInt32;
import cpp.Float;
import cpp.ConstCharStar;
import cpp.UInt8;

@:include("SDL2/SDL_render.h")
@:native("SDL_RendererFlip")
extern enum SDL_RendererFlip {
    @:native("SDL_FLIP_NONE") SDL_FLIP_NONE;
    @:native("SDL_FLIP_HORIZONTAL") SDL_FLIP_HORIZONTAL;
    @:native("SDL_FLIP_VERTICAL") SDL_FLIP_VERTICAL;
}

@:include("SDL2/SDL_render.h")
@:native("SDL_Texture")
extern class SDL_Texture {
    public function new() {}
}

@:include("SDL2/SDL_render.h")
@:native("SDL_Renderer")
extern class SDL_Renderer {
    public function new() {}
}

@:include("SDL2/SDL_render.h")
extern class SDL_Render {
    @:native("SDL_CreateWindowAndRenderer")
    extern public static function SDL_CreateWindowAndRenderer(width:Int, height:Int, window_flags:UInt32, window:Pointer<SDL_Window>, renderer:Pointer<SDL_Renderer>):Int;

    @:native("SDL_CreateTextureFromSurface")
    extern public static function SDL_CreateTextureFromSurface(renderer:Pointer<SDL_Renderer>, surface:Pointer<SDL_Surface>):Pointer<SDL_Texture>;

    @:native("SDL_QueryTexture")
    extern public static function SDL_QueryTexture(texture:Pointer<SDL_Texture>, format:Pointer<UInt32>, access:Pointer<Int32>, w:Pointer<Int32>, h:Pointer<Int32>):Int;

    @:native("SDL_SetTextureColorMod")
    extern public static function SDL_SetTextureColorMod(texture:Pointer<SDL_Texture>, r:UInt8, g:UInt8, b:UInt8):Int;

    @:native("SDL_SetTextureAlphaMod")
    extern public static function SDL_SetTextureAlphaMod(texture:Pointer<SDL_Texture>, alpha:UInt8):Int;

    @:native("SDL_SetRenderDrawBlendMode")
    extern public static function SDL_SetRenderDrawBlendMode(renderer:Pointer<SDL_Renderer>, blendMode:SDL_BlendMode):Int;

    @:native("SDL_DestroyTexture")
    extern public static function SDL_DestroyTexture(texture:Pointer<SDL_Texture>):Void;

    @:native("SDL_RenderCopy")
    extern public static function SDL_RenderCopy(renderer:Pointer<SDL_Renderer>, texture:Pointer<SDL_Texture>, srcRect:Const<Pointer<SDL_Rect>>, dstRect:Pointer<SDL_Rect>):Int;

    @:native("SDL_RenderCopyEx")
    extern public static function SDL_RenderCopyEx(renderer:Pointer<SDL_Renderer>, texture:Pointer<SDL_Texture>, srcRect:Const<Pointer<SDL_Rect>>, dstRect:Pointer<SDL_Rect>, angle:Float, center:Pointer<SDL_Point>, flip:SDL_RendererFlip):Int;

    @:native("SDL_RenderPresent")
    extern public static function SDL_RenderPresent(renderer:Pointer<SDL_Renderer>):Void;

    @:native("SDL_RenderClear")
    extern public static function SDL_RenderClear(renderer:Pointer<SDL_Renderer>):Int;

    @:native("SDL_SetRenderDrawColor")
    extern public static function SDL_SetRenderDrawColor(renderer:Pointer<SDL_Renderer>, r:UInt8, g:UInt8, b:UInt8, a:UInt8):Int;
}
