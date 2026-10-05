package citro.object;

import citro.object.CitroObject;
import citro.math.CitroMath;

#if !wiiu
@:cppInclude("citro/CitroGame.h")
@:cppInclude("3ds.h")
#else
@:cppInclude("SDL2/SDL.h")
@:headerCode("extern SDL_Renderer* gRenderer;")
#end

class CitroCamera extends CitroObject {
	var curX:Float = 0;
	var curY:Float = 0;
	var bottomCam:Bool = false;
	var scX:Int = 0;

	public var target:CitroObject = null;
	public var members:Array<CitroObject> = [];
	public var lerp:Float = 0.5;
	public var zoom:Float = 1;

	public function new(bottom:Bool = false) {
		super();
		bottomCam = bottom;
		scX = bottom ? 160 : 200;
	}

	override function update():Bool {
		if (target != null) {
			x = target.x - (bottomCam ? 160 : 200) + (target.width / 2);
			y = target.y - 120 + (target.height / 2);
		}

		super.update();

		curX = CitroMath.lerp(curX, x, lerp);
		curY = CitroMath.lerp(curY, y, lerp);
		bottom = bottomCam;

		#if !wiiu
		untyped __cpp__('
			C3D_Mtx camMtx;
			Mtx_Diagonal(&camMtx, 1.0f, 1.0f, 1.0f, 1.0f);
			C2D_ViewSave(&camMtx);
			C2D_ViewTranslate((Float){0}, 120.0f);
			C2D_ViewScale({1}, {1});
			C2D_ViewTranslate(-(Float){2} - (Float){0}, -(Float){3} - 120.0f);
		', scX, zoom, curX, curY);
		#else
		untyped __cpp__('
			if (!gRenderer) return true;

			SDL_Rect oldViewport;
			float oldScaleX, oldScaleY;
			SDL_RenderGetViewport(gRenderer, &oldViewport);
			SDL_RenderGetScale(gRenderer, &oldScaleX, &oldScaleY);

			float screenW = 1280.0f;
			float screenH = 720.0f;
			float centerX = screenW / 2.0f;
			float centerY = screenH / 2.0f;

			SDL_Rect camViewport;
			camViewport.x = (int)(centerX - (curX * zoom));
			camViewport.y = (int)(centerY - (curY * zoom));
			camViewport.w = (int)(screenW / zoom);
			camViewport.h = (int)(screenH / zoom);
			SDL_RenderSetViewport(gRenderer, &camViewport);
			SDL_RenderSetScale(gRenderer, zoom, zoom);
		');
		#end

		for (spr in members) {
			if (spr == null) continue;
			if (spr.isDestroyed) {
				members.remove(spr);
				continue;
			}
			if (!spr.visible || spr.alpha <= 0) continue;
			spr.update();
		}

		#if !wiiu
		untyped __cpp__('C2D_ViewRestore(&camMtx)');
		#else
		untyped __cpp__('
			SDL_RenderSetViewport(gRenderer, &oldViewport);
			SDL_RenderSetScale(gRenderer, oldScaleX, oldScaleY);
		');
		#end

		return true;
	}

	public function renderObj(spr:CitroObject):Bool {
		if (spr == null) return false;
		return spr.update();
	}

	public function follow(object:CitroObject, persistent:Bool = false) {
		if (object != null) {
			x = object.x - (bottomCam ? 160 : 200) + (object.width / 2);
			y = object.y - 120 + (object.height / 2);
		}
		if (persistent) {
			target = object;
		}
	}

	public function add(member:CitroObject) {
		members.push(member);
	}

	public function insert(index:Int, member:CitroObject) {
		members.insert(index, member);
	}

	override function destroy() {
		super.destroy();
		for (member in members) {
			member.destroy();
		}
		members = [];
	}
}
