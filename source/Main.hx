package;

#if haxe3ds
import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import citro.CitroGame;
import citro.object.CitroObject;
import citro.object.CitroText;
import citro.backend.CitroTimer;
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

        SoundPlayer.preload('romfs:/assets/sounds/audiogroup_default/external/AUDIO_INTRONOISE.cwav');
        SoundPlayer.preload('romfs:/assets/sounds/snd_select.cwav');
        SoundPlayer.preload('romfs:/assets/sounds/snd_shineselect.cwav');
        SoundPlayer.preload('romfs:/assets/sounds/snd_error.cwav');
        SoundPlayer.preload('romfs:/assets/sounds/snd_break1.cwav');
        SoundPlayer.preload('romfs:/assets/sounds/snd_break2.cwav');
        SoundPlayer.preload('romfs:/assets/sounds/snd_save.cwav');
        
        trace("Starting Citro 3DS Application...");

        CitroGame.start(new ThreeDSMainMenuState());
        
        #else
        LfEngine.initEngine("Deltarune", DRC, new WiiUMainMenuState());
        #end
    }
}
