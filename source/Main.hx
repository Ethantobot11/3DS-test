package;

#if haxe3ds
import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import citro.CitroGame;
#else
import leafy.LfEngine;
import leafy.backend.sdl.LfWindowRender;
#end

class Main
{
    public static function main():Void
    {
        #if haxe3ds
        CrashHandler.init();
        
        trace("Starting Citro 3DS Application...");

        CitroGame.start(new ThreeDSMainMenuState());
        #else
        LfEngine.initEngine("Deltarune", LfRenderType.DRC, new MainMenuState());
        #end
    }
}