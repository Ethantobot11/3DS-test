package;

import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import citro.CitroGame;

class Main
{
    public static function main():Void
    {
        CrashHandler.init();
        
        trace("Starting Citro 3DS Application...");

        try {
            CitroGame.start(new MainMenuState());
        } catch (e:Dynamic) {
            CrashHandler.logException(e, "Fatal error during CitroGame execution!");
            throw e;
        }
    }
}