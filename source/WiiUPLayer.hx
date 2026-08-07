package;

import leafy.objects.LfSprite;
import leafy.gamepad.LfGamepad;
import leafy.backend.LeafyDebug;

typedef PositionFrame = {
    var x:Float;
    var y:Float;
    var anim:String;
}

class WiiUPlayer extends LfSprite
{
    public var moveSpeed:Float = 120;
    public var facingDir:String = "down";
    public var isBusy:Bool = false;
    public var isDarkWorld:Bool = false;
    public var pathHistory:Array<PositionFrame> = [];

    private var gamepad:LfGamepad;

    public function new(x:Float, y:Float)
    {
        super(Std.int(x), Std.int(y));
        gamepad = new LfGamepad();

        loadLightWorld();
    }

    public function loadLightWorld():Void
    {
        isDarkWorld = false;
        
        loadGraphicFromXml("assets/images/chars/Kris_Light.png", "assets/images/chars/Kris_Light.xml");

        addAnimationByPrefix("walk_down", "spr_krisd_", 6, true);
        addAnimationByPrefix("walk_left", "spr_krisl_", 6, true);
        addAnimationByPrefix("walk_right", "spr_krisr_", 6, true);
        addAnimationByPrefix("walk_up", "spr_krisu_", 6, true);

        addAnimationByPrefix("idle_down", "spr_krisd_00000", 0, false);
        addAnimationByPrefix("idle_left", "spr_krisl_00000", 0, false);
        addAnimationByPrefix("idle_right", "spr_krisr_00000", 0, false);
        addAnimationByPrefix("idle_up", "spr_krisu_00000", 0, false);

        playAnimation("idle_down");
    }

    public function loadDarkWorld():Void
    {
        isDarkWorld = true;
        
        loadGraphicFromXml("assets/images/chars/Kris_Dark.png", "assets/images/chars/Kris_Dark.xml");

        addAnimationByPrefix("walk_down", "spr_krisd_dark_", 6, true);
        addAnimationByPrefix("walk_left", "spr_krisl_dark_", 6, true);
        addAnimationByPrefix("walk_right", "spr_krisr_dark_", 6, true);
        addAnimationByPrefix("walk_up", "spr_krisu_dark_", 6, true);

        addAnimationByPrefix("idle_down", "spr_krisd_dark_00000", 0, false);
        addAnimationByPrefix("idle_left", "spr_krisl_dark_00000", 0, false);
        addAnimationByPrefix("idle_right", "spr_krisr_dark_00000", 0, false);
        addAnimationByPrefix("idle_up", "spr_krisu_dark_00000", 0, false);

        playAnimation("idle_down");
    }

    override public function update(elapsed:Float):Void
    {
        var oldX = x;
        var oldY = y;

        if (!isBusy)
            handleMovement();
        else
            velocity = {x: 0, y: 0};

        super.update(elapsed);

        if (x != oldX || y != oldY)
        {
            var curAnimName = (currentAnimation != null) ? currentAnimation.name : "walk_down";
            pathHistory.unshift({x: x, y: y, anim: curAnimName});

            if (pathHistory.length > 100)
            {
                pathHistory.pop();
            }
        }
        else
        {
            if (facingDir == "up") playAnimation("idle_up");
            else if (facingDir == "down") playAnimation("idle_down");
            else if (facingDir == "left") playAnimation("idle_left");
            else if (facingDir == "right") playAnimation("idle_right");
        }
    }

    private function handleMovement():Void
    {
        var up:Bool = false;
        var down:Bool = false;
        var left:Bool = false;
        var right:Bool = false;

        if (gamepad.pressed(BUTTON_UP) || gamepad.getLeftStick().y < -0.3) up = true;
        if (gamepad.pressed(BUTTON_DOWN) || gamepad.getLeftStick().y > 0.3) down = true;
        if (gamepad.pressed(BUTTON_LEFT) || gamepad.getLeftStick().x < -0.3) left = true;
        if (gamepad.pressed(BUTTON_RIGHT) || gamepad.getLeftStick().x > 0.3) right = true;

        if (up && down) up = down = false;
        if (left && right) left = right = false;

        velocity = {x: 0, y: 0};

        if (up || down || left || right)
        {
            if (up) { velocity.y = -moveSpeed; facingDir = "up"; }
            else if (down) { velocity.y = moveSpeed; facingDir = "down"; }

            if (left) { velocity.x = -moveSpeed; facingDir = "left"; }
            else if (right) { velocity.x = moveSpeed; facingDir = "right"; }

            if (up) playAnimation("walk_up");
            else if (down) playAnimation("walk_down");
            else if (left) playAnimation("walk_left");
            else if (right) playAnimation("walk_right");
        }
        else
        {
            if (facingDir == "up") playAnimation("idle_up");
            else if (facingDir == "down") playAnimation("idle_down");
            else if (facingDir == "left") playAnimation("idle_left");
            else if (facingDir == "right") playAnimation("idle_right");
        }
    }
}