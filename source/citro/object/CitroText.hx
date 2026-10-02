package citro.object;

import citro.backend.CitroColor;

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

@:cppFileCode('
#include "haxe3ds_Utils.h"

static C2D_Font fnt = NULL;
const Float offsets[8][2] = {{-1, -1}, {1, -1}, {-1, 1}, {1, 1}, {1, 0}, {-1, 0}, {0, 1}, {0, -1}};

namespace textUtil {
void createText(citro::object::CitroText_obj* value) {
	C2D_TextBufClear(value->sbuf);
	C2D_TextFontParse(&value->c2dText, value->defaultFont ? value->defaultFont : fnt, value->sbuf, value->text.utf8_str());
	C2D_TextOptimize(&value->c2dText);

	float width, height;
	C2D_TextGetDimensions(&value->c2dText, value->scale->x, value->scale->y, &width, &height);
	value->width = width;
	value->height = height;
}
}')

@:headerCode('
#include <citro2d.h>
#include <citro3d.h>
')
@:headerClassCode('
    C2D_Font defaultFont;
    C2D_TextBuf sbuf;
    C2D_Text c2dText;
')
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

		untyped __cpp__('
			if (fnt == NULL) {
				fnt = C2D_FontLoadSystem(CFG_REGION_USA);
			}
            this->sbuf = C2D_TextBufNew(4096);
			textUtil::createText(this);
		');
	}

	override function update():Bool {
		if (text.length == 0 || super.update()) {
			return false;
		}

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
					case 1: {
						for (int i = 0; i < 8; i++) C2D_DrawText(&this->c2dText, fl, (offsets[i][0] * borderSize), (offsets[i][1] * borderSize), 0, 1, 1, finalColor);
						break;
					}
					case 2: {
						for (int i = 1; i < borderSize + 1; i++) C2D_DrawText(&this->c2dText, fl, -i, i, 0, 1, 1, finalColor);
						break;
					}
				}
			}

			CONVERT_TO_COMPATIBLE_COLOR(color)
			C2D_DrawText(&this->c2dText, fl, 0, 0, 0, 1, 1, finalColor);
			C2D_ViewRestore(&matrix)
		', bottom);

		return true;
	}

	public function loadFont(path:String):Bool {
		var success = false;
		if (CitroG.caches.cache.exists(path)) {
			untyped __cpp__('
				defaultFont = (C2D_Font){0};
				success = defaultFont != nullptr
			', CitroG.caches.get(path));
		}

		if (!success) {
			success = untyped __cpp__('(defaultFont = C2D_FontLoad(path.c_str())) != NULL');
			if (success) {
				CitroG.caches.set(path, untyped __cpp__('defaultFont'));
			}
		}

		return success;
	}

	inline public function setBorderStyle(color:CitroColor = 0xFF000000, size:Float = 1, style:BorderStyle = OUTLINE):CitroText {
		borderColor = color;
		borderSize = size;
		borderStyle = style;
		return this;
	}

	override function destroy() {
		super.destroy();
		untyped __cpp__('
			if (this->sbuf) {
				C2D_TextBufDelete(this->sbuf);
				this->sbuf = nullptr;
			}
			if (defaultFont) {
				C2D_FontFree(defaultFont);
				defaultFont = nullptr;
			}
		');
	}
}
