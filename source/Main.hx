package;

#if !wiiu
import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import haxe3ds.services.misc.PLGLDR;
import citro.CitroGame;
import citro.object.CitroText;

using StringTools;
@:headerInclude("3ds.h")
#else
import leafy.LfEngine;
import leafy.backend.sdl.LfWindowRender;
@:cppFileCode('
#include <wups.h>

WUPS_PLUGIN_NAME("Deltarune");
WUPS_PLUGIN_DESCRIPTION("A fangame of deltarune for Wii U");
WUPS_PLUGIN_AUTHOR("Ethantobot");
WUPS_PLUGIN_VERSION("v1.0.0");
WUPS_PLUGIN_LICENSE("MIT");
WUPS_USE_STORAGE("com.ethantobot.deltarune");
WUPS_ON_APPLICATION_START() {
}
')
#end

class Main {
    #if !wiiu
    public static var fpsText:CitroText;
    #end
    
    public static function main():Void {
        #if !wiiu
        RomFS.init();
        CrashHandler.init();

        var plgResult = PLGLDR.init();
        if (plgResult == 0) {
            trace("Luma3DS Plugin Loader initialized successfully.");
            PLGLDR.displayMessage("Deltarune 3DS", "Luma3DS Plugin Loader active!");
        } else {
            trace("Luma3DS Plugin Loader not available (Result: " + plgResult + ")");
        }
        
        trace("Starting Deltarune 3DS Application...");
        // AchievementManager.unlock("play_DELTARUNE_3DS"); 
        
        CitroGame.start(new LoadingState());
        #else
        LfEngine.initEngine("Deltarune", DRC, new WiiUMainMenuState());
        #end
    }
}
