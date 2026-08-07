package;

import leafy.objects.LfSprite;

class WiiUNoelle extends LfSprite
{
    public var isFollowing:Bool = false;
    public var target:WiiUPlayer;
    
    public var trailDelay:Int = 18; 

    public function new(x:Float, y:Float)
    {
        super(Std.int(x), Std.int(y));

        loadGraphicFromXml("assets/images/chars/noelle_light.png", "assets/images/chars/noelle_light.xml");

        addAnimationByPrefix("walk_down", "spr_noelle_walk_down_lw_", 6, true);
        addAnimationByPrefix("walk_up", "spr_noelle_walk_up_lw_", 6, true);
        addAnimationByPrefix("walk_left", "spr_noelle_walk_left_lw_", 6, true);
        addAnimationByPrefix("walk_right", "spr_noelle_walk_right_lw_", 6, true);

        addAnimationByPrefix("idle_down", "spr_noelle_walk_down_lw_00000", 0, false);
        addAnimationByPrefix("idle_up", "spr_noelle_walk_up_lw_00000", 0, false);
        addAnimationByPrefix("idle_left", "spr_noelle_walk_left_lw_00000", 0, false);
        addAnimationByPrefix("idle_right", "spr_noelle_walk_right_lw_00000", 0, false);

        playAnimation("idle_down");

        immovable = true;
    }

    override public function update(elapsed:Float):Void
    {
        if (isFollowing && target != null)
        {
            followPathTrail();
        }
        super.update(elapsed);
    }

    private function followPathTrail():Void
    {
        if (target.pathHistory.length >= trailDelay)
        {
            var targetFrame = target.pathHistory[trailDelay - 1];

            if (x != targetFrame.x || y != targetFrame.y)
            {
                x = Std.int(targetFrame.x);
                y = Std.int(targetFrame.y);

                sdlRect.x = Std.int(x);
                sdlRect.y = Std.int(y);

                if (targetFrame.anim.indexOf("up") != -1) playAnimation("walk_up");
                else if (targetFrame.anim.indexOf("down") != -1) playAnimation("walk_down");
                else if (targetFrame.anim.indexOf("left") != -1) playAnimation("walk_left");
                else if (targetFrame.anim.indexOf("right") != -1) playAnimation("walk_right");
            }
        }

        if (target.velocity.x == 0 && target.velocity.y == 0)
        {
            if (currentAnimation != null)
            {
                var curName = currentAnimation.name;
                if (curName.indexOf("up") != -1) playAnimation("idle_up");
                else if (curName.indexOf("down") != -1) playAnimation("idle_down");
                else if (curName.indexOf("left") != -1) playAnimation("idle_left");
                else if (curName.indexOf("right") != -1) playAnimation("idle_right");
            }
        }
    }
}