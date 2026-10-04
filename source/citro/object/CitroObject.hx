package citro.object;

import cpp.UInt16;
import citro.state.CitroState;
import citro.backend.CitroColor;

enum abstract CitroAxes(Int) {
	var X;
	var Y;
	var XY;
}

typedef CitroAcceleration = {
	var x:Float;
	var y:Float;
	var angle:Float;
}

class CitroVector2D {
	public var x:Float = 1;
	public var y:Float = 1;

	public function set(xTo:Float, yTo:Float) {
		x = xTo;
		y = yTo;
	}

	public function new() {};
}

@:headerCode('
#define CONVERT_TO_COMPATIBLE_COLOR(color) \\
	u32 finalColor = ((color & 0xFF00FF00) | ((color >> 16) & 0xFF) | ((color & 0xFF) << 16)); \\
	if (alpha < 1) finalColor = (color & 0x00FFFFFF) | ((u8)((u8)((color >> 24) & 0xFF) * alpha) << 24);
')
#if HAXE3DS
@:headerInclude("3ds.h")
#else
@:headerInclude("coreinit.h")
#end
class CitroObject {
	public var acceleration:CitroAcceleration = {x: 0, y: 0, angle: 0};
	public var alpha:Float = 1;
	public var angle:Float = 0;
	public var bottom:Bool = false;
	public var color:CitroColor = 0xFFFFFFFF;
	public var height(default, null):Float = 0;

	public var index(get, set):UInt16;
	function get_index():UInt16 {
		final pos = CitroG.state.members.indexOf(this);
		if (pos == -1 && CitroG.substate != null) {
			return CitroG.substate.members.indexOf(this);
		}
		return pos;
	}

	function set_index(index:UInt16):UInt16 {
		var state:CitroState = CitroG.state;
		if (!CitroG.state.members.contains(this)) {
			if (CitroG.substate == null || !CitroG.substate.members.contains(this)) {
				return -1;
			}
			state = CitroG.substate;
		}
		state.remove(this);
		state.insert(index, this);
		return index;
	}

	@:noCompletion
	public var isDestroyed(default, null):Bool = false;

	public var scale:CitroVector2D = new CitroVector2D();
	public var visible:Bool = true;
	public var width(default, null):Float = 0;
	public var x:Float = 0;
	public var y:Float = 0;

	public function new() {}

	public function destroy() {
		isDestroyed = true;
		acceleration = null;
		scale = null;
	}

	public function update():Bool {
		x += acceleration.x;
		y += acceleration.y;
		angle += acceleration.angle;
		return isOnScreen() || isDestroyed;
	};

	public function screenCenter(pos:CitroAxes = XY) {
		final newW:Float = width * scale.x;
		final newX:Float = bottom ? (320 - newW) / 2 : (CitroG.WIDTH - newW) / 2;
		final newY:Float = (CitroG.HEIGHT - (height * scale.y)) / 2;

		switch(pos) {
			case X:  x = newX;
			case Y:  y = newY;
			case XY: x = newX; y = newY;
		}
	}
	
	public function isOnScreen():Bool {
		if (!visible || alpha <= 0) return false; 
		final w = CitroG.WIDTH;
		final h = CitroG.HEIGHT;
		final sw = width * scale.x;
		final sh = height * scale.y;

		return x + sw > 0 && x < (bottom ? 320 : w) && y + sh > 0 && y < h;
	}
}
