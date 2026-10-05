package citro.object;

import citro.CitroG;
import citro.backend.CitroColor;
#if !HAXE3DS
import sdl2.SDL;
import sdl2.SDL_Render;
import sdl2.SDL_Image;
import cpp.Pointer;
#end

#if !wiiu
@:headerCode('
#include <3ds.h>
#include <citro2d.h>
#include <citro3d.h>
')
#else
@:headerCode('
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
extern "C" SDL_Renderer* gRenderer; 
')
#end

@:headerInclude("citro/object/CitroVector2D.h")

#if !wiiu
@:headerClassCode('
    C2D_SpriteSheet ss;
    C2D_Image image;
')
#else
@:headerClassCode('
    SDL_Texture* wiiu_texture = nullptr;
')
#end

class CitroSprite extends CitroObject {
    public var srcX:Float = 0;
    public var srcY:Float = 0;
    public var srcWidth:Float = 0;
    public var srcHeight:Float = 0;
    public var useSrcRect:Bool = false;

    public function new(x:Float = 0, y:Float = 0) {
        super();
        this.x = x;
        this.y = y;
    }

    inline public function makeGraphic(Width:Float, Height:Float, Col:CitroColor = 0xFFFFFFFF):CitroSprite {
        width  = Width;
        height = Height;
        color  = Col;
        return this;
    }

    public function setSourceRect(x:Float, y:Float, w:Float, h:Float):Bool {
        srcX = x; srcY = y; srcWidth = w; srcHeight = h;
        useSrcRect = true; width = w; height = h;
        return true;
    }

    public function loadGraphic(file:String):Bool {
        #if !wiiu
        if (CitroG.caches.cache.exists(file)) {
            untyped __cpp__('this->ss = (C2D_SpriteSheet){0}', CitroG.caches.get(file));
        }
        untyped __cpp__('
            if (!this->ss) {
                this->ss = C2D_SpriteSheetLoad(file.c_str());
                if (!this->ss) return false;
            }
            this->image = C2D_SpriteSheetGetImage(this->ss, 0);
            width = this->image.subtex->width;
            height = this->image.subtex->height;
        ');
        CitroG.caches.set(file, untyped __cpp__('this->ss'));
        #else
        untyped __cpp__('
            SDL_Surface* surface = IMG_Load(file.c_str());
            if (surface) {
                this->wiiu_texture = SDL_CreateTextureFromSurface(gRenderer, surface);
                this->width = surface->w;
                this->height = surface->h;
                SDL_FreeSurface(surface);
                return true;
            }
            return false;
        ');
        #end
        return true;
    }

    override function update():Bool {
        if (!visible || alpha <= 0) return false;
        
        #if !wiiu
        untyped __cpp__('
            Float sw = this->scale->x, sh = this->scale->y;
            C3D_Mtx matrix;
            Mtx_Diagonal(&matrix, 1.0f, 1.0f, 1.0f, 1.0f);
            C2D_ViewSave(&matrix);
            C2D_ViewTranslate(this->x, this->y);
            C2D_ViewTranslate(this->width * sw / 2.0, this->height * sh / 2.0);
            C2D_ViewRotateDegrees(this->angle);
            C2D_ViewScale(sw, sh);
            C2D_ViewTranslate(-this->width / 2.0, -this->height / 2.0);

            if (this->image.tex == NULL || this->image.subtex == NULL) {
                CONVERT_TO_COMPATIBLE_COLOR(this->color)
                C2D_DrawRectSolid(0, 0, 0, this->width, this->height, finalColor);
            } else {
                C2D_ImageTint tint;
                C2D_PlainImageTint(&tint, C2D_Color32((this->color >> 16) & 0xFF, (this->color >> 8) & 0xFF, this->color & 0xFF, ((this->color >> 24) & 0xFF) * C2D_Clamp(this->alpha, 0, 1)), 0);
                C2D_DrawImageAt(this->image, 0, 0, 0, &tint, 1, 1);
            }
            C2D_ViewRestore(&matrix);
        ');
        #else
        untyped __cpp__('
            if (!this->wiiu_texture || !gRenderer) return true;

            Uint8 alphaVal = (Uint8)(this->alpha * 255.0f);
            SDL_SetTextureAlphaMod(this->wiiu_texture, alphaVal);
            SDL_SetTextureColorMod(this->wiiu_texture, (this->color >> 16) & 0xFF, (this->color >> 8) & 0xFF, this->color & 0xFF);

            SDL_Rect dstRect;
            dstRect.x = (int)this->x;
            dstRect.y = (int)this->y;
            dstRect.w = (int)(this->width * this->scale->x);
            dstRect.h = (int)(this->height * this->scale->y);

            SDL_Point center;
            center.x = dstRect.w / 2;
            center.y = dstRect.h / 2;
            
            SDL_RenderCopyEx(gRenderer, this->wiiu_texture, NULL, &dstRect, (double)this->angle, &center, SDL_FLIP_NONE);
        ');
        #end
        return true;
    }

    override function destroy() {
        #if !wiiu
        untyped __cpp__('if (this->ss) { this->ss = nullptr; }');
        #else
        untyped __cpp__('
            if (this->wiiu_texture != nullptr) {
                SDL_DestroyTexture(this->wiiu_texture);
                this->wiiu_texture = nullptr;
            }
        ');
        #end
        super.destroy();
    }
}
