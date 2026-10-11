package citro.state;

import CrashHandler;
import citro.object.CitroObject;
import citro.object.CitroText;

class CitroState {
	
	public static var fpsText:CitroText;
	public var members:Array<CitroObject> = [];

	public function new() {}

	public function create() {
		if (fpsText == null) {
			fpsText = new CitroText(5, 5, "FPS: 60");
			fpsText.bottom = true;
			add(fpsText);
		}
	}

	public function update(delta:Int) {
		CrashHandler.protect(function() {
			var i = members.length - 1;
			while (i >= 0) {
				var member = members[i];
				if (member != null) {
					if (member.isDestroyed) {
						members.splice(i, 1);
					} else {
						member.update(); 
					}
				}
				i--;
			}
		}, new ThreeDSMainMenuState());
	}

	public function destroy() {
		for (member in members) {
			if (member != null) member.destroy();
		}
		members.splice(0, members.length);
	}

	function check(member:CitroObject):Bool {
		if (member == null) return true;
		if (members.indexOf(member) > -1) return true;
		return false;
	}

	public function add(member:CitroObject) {
		if (check(member)) return;
		members.push(member);
	}

	public function insert(index:Int, member:CitroObject) {
		if (check(member)) return;
		if (index < 0) index = 0;
		if (index > members.length) index = members.length;
		members.insert(index, member);
	}

	public function remove(member:CitroObject, once:Bool = true) {
		if (once) {
			members.remove(member);
		} else {
			while (members.remove(member)) {}
		}
	}

	public function openSubstate(substate:CitroSubState) {
		if (CitroG.substate != null) return;
		CitroG.substate = substate;
		substate.create();
	}
}
