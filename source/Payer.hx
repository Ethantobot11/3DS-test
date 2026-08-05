package;

import citro.CitroG;
import citro.object.CitroAnimate;
import haxe3ds.services.HID;

typedef PositionFrame = {
    var x:Float;
    var y:Float;
    var anim:String;
}

class Player extends CitroAnimate
{
    public var moveSpeed:Float = 120;
    public var facingDir:String = "down";
    public var isBusy:Bool = false;
    public var isDarkWorld:Bool = false;
    public var pathHistory:Array<PositionFrame> = [];

    public function new(x:Float, y:Float)
    {
        super("romfs:/assets/images/chars/Kris_Light.cea", "idle_down");
        this.x = x;
        this.y = y;

        loadLightWorld();
    }

    public function loadLightWorld():Void
    {
        super("romfs:/assets/images/chars/Kris_Light.cea", "idle_down");
        isDarkWorld = false;
    }

    public function loadDarkWorld():Void
    {
        super("romfs:/assets/images/chars/Kris_Dark.cea", "idle_down");
        isDarkWorld = true;
    }

    public function updatePlayer(delta:Float):Bool
    {
        var oldX = x;
        var oldY = y;

        if (!isBusy)
            handleMovement();

        var result = super.update();

        if (x != oldX || y != oldY)
        {
            var curAnimName = (curAnim != "") ? curAnim : "walk_down";
            pathHistory.unshift({x: x, y: y, anim: curAnimName});

            if (pathHistory.length > 100)
            {
                pathHistory.pop();
            }
        }
        else
        {
            if (facingDir == "up") play("idle_up");
            else if (facingDir == "down") play("idle_down");
            else if (facingDir == "left") play("idle_left");
            else if (facingDir == "right") play("idle_right");
        }

        return result;
    }

    private function handleMovement()
    {
        var up:Bool = HID.keyHeld(HIDKey.DUP) || HID.keyHeld(HIDKey.CPAD_UP);
        var down:Bool = HID.keyHeld(HIDKey.DDOWN) || HID.keyHeld(HIDKey.CPAD_DOWN);
        var left:Bool = HID.keyHeld(HIDKey.DLEFT) || HID.keyHeld(HIDKey.CPAD_LEFT);
        var right:Bool = HID.keyHeld(HIDKey.DRIGHT) || HID.keyHeld(HIDKey.CPAD_RIGHT);

        if (up && down) up = down = false;
        if (left && right) left = right = false;

        var vx:Float = 0;
        var vy:Float = 0;

        if (up || down || left || right)
        {
            if (up) { vy = -moveSpeed; facingDir = "up"; }
            else if (down) { vy = moveSpeed; facingDir = "down"; }

            if (left) { vx = -moveSpeed; facingDir = "left"; }
            else if (right) { vx = moveSpeed; facingDir = "right"; }

            var dt = CitroG.deltaTime / 1000; 
            x += vx * dt;
            y += vy * dt;

            if (up) play("walk_up");
            else if (down) play("walk_down");
            else if (left) play("walk_left");
            else if (right) play("walk_right");
        }
        else
        {
            if (facingDir == "up") play("idle_up");
            else if (facingDir == "down") play("idle_down");
            else if (facingDir == "left") play("idle_left");
            else if (facingDir == "right") play("idle_right");
        }
    }
}