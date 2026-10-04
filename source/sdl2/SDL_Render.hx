package sdl2;

import cpp.Pointer;
import cpp.Float;
import cpp.UInt8;
import cpp.UInt32;
import cpp.Int;
import sdl2.SDL_Rect.SDL_Rect;
import sdl2.SDL_Rect.SDL_FRect;
import sdl2.SDL_Rect.SDL_Point;
import sdl2.SDL_Rect.SDL_FPoint;
import sdl2.SDL_Pixels.SDL_Color;
import sdl2.SDL_Video.SDL_Window;

@:cppInclude("SDL2/SDL_render.h") @:include("SDL2/SDL_render.h")

@:native("SDL_RendererFlags")
extern enum SDL_RendererFlags {
    @:native("SDL_RENDERER_SOFTWARE") SDL_RENDERER_SOFTWARE;
    @:native("SDL_RENDERER_ACCELERATED") SDL_RENDERER_ACCELERATED;
    @:native("SDL_RENDERER_PRESENTVSYNC") SDL_RENDERER_PRESENTVSYNC;
    @:native("SDL_RENDERER_TARGETTEXTURE") SDL_RENDERER_TARGETTEXTURE;
}

@:native("SDL_RendererInfo")
extern typedef SDL_RendererInfo = {
    @:native("name") var name:cpp.ConstCharStar;
    @:native("flags") var flags:UInt32;
    @:native("num_texture_formats") var num_texture_formats:UInt32;
    @:native("texture_formats") var texture_formats:UInt32;
    @:native("max_texture_width") var max_texture_width:Int;
    @:native("max_texture_height") var max_texture_height:Int;
}

@:native("SDL_TextureAccess")
extern enum SDL_TextureAccess {
    @:native("SDL_TEXTUREACCESS_STATIC") SDL_TEXTUREACCESS_STATIC;
    @:native("SDL_TEXTUREACCESS_STREAMING") SDL_TEXTUREACCESS_STREAMING;
    @:native("SDL_TEXTUREACCESS_TARGET") SDL_TEXTUREACCESS_TARGET;
}

@:native("SDL_TextureModulate")
extern enum SDL_TextureModulate {
    @:native("SDL_TEXTUREMODULATE_NONE") SDL_TEXTUREMODULATE_NONE;
    @:native("SDL_TEXTUREMODULATE_COLOR") SDL_TEXTUREMODULATE_COLOR;
    @:native("SDL_TEXTUREMODULATE_ALPHA") SDL_TEXTUREMODULATE_ALPHA;
}

@:native("SDL_RendererFlip")
extern enum SDL_RendererFlip {
    @:native("SDL_FLIP_NONE") SDL_FLIP_NONE;
    @:native("SDL_FLIP_HORIZONTAL") SDL_FLIP_HORIZONTAL;
    @:native("SDL_FLIP_VERTICAL") SDL_FLIP_VERTICAL;
}

@:native("SDL_Texture")
extern class SDL_Texture {
    public function new();
}

@:native("SDL_Renderer")
extern class SDL_Renderer {
    public function new();
}

@:native("SDL_Vertex")
@:structAccess
extern class SDL_Vertex {
    public var position:SDL_FPoint;
    public var color:SDL_Color;
    public var tex_coord:SDL_FPoint;
    public function new();
}

@:native("SDL_ScaleMode")
extern enum SDL_ScaleMode {
    @:native("SDL_ScaleModeNearest") SDL_ScaleModeNearest;
    @:native("SDL_ScaleModeLinear") SDL_ScaleModeLinear;
    @:native("SDL_ScaleModeBest") SDL_ScaleModeBest;
}

