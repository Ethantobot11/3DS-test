package;

#if (!wiiu || !cafe)
import cpp.RawPointer;
import CWAV;
import citro.CitroG;

@:headerCode('
#include "3ds.h"
#include "cwav.h"
')
class SoundPlayer
{
	private static var initialized:Bool = false;

	public static function init():Void
	{
		if (initialized) return;

		untyped __cpp__("ndspInit()");
		CWAVHelper.useEnvironment(0);	
		
		initialized = true;
		trace("SoundPlayer initialized with NDSP.");
	}

	public static function playSound(path:String):Void
	{
		init();

		var cwavPtr:RawPointer<CWAVData> = cast CitroG.caches.get(path);

		if (cwavPtr == null) {
			cwavPtr = untyped __cpp__("calloc(1, sizeof(CWAV))");
			
			CWAVHelper.fileLoad(cwavPtr, path, 4);

			var status:Int = untyped __cpp__("((CWAV*){0})->loadStatus", cwavPtr);
			
			if (status == 1) {
				CitroG.caches.set(path, cwavPtr);
				trace('Successfully cached and loaded sound: $path');
			} else {
				trace('ERROR: Failed to load CWAV file "$path". Status code: $status');
				untyped __cpp__("free({0})", cwavPtr);
				return;
			}
		}

		CWAVHelper.play(cwavPtr, 0, -1);
	}
}
#end
