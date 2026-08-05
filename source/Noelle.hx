package;

import citro.object.CitroAnimate;

class Noelle extends CitroAnimate
{
    public var isFollowing:Bool = false;
    public var target:Player;
    
    public var trailDelay:Int = 18; 

    public function new(x:Float, y:Float)
    {
        super("romfs:/assets/images/chars/noelle_light.cea", "spr_noelle_walk_down_lw");
        
        this.x = x;
        this.y = y;
        framerate = 6;
        looped = true;

        play("spr_noelle_walk_down_lw");
    }

    override public function update():Bool
    {
        if (isFollowing && target != null)
        {
            followPathTrail();
        }
        
        return super.update();
    }

    private function followPathTrail()
    {
        if (target.pathHistory.length >= trailDelay)
        {
            var targetFrame = target.pathHistory[trailDelay - 1];

            if (x != targetFrame.x || y != targetFrame.y)
            {
                x = targetFrame.x;
                y = targetFrame.y;

                if (targetFrame.anim.indexOf("up") != -1) play("spr_noelle_walk_up_lw");
                else if (targetFrame.anim.indexOf("down") != -1) play("spr_noelle_walk_down_lw");
                else if (targetFrame.anim.indexOf("left") != -1) play("spr_noelle_walk_left_lw");
                else if (targetFrame.anim.indexOf("right") != -1) play("spr_noelle_walk_right_lw");
            }
        }

        if (target.acceleration.x == 0 && target.acceleration.y == 0)
        {
            if (curAnim != "")
            {
                if (curAnim.indexOf("up") != -1) play("spr_noelle_walk_up_lw");
                else if (curAnim.indexOf("down") != -1) play("spr_noelle_walk_down_lw");
                else if (curAnim.indexOf("left") != -1) play("spr_noelle_walk_left_lw");
                else if (curAnim.indexOf("right") != -1) play("spr_noelle_walk_right_lw");
            }
        }
    }
}