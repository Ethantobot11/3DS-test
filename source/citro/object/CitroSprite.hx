package citro.object;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.backend.CitroColor;
import cpp.Pointer;
import cpp.Void;

@:headerInclude("3ds.h")
@:headerInclude("citro2d.h")
@:headerInclude("citro3d.h")

class CitroSprite extends CitroObject {
    
    @:native("ss")
    var sheet:Pointer<Void>;
    
    @:native("image")
    var img:Pointer<Void>;

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
        return true;
    }

    public function loadGraphic(file:String):Bool {
        if (CitroG.caches.cache.exists(file)) {
            untyped __cpp__('this->ss = (C2D_SpriteSheet){0}', CitroG.caches.get(file));
        }

        untyped __cpp__('
            if (!this->ss) {
                this->ss = (C2D_SpriteSheet)C2D_SpriteSheetLoad(file.c_str());
                if (!this->ss) return false;
            }

            this->img = (C2D_Image)C2D_SpriteSheetGetImage((C2D_SpriteSheet)this->ss, 0);
            width = ((C2D_Image)this->img)->subtex->width;
            height = ((C2D_Image)this->img)->subtex->height;
        ');

        CitroG.caches.set(file, untyped __cpp__('this->ss'));
        return true;
    }

    override function update():Bool {
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

            C2D_Image currentImage = (C2D_Image)this->img;

            if (currentImage.tex == NULL || currentImage.subtex == NULL) {
                CONVERT_TO_COMPATIBLE_COLOR(this->color)
                C2D_DrawRectSolid(0, 0, 0, this->width, this->height, finalColor);
            } else {
                C2D_ImageTint tint;
                C2D_PlainImageTint(
                    &tint,
                    C2D_Color32(
                        (this->color >> 16) & 0xFF,
                        (this->color >> 8) & 0xFF,
                        this->color & 0xFF,
                        ((this->color >> 24) & 0xFF) * C2D_Clamp(this->alpha, 0, 1)
                    ),
                    fabs(((Float)(this->color & 0xFFFFFF) / 16777215.0) - 1) / 2.0
                );
                
                if (this->useSrcRect) {
                    Tex3DS_SubTexture srcSubTex;
                    srcSubTex.width = (u16)this->srcWidth;
                    srcSubTex.height = (u16)this->srcHeight;
                    srcSubTex.left = this->srcX / currentImage.tex->width;
                    srcSubTex.right = (this->srcX + this->srcWidth) / currentImage.tex->width;
                    srcSubTex.top = this->srcY / currentImage.tex->height;
                    srcSubTex.bottom = (this->srcY + this->srcHeight) / currentImage.tex->height;
                    
                    C2D_Image drawImg = currentImage;
                    drawImg.subtex = &srcSubTex;
                    C2D_DrawImageAt(drawImg, 0, 0, 0, &tint, 1, 1);
                } else {
                    C2D_DrawImageAt(currentImage, 0, 0, 0, &tint, 1, 1);
                }
            }

            C2D_ViewRestore(&matrix);
        ');
        return true;
    }

    override function destroy() {
        untyped __cpp__('
            if (this->ss) {
                C2D_SpriteSheetFree((C2D_SpriteSheet)this->ss);
                this->ss = nullptr;
                this->img = nullptr;
            }
        ');
        super.destroy();
    }
}

#end