extern class SDL_Render {
    @:native("SDL_GetNumRenderDrivers")
    extern public static function SDL_GetNumRenderDrivers():Int;

    @:native("SDL_GetRenderDriverInfo")
    extern public static function SDL_GetRenderDriverInfo(index:Int, info:Pointer<SDL_RendererInfo>):Int;
    
    @:native("SDL_CreateWindowAndRenderer")
    extern public static function SDL_CreateWindowAndRenderer(width:Int, height:Int, window_flags:UInt32, window:Pointer<SDL_Window>, renderer:Pointer<SDL_Renderer>):Int;

    @:native("SDL_CreateRenderer")
    extern public static function SDL_CreateRenderer(window:Pointer<SDL_Window>, index:Int, flags:SDL_RendererFlags):Pointer<SDL_Renderer>;

    @:native("SDL_CreateSoftwareRenderer")
    extern public static function SDL_CreateSoftwareRenderer(surface:Pointer<sdl2.SDL_Surface.SDL_Surface>):Pointer<SDL_Renderer>;

    @:native("SDL_GetRenderer")
    extern public static function SDL_GetRenderer(window:Pointer<SDL_Window>):Pointer<SDL_Renderer>;

    @:native("SDL_GetRendererInfo")
    extern public static function SDL_GetRendererInfo(renderer:Pointer<SDL_Renderer>, info:Pointer<SDL_RendererInfo>):Int;
    
    @:native("SDL_GetRendererOutputSize")
    extern public static function SDL_GetRendererOutputSize(renderer:Pointer<SDL_Renderer>, w:Pointer<Int>, h:Pointer<Int>):Int;

    @:native("SDL_CreateTexture")
    extern public static function SDL_CreateTexture(renderer:Pointer<SDL_Renderer>, format:UInt32, access:SDL_TextureAccess, w:Int, h:Int):Pointer<SDL_Texture>;

    @:native("SDL_CreateTextureFromSurface")
    extern public static function SDL_CreateTextureFromSurface(renderer:Pointer<SDL_Renderer>, surface:Pointer<sdl2.SDL_Surface.SDL_Surface>):Pointer<SDL_Texture>;

    @:native("SDL_QueryTexture")
    extern public static function SDL_QueryTexture(texture:Pointer<SDL_Texture>, format:Pointer<UInt32>, access:Pointer<Int>, w:Pointer<Int>, h:Pointer<Int>):Int;

    @:native("SDL_SetTextureColorMod")
    extern public static function SDL_SetTextureColorMod(texture:Pointer<SDL_Texture>, r:UInt8, g:UInt8, b:UInt8):Int;

    @:native("SDL_GetTextureColorMod")
    extern public static function SDL_GetTextureColorMod(texture:Pointer<SDL_Texture>, r:Pointer<UInt8>, g:Pointer<UInt8>, b:Pointer<UInt8>):Int;

    @:native("SDL_SetTextureAlphaMod")
    extern public static function SDL_SetTextureAlphaMod(texture:Pointer<SDL_Texture>, alpha:UInt8):Int;

    @:native("SDL_GetTextureAlphaMod")
    extern public static function SDL_GetTextureAlphaMod(texture:Pointer<SDL_Texture>, alpha:Pointer<UInt8>):Int;

    @:native("SDL_SetTextureBlendMode")
    extern public static function SDL_SetTextureBlendMode(texture:Pointer<SDL_Texture>, blendMode:sdl2.SDL_BlendMode.SDL_BlendMode):Int;

    @:native("SDL_SetRenderDrawBlendMode")
    extern public static function SDL_SetRenderDrawBlendMode(renderer:Pointer<SDL_Renderer>, blendMode:sdl2.SDL_BlendMode.SDL_BlendMode):Int;

    @:native("SDL_GetTextureBlendMode")
    extern public static function SDL_GetTextureBlendMode(texture:Pointer<SDL_Texture>, blendMode:Pointer<sdl2.SDL_BlendMode.SDL_BlendMode>):Int;

    @:native("SDL_UpdateTexture")
    extern public static function SDL_UpdateTexture(texture:Pointer<SDL_Texture>, rect:Pointer<SDL_Rect>, pixels:cpp.RawPointer<cpp.Void>, pitch:Int):Int;

    @:native("SDL_UpdateYUVTexture")
    extern public static function SDL_UpdateYUVTexture(texture:Pointer<SDL_Texture>, rect:Pointer<SDL_Rect>, Yplane:Pointer<UInt8>, Ypitch:Int, Uplane:Pointer<UInt8>, Upitch:Int, Vplane:Pointer<UInt8>, Vpitch:Int):Int;

    @:native("SDL_LockTexture")
    extern public static function SDL_LockTexture(texture:Pointer<SDL_Texture>, rect:Pointer<SDL_Rect>, pixels:cpp.RawPointer<cpp.Void>, pitch:Pointer<Int>):Int;

    @:native("SDL_UnlockTexture")
    extern public static function SDL_UnlockTexture(texture:Pointer<SDL_Texture>):Void;

    @:native("SDL_RenderTargetSupported")
    extern public static function SDL_RenderTargetSupported(renderer:Pointer<SDL_Renderer>):Int;

    @:native("SDL_SetRenderTarget")
    extern public static function SDL_SetRenderTarget(renderer:Pointer<SDL_Renderer>, texture:Pointer<SDL_Texture>):Int;

    @:native("SDL_GetRenderTarget")
    extern public static function SDL_GetRenderTarget(renderer:Pointer<SDL_Renderer>):Pointer<SDL_Texture>;

    @:native("SDL_RenderSetLogicalSize")
    extern public static function SDL_RenderSetLogicalSize(renderer:Pointer<SDL_Renderer>, w:Int, h:Int):Int;

    @:native("SDL_RenderGetLogicalSize")
    extern public static function SDL_RenderGetLogicalSize(renderer:Pointer<SDL_Renderer>, w:Pointer<Int>, h:Pointer<Int>):Int;

    @:native("SDL_RenderSetIntegerScale")
    extern public static function SDL_RenderSetIntegerScale(renderer:Pointer<SDL_Renderer>, enable:sdl2.SDL_Stdinc.SDL_bool):Int;

    @:native("SDL_DestroyTexture")
    extern public static function SDL_DestroyTexture(texture:Pointer<SDL_Texture>):Void;

    @:native("SDL_DestroyRenderer")
    extern public static function SDL_DestroyRenderer(renderer:Pointer<SDL_Renderer>):Void;

    @:native("SDL_RenderCopy")
    extern public static function SDL_RenderCopy(renderer:Pointer<SDL_Renderer>, texture:Pointer<SDL_Texture>, srcRect:Pointer<SDL_Rect>, dstRect:Pointer<SDL_Rect>):Int;

    @:native("SDL_RenderCopyEx")
    extern public static function SDL_RenderCopyEx(renderer:Pointer<SDL_Renderer>, texture:Pointer<SDL_Texture>, srcRect:Pointer<SDL_Rect>, dstRect:Pointer<SDL_Rect>, angle:Float, center:Pointer<SDL_Point>, flip:SDL_RendererFlip):Int;

    @:native("SDL_RenderCopyExF")
    extern public static function SDL_RenderCopyExF(renderer:Pointer<SDL_Renderer>, texture:Pointer<SDL_Texture>, srcRect:Pointer<SDL_Rect>, dstRect:Pointer<SDL_FRect>, angle:Float, center:Pointer<SDL_FPoint>, flip:SDL_RendererFlip):Int;

    @:native("SDL_RenderPresent")
    extern public static function SDL_RenderPresent(renderer:Pointer<SDL_Renderer>):Void;

    @:native("SDL_RenderClear")
    extern public static function SDL_RenderClear(renderer:Pointer<SDL_Renderer>):Int;

    @:native("SDL_SetRenderDrawColor")
    extern public static function SDL_SetRenderDrawColor(renderer:Pointer<SDL_Renderer>, r:UInt8, g:UInt8, b:UInt8, a:UInt8):Int;

    @:native("SDL_RenderFillRect")
    extern public static function SDL_RenderFillRect(renderer:Pointer<SDL_Renderer>, rect:Pointer<SDL_Rect>):Int;

    @:native("SDL_RenderGeometry")
    extern public static function SDL_RenderGeometry(renderer:Pointer<SDL_Renderer>, texture:Pointer<SDL_Texture>, vertices:Pointer<SDL_Vertex>, num_vertices:Int, indices:Int, num_indices:Int):Int;

    @:native("SDL_SetTextureScaleMode")
    extern public static function SDL_SetTextureScaleMode(texture:Pointer<SDL_Texture>, scaleMode:SDL_ScaleMode):Int;

    @:native("SDL_GetTextureScaleMode")
    extern public static function SDL_GetTextureScaleMode(texture:Pointer<SDL_Texture>, blendMode:Pointer<SDL_ScaleMode>):Int;
}