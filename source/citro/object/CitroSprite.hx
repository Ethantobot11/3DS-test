package citro.object;

import citro.CitroG;
import citro.backend.CitroColor;

#if HAXE3DS
@:headerCode('
#include <3ds.h>
#include <citro2d.h>
#include <citro3d.h>
')
#else
@:headerCode('
#include <coreinit.h>
#include <gx2.h>
#include <gx2/draw.h>
#include <gx2/utils.h>
#include <gx2/state.h>
')
#end

@:headerInclude("citro/object/CitroVector2D.h")

#if HAXE3DS
@:headerClassCode('
    C2D_SpriteSheet ss;
    C2D_Image image;
')
#else
@:headerClassCode('
    GX2Texture* texture = nullptr;
    GX2Sampler sampler;
    bool isLoaded = false;
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
        srcX = x;
        srcY = y;
        srcWidth = w;
        srcHeight = h;
        useSrcRect = true;
        width = w;
        height = h;
        return true;
    }

    public function loadGraphic(file:String):Bool {
        #if HAXE3DS
        if (CitroG.caches.cache.exists(file)) {
            untyped __cpp__('this->ss = (C2D_SpriteSheet){0}', CitroG.caches.get(file));
        }
        untyped __cpp__('
            if (!this->ss) {
                this->ss = C2D_SpriteSheetLoad(file.c_str());
                if (!this->s) return false;
            }
            this->image = C2D_SpriteSheetGetImage(this->ss, 0);
            width = this->image.subtex->width;
            height = this->image.subtex->height;
        ');
        CitroG.caches.set(file, untyped __cpp__('this->ss'));
        #else
        untyped __cpp__('
            // GX2InitTextureRegs(&this->texture);
            // GX2SetupTextureEx(&this->texture, ...);
            // GX2InitSampler(&this->sampler, GX2_TEX_CLAMP_MODE_CLAMP, GX2_TEX_XY_FILTER_MODE_POINT);
            this->isLoaded = true;
            this->width = 100;
            this->height = 100;
        ');
        #end
        return true;
    }

    override function update():Bool {
        if (!visible || alpha <= 0) return false;
        
        #if HAXE3DS
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
            if (!this->isLoaded || this->texture == nullptr) return true;

            GX2SetBlendControl(GX2_RENDER_TARGET_0, GX2_BLEND_MODE_SRC_ALPHA, GX2_BLEND_MODE_INV_SRC_ALPHA, GX2_BLEND_COMBINE_MODE_ADD, TRUE, GX2_BLEND_MODE_SRC_ALPHA, GX2_BLEND_MODE_INV_SRC_ALPHA, GX2_BLEND_COMBINE_MODE_ADD);
            
            GX2SetPixelTexture(this->texture, 0);
            GX2SetPixelSampler(&this->sampler, 0);
            GX2DrawEx(GX2_PRIMITIVE_MODE_QUADS, 4, 0, 1);
        ');
        #end
        return true;
    }

    override function destroy() {
        #if HAXE3DS
        untyped __cpp__('if (this->ss) { this->ss = nullptr; }');
        #else
        untyped __cpp__('
            if (this->texture != nullptr) {
                // Free GX2 texture memory (implementation depends on your memory allocator)
                // GX2Invalidate(GX2_INVALIDATE_MODE_CPU, this->texture->image, this->texture->imageSize);
                this->texture = nullptr;
            }
        ');
        #end
        super.destroy();
    }
}
