package;

#if haxe3ds
import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import haxe3ds.services.misc.PLGLDR;
import citro.CitroGame;
import citro.object.CitroObject;
import citro.object.CitroText;
import citro.backend.CitroTimer;
import sys.FileSystem;
#else
import leafy.LfEngine;
import leafy.backend.sdl.LfWindowRender;
#end

class Main
{
    #if haxe3ds
    public static var fpsText:CitroText;
    #end
    
    public static function main():Void
    {
        #if haxe3ds
        RomFS.init();
        CrashHandler.init();

        var plgResult = PLGLDR.init();
        if (plgResult == 0) {
            trace("Luma3DS Plugin Loader initialized successfully.");
            PLGLDR.displayMessage("Deltarune 3DS", "Luma3DS Plugin Loader active!");
        } else {
            trace("Luma3DS Plugin Loader not available (Result: " + plgResult + ")");
        }

        var soundDir = "romfs:/assets/sounds";
        if (FileSystem.isDirectory(soundDir)) {
            for (file in FileSystem.readDirectory(soundDir)) {
                if (file.endsWith(".cwav")) {
                    var fullPath = '$soundDir/$file';
                    SoundPlayer.preload(fullPath);
                    trace('Auto-preloaded: $fullPath');
                }
            }
        } else {
            trace('WARNING: Sound directory not found: $soundDir');
        }
        
        trace("Starting Deltarune 3DS Shitty Application...");

        CitroGame.start(new ThreeDSMainMenuState());
        
        #else
        LfEngine.initEngine("Deltarune", DRC, new WiiUMainMenuState());
        #end
    }
}
