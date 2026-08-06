package;

import citro.object.CitroAnimate;

class DSRudinn extends CitroAnimate
{
    public var moveSpeed:Float = 40;
    public var startX:Float;
    public var patrolDistance:Float = 100;
    public var movingRight:Bool = true;

    public function new(x:Float, y:Float, patrolDistance:Float = 100)
    {
        super("romfs:/assets/images/chars/Rudinn.cea", "spr_diamondm_idle");

        this.startX = x;
        this.patrolDistance = patrolDistance;
        this.x = x;
        this.y = y;
        
        framerate = 6;
        looped = true;

        play("spr_diamondm_idle");
    }

    override public function update():Bool
    {
        handlePatrol();
        return super.update();
    }

    function handlePatrol()
    {
        var walkAnim = "spr_diamondm_walk"; 
        var idleAnim = "spr_diamondm_idle";

        if (movingRight)
        {
            x += (moveSpeed / 24);
            scale.x = -1;
            
            play(walkAnim);

            if (x >= startX + patrolDistance)
            {
                x = startX + patrolDistance;
                movingRight = false;
            }
        }
        else
        {
            x -= (moveSpeed / 24);
            scale.x = 1;

            play(walkAnim);

            if (x <= startX)
            {
                x = startX;
                movingRight = true;
            }
        }
    }
}