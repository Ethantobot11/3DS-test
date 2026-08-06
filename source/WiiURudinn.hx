package objects;

import leafy.objects.LfSprite;

class WiiURudinn extends LfSprite
{
    public var moveSpeed:Float = 40;
    public var startX:Float;
    public var patrolDistance:Float = 100;
    public var movingRight:Bool = true;

    public function new(x:Float, y:Float, patrolDistance:Float = 100)
    {
        super(Std.int(x), Std.int(y));

        this.startX = x;
        this.patrolDistance = patrolDistance;

        loadGraphicFromXml("assets/images/chars/Rudinn.png", "assets/images/chars/Rudinn.xml");

        addAnimationByPrefix("spr_diamondm_idle", "spr_diamondm_idle_", 6, true);
        addAnimationByPrefix("spr_diamondm_walk", "spr_diamondm_walk_", 6, true);

        playAnimation("spr_diamondm_idle");
        immovable = true;
    }

    override public function update(elapsed:Float):Void
    {
        handlePatrol(elapsed);
        super.update(elapsed);
    }

    function handlePatrol(elapsed:Float):Void
    {
        var walkAnim = "spr_diamondm_walk"; 
        var idleAnim = "spr_diamondm_idle";

        if (movingRight)
        {
            x += moveSpeed * elapsed;
            scale = {x: -1, y: 1};
            
            playAnimation(walkAnim);

            if (x >= startX + patrolDistance)
            {
                x = startX + patrolDistance;
                movingRight = false;
            }
        }
        else
        {
            x -= moveSpeed * elapsed;
            scale = {x: 1, y: 1};

            playAnimation(walkAnim);

            if (x <= startX)
            {
                x = startX;
                movingRight = true;
            }
        }

        sdlRect.x = Std.int(x);
        sdlRect.y = Std.int(y);
    }
}