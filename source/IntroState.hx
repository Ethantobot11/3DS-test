package;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.backend.CitroColor;
import haxe3ds.services.HID;

class IntroState extends CitroState
{
    var logoIntro:DeltaruneLogoIntro;
    var introTimer:Float = 0;

    override public function create()
    {
        super.create();

        var bg = new CitroSprite(0, 0);
        bg.makeGraphic(CitroG.WIDTH, CitroG.HEIGHT, CitroColor.BLACK);
        add(bg);

        logoIntro = new DeltaruneLogoIntro(0, 0, false);
        add(logoIntro);
    }

    override public function update():Bool
    {
        super.update();

        var dtSec = 1.0 / 60.0; 
        introTimer += dtSec;

        if (HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.START))
        {
            if (logoIntro != null) {
                logoIntro.skipped = 1;
            }
        }

        if (introTimer >= 4.5 || (logoIntro != null && logoIntro.skipped == 1))
        {
            finishIntro();
        }
        
        return true;
    }

    private function finishIntro()
    {
        CitroG.switchState(new ThreeDSMainMenuState());
    }
}

#end
