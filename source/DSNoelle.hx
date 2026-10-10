package;

#if (!wiiu || !cafe)

import citro.object.CitroAnimate;
using StringTools;

class DSNoelle extends CitroAnimate
{
    public var isFollowing:Bool = false;
    public var target:DSPlayer;
    public var trailDelay:Int = 18; 

    public function new(x:Float, y:Float)
    {
        super("romfs:/assets/images/chars/noelle_light.cea", "spr_noelle_walk_down_lw");
        
        this.x = x;
        this.y = y;
        framerate = 6;
        looped = true;
    }

    override public function update():Bool
    {
        if (!isFollowing)
        {
            if (curAnim != "spr_noelle_walk_down_lw") {
                play("spr_noelle_walk_down_lw");
            }

            timeLeft = 999999;
            frame = 0;
        }
        else
        {
            if (target != null)
            {
                followPathTrail();
            }
        }
        
        return super.update();
    }

    private function followPathTrail()
    {
        if (target != null && target.pathHistory.length > 0)
        {
            var indexToUse = (target.pathHistory.length >= trailDelay) ? (trailDelay - 1) : (target.pathHistory.length - 1);
            var targetFrame = target.pathHistory[indexToUse];

            x = targetFrame.x;
            y = targetFrame.y;

            var desiredAnim = "spr_noelle_walk_down_lw";
            if (targetFrame.anim.indexOf("u") != -1) desiredAnim = "spr_noelle_walk_up_lw";
            else if (targetFrame.anim.indexOf("d") != -1) desiredAnim = "spr_noelle_walk_down_lw";
            else if (targetFrame.anim.indexOf("l") != -1) desiredAnim = "spr_noelle_walk_left_lw";
            else if (targetFrame.anim.indexOf("r") != -1) desiredAnim = "spr_noelle_walk_right_lw";

            if (curAnim != desiredAnim) {
                play(desiredAnim);
            }
        }
    }

    public function setDarkWorld(darkWorld:Bool):Void {
        // isDarkWorld = darkWorld;
        // reloadCEA("romfs:/assets/images/chars/noelle_dark.cea", "spr_noelle_d");
        // frame = 0;
        // timeLeft = 999999;
    }
}

#end
