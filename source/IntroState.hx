package;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.state.CitroState;
import citro.backend.CitroColor;

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

    override public function update(delta:Int)
    {
        super.update(delta);

        var dtSec = delta / 1000.0;
        introTimer += dtSec;

        if (introTimer >= 4.5 || (logoIntro != null && logoIntro.skipped == 1))
        {
            finishIntro();
        }
    }

    private function finishIntro()
    {
        CitroG.switchState(new ThreeDSMainMenuState());
    }
}

#end
