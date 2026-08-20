package;

#if haxe3ds
import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import citro.CitroGame;
import citro.object.CitroText;
import citro.state.CitroState;
#else
import leafy.LfEngine;
import leafy.backend.sdl.LfWindowRender;
#end

class Main extends CitroState
{  
    public static var fpsText:CitroText;
    
    override public static function main():Void
    {
        super.create();
        #if haxe3ds
        CrashHandler.init();

        fpsText = new FPS();
        add(fpsText);
        
        trace("Starting Citro 3DS Application...");

        CitroGame.start(new ThreeDSMainMenuState());
        
        #else
        LfEngine.initEngine("Deltarune", DRC, new WiiUMainMenuState());
        #end
    }
}
