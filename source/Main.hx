package;

import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import haxe3ds.services.misc.PLGLDR;
import citro.CitroGame;

using StringTools;

class Main {
    public static function main():Void {
        CrashHandler.init();

        #if haxe3ds
        RomFS.init();
        var plgResult = PLGLDR.init();
        if (plgResult == 0) {
            trace("Luma3DS Plugin Loader initialized successfully.");
            PLGLDR.displayMessage("Deltarune 3DS", "Luma3DS Plugin Loader active!");
        } else {
            trace("Luma3DS Plugin Loader not available (Result: " + plgResult + ")");
        }
        trace("Starting Deltarune 3DS Application...");
        #else
        trace("Starting Deltarune Wii U Application...");
        #end

        // AchievementManager.unlock("play_DELTARUNE_3DS");
        #if HAXE3DS
        CitroGame.start(new LoadingState());
        #else
        CitroGame.start(new ThreeDSMenuState());
        #end
    }
}