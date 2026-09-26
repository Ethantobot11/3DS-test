package;

#if (!wiiu || !cafe)

import citro.object.CitroAnimate;
using StringTools;

class DSLacie extends CitroAnimate
{
    public var isFollowing:Bool = false;
    public var target:DSNoelle;
    public var trailDelay:Int = 18; 

    public function new(x:Float, y:Float)
    {
        super("romfs:/assets/images/chars/lacie_spritesheet_playable.cea", "walk_down");
        
        this.x = x;
        this.y = y;
        framerate = 6;
        looped = true;
    }

    override public function update():Bool
    {
        if (!isFollowing)
        {
            if (curAnim != "walk_down") {
                play("walk_down");
            }
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

            var desiredAnim = "walk_down";
            if (targetFrame.anim.indexOf("u") != -1) desiredAnim = "walk_up";
            else if (targetFrame.anim.indexOf("d") != -1) desiredAnim = "walk_down";
            else if (targetFrame.anim.indexOf("l") != -1) desiredAnim = "walk_left";
            else if (targetFrame.anim.indexOf("r") != -1) desiredAnim = "walk_right";

            if (curAnim != desiredAnim) {
                play(desiredAnim);
            }
        }
    }
}

#end