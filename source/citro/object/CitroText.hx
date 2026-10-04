package citro.object;

import citro.backend.CitroColor;
#if !HAXE3DS
import sdl2.SDL_TTF;
import sdl2.SDL_Surface;
import sdl2.SDL_Render;
import cpp.Pointer;
#end

using StringTools;

enum abstract Align(Int) {
	var LEFT;
	var CENTER;
	var RIGHT;
}

enum abstract BorderStyle(Int) {
	var NONE;
	var OUTLINE;
	var SHADOW;
}

#if !wiiu
@:cppFileCode('
#include "haxe3ds_Utils.h"
static C2D_Font fnt = NULL;
static C2D_TextBuf sbuf = NULL;
C2D_Text c2dText;
const Float offsets[8][2] = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}, {1, 0}, {-1, 0}, {0, 1}, {0, -1}};
namespace textUtil {
void createText(citro::object::CitroText_obj* value) {
	C2D_TextBufClear(sbuf);
	C2D_TextFontParse(&c2dText, value->defaultFont ? value->defaultFont : fnt, sbuf, value->text.utf8_str());
	C2D_TextOptimize(&c2dText);
	float width, height;
	C2D_TextGetDimensions(&c2dText, value->scale->x, value->scale->y, &width, &height);
	value->width = width;
	value->height = height;
}
}')
#else
@:cppFileCode('
#include <SDL.h>
#include <SDL_ttf.h>
extern "C" SDL_Renderer* gRenderer;
extern "C" TTF_Font* gDefaultFont;
namespace textUtil {
void createText(void* value) {}
}')
#end

#if !wiiu
@:headerCode('#include <citro2d.h>\n#include <citro3d.h>')
@:headerClassCode('C2D_Font defaultFont;')
#else
@:headerCode('#include <SDL.h>\n#include <SDL_ttf.h>')
@:headerClassCode('TTF_Font* defaultFont = nullptr;')
#end

class CitroText extends CitroObject {
	public var text:String = "";
	public var alignment:Align = LEFT;
	public var borderColor:CitroColor = 0xFF000000;
	public var borderSize:Float = 1;
	public var borderStyle:BorderStyle = NONE;

	public function new(x:Float = 0, y:Float = 0, Text:String = "") {
		super();
		this.x = x;
		this.y = y;
		this.text = Text;

		#if !wiiu
		untyped __cpp__('
			if (sbuf == NULL) {
				fnt = C2D_FontLoadSystem(CFG_REGION_USA);
				sbuf = C2D_TextBufNew(512);
			} textUtil::createText(this)
		', this.scale);
		#else
		width = text.length * 10;
		height = 20;
		#end
	}

	override function update():Bool {
		if (text.length == 0 || super.update()) return false;

		#if !wiiu
		untyped __cpp__('
			textUtil::createText(this);
			float newX = x, sw = scale->x, sh = scale->y;
			u32 fl = C2D_WithColor;
			switch (alignment) {
				case 0: break;
				case 1: newX += {0} ? (320 - width) / 2 : (400 - width) / 2; break;
				case 2: newX += {0} ? 320 - width : 400 - width; break;
			}
			C3D_Mtx matrix;
			Mtx_Diagonal(&matrix, 1.0f, 1.0f, 1.0f, 1.0f);
			C2D_ViewSave(&matrix);
			C2D_ViewTranslate(newX, y);
			C2D_ViewTranslate(width * sw / 2.0, height * sh / 2.0);
			C2D_ViewRotateDegrees(angle);
			C2D_ViewScale(sw, sh);
			C2D_ViewTranslate(-width / 2.0, -height / 2.0);

			if (borderStyle != 0 && borderSize >= 0) {
				CONVERT_TO_COMPATIBLE_COLOR(borderColor)
				switch(borderStyle) {
					case 1: for (int i = 0; i < 8; i++) C2D_DrawText(&c2dText, fl, (offsets[i][0] * borderSize), (offsets[i][1] * borderSize), 0, 1, 1, finalColor); break;
					case 2: for (int i = 1; i < borderSize + 1; i++) C2D_DrawText(&c2dText, fl, -i, i, 0, 1, 1, finalColor); break;
				}
			}
			CONVERT_TO_COMPATIBLE_COLOR(color)
			C2D_DrawText(&c2dText, fl, 0, 0, 0, 1, 1, finalColor);
			C2D_ViewRestore(&matrix)
		', bottom);
		#else
		untyped __cpp__('
			if (!defaultFont || !gRenderer) return true;
			
			SDL_Color fg = { (Uint8)((this->color >> 16) & 0xFF), (Uint8)((this->color >> 8) & 0xFF), (Uint8)(this->color & 0xFF), (Uint8)(this->alpha * 255.0f) };
			SDL_Surface* textSurface = TTF_RenderText_Blended(defaultFont, this->text.utf8_str(), fg);
			if (textSurface) {
				SDL_Texture* textTexture = SDL_CreateTextureFromSurface(gRenderer, textSurface);
				if (textTexture) {
					SDL_Rect dstRect;
					dstRect.x = (int)this->x;
					dstRect.y = (int)this->y;
					dstRect.w = (int)(textSurface->w * this->scale->x);
					dstRect.h = (int)(textSurface->h * this->scale->y);
					
					SDL_RenderCopy(gRenderer, textTexture, NULL, &dstRect);
					SDL_DestroyTexture(textTexture);
				}
				SDL_FreeSurface(textSurface);
			}
		');
		#end
		return true;
	}

	public function loadFont(path:String):Bool {
		#if HAXE3DS
		var success = false;
		if (CitroG.caches.cache.exists(path)) {
			untyped __cpp__('defaultFont = (C2D_Font){0}; success = defaultFont != nullptr', CitroG.caches.get(path));
		}
		if (!success) {
			success = untyped __cpp__('(defaultFont = C2D_FontLoad(path.c_str())) != NULL');
			if (success) CitroG.caches.set(path, untyped __cpp__('defaultFont'));
		}
		return success;
		#else
		var success:Bool = false;
		untyped __cpp__('
			this->defaultFont = TTF_OpenFont(path.c_str(), 24);
			success = (this->defaultFont != nullptr);
		');
		return success;
		#end
	}

	inline public function setBorderStyle(color:CitroColor = 0xFF000000, size:Float = 1, style:BorderStyle = OUTLINE):CitroText {
		borderColor = color;
		borderSize = size;
		borderStyle = style;
		return this;
	}

	override function destroy() {
		super.destroy();
		#if !wiiu
		untyped __cpp__('if (defaultFont) { C2D_FontFree(defaultFont); defaultFont = nullptr; }');
		#else
		untyped __cpp__('if (defaultFont != nullptr) { TTF_CloseFont(defaultFont); defaultFont = nullptr; }');
		#end
	}
}
