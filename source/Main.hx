package;

#if haxe3ds
import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import citro.CitroGame;
import citro.object.CitroObject;
import citro.object.CitroText;
#else
import leafy.LfEngine;
import leafy.backend.sdl.LfWindowRender;
#end

class Main
{  
    public static var fpsText:CitroText;
    
    public static function main():Void
    {
        #if haxe3ds
        romfsInit();
        
        CrashHandler.init();
        
        trace("Starting Citro 3DS Application...");

        CitroGame.start(new ThreeDSMainMenuState());
        
        #else
        LfEngine.initEngine("Deltarune", DRC, new WiiUMainMenuState());
        #end
    }
}
