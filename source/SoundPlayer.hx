package;

#if (!wiiu || !cafe)
import cpp.RawPointer;
import CWAV;

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

        CrashHandler.init();

        untyped __cpp__("ndspInit()");

        CWAVHelper.useEnvironment(0); 
        
        initialized = true;
        trace("SoundPlayer initialized with NDSP.");
    }

    public static function playSound(path:String):Void
    {
        init();

        var cwavPtr:RawPointer<CWAVData> = untyped __cpp__("calloc(1, sizeof(CWAV))");
        
        CWAVHelper.fileLoad(cwavPtr, path, 1);

        var status:Int = untyped __cpp__("((CWAV*){0})->loadStatus", cwavPtr);
        
        if (status == 1) {
            trace('Successfully loaded and playing sound: $path');
            CWAVHelper.play(cwavPtr, 0, -1);
        } else {
            trace('ERROR: Failed to load CWAV file "$path". Status code: $status');
        }
    }
}
#end
