package citro.object;

import citro.object.CitroObject;
import citro.math.CitroMath;

#if !wiiu
@:cppInclude("citro/CitroGame.h")
@:cppInclude("3ds.h")
#else
@:cppInclude("coreinit.h")
@:cppInclude("gx2.h")
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
			// Basic GX2 stub for camera
			// GX2SetViewport(...)
			// GX2SetContextState(...)
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
