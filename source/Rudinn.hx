package;

import citro.object.CitroAnimate;

class Rudinn extends CitroAnimate
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
        if (movingRight)
        {
            x += (moveSpeed / 24);
            scale.x = -1;

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

            if (x <= startX)
            {
                x = startX;
                movingRight = true;
            }
        }
    }
}