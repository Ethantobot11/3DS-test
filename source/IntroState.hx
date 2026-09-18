package;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.state.CitroState;

class IntroState extends CitroState
{
    var logoIntro:DeltaruneLogoIntro;
    var introTimer:Float = 0;

    override public function create()
    {
        super.create();

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
