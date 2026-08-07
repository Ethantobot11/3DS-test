package;
#if (!wiiu || !cafe)
import cpp.RawPointer;
import CWAV;

@:headerCode('
#include "cwav.h"
')
class SoundPlayer
{
    private static var initialized:Bool = false;

    public static function init():Void
    {
        if (initialized) return;
        CWAVHelper.useEnvironment(0); 
        initialized = true;
    }

    public static function playSound(path:String):Void
    {
        init();
        var cwavPtr:RawPointer<CWAVData> = untyped __cpp__("malloc(sizeof(CWAV))");
        CWAVHelper.fileLoad(cwavPtr, path, 1);
        CWAVHelper.play(cwavPtr, 0, -1);
    }
}
#end