package;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.object.CitroSprite;
import haxe3ds.services.HID;
import citro.object.CitroSprite;

class DeltaruneLogoIntro extends CitroSprite
{
    public var w:Float = 0;
    public var h:Float = 0;
    
    public var siner:Float = 0;
    public var factor:Float = 1;
    public var factor2:Float = 0;
    public var factory:Float = 0;
    public var mid:Float = 0;
    public var inity:Float = 0;
    
    public var PHASE:Int = 0;
    public var PHASETIMER:Float = 0;
    public var PHASEPLUS:Float = 0;
    public var AA:Float = 1;
    public var AB:Float = 1;
    public var ingame:Int = 1;
    
    public var skipped:Int = 0;
    public var skiptimer:Float = 0;
    public var draw_screen:Bool = true;

    public function new(xPos:Float, yPos:Float, isIngame:Bool = true)
    {
        super(xPos, yPos);
        
        loadGraphic("romfs:/assets/images/spr_deltarunelogo.t3x");

        w = width;
        h = height;

        SoundPlayer.playSound('romfs:/assets/sounds/AUDIO_INTRONOISE.cwav');

        siner = 0;
        factor = 1;
        factor2 = 0;
        factory = h / 2;
        mid = h / 2;
        
        x = (CitroG.WIDTH / 2) - (w / 2);
        y = (CitroG.HEIGHT / 2) - (h / 2) - 10;
        inity = y;

        PHASE = 0;
        PHASETIMER = 0;
        PHASEPLUS = 0;
        AA = 1;
        AB = 1;
        
        ingame = isIngame ? 1 : 0;
        
        if (CitroG.save.data.plot == 0) ingame = 0;

        skipped = 0;
        skiptimer = 0;
        draw_screen = true;
    }

    override public function update():Void
    {
        super.update();

        if (!draw_screen) return;

        siner += 1;

        switch (PHASE)
        {
            case 0:
                PHASETIMER += 1;
                if (PHASETIMER >= 30)
                {
                    PHASE = 1;
                    PHASETIMER = 0;
                }
            case 1:
                factor2 += 0.05;
        }

        if (HID.keyPressed(HIDKey.START) || HID.keyPressed(HIDKey.A))
        {
            skipped = 1;
        }
    }
}

#end
