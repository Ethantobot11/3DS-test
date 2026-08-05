package;

import citro.CitroG;
import citro.object.CitroAnimate;
import haxe3ds.services.HID;
using StringTools;

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

    public function new(x:Float, y:Float, darkWorld:Bool = false)
    {
        isDarkWorld = darkWorld;
        var ceaPath = isDarkWorld ? "romfs:/assets/images/chars/Kris_Dark.cea" : "romfs:/assets/images/chars/Kris_Light.cea";
        
        super(ceaPath, "idle_down");
        
        this.x = x;
        this.y = y;
    }

    public function setDarkWorld(darkWorld:Bool):Void
    {
        if (isDarkWorld == darkWorld) return;
        isDarkWorld = darkWorld;

        if (sprites != null) {
            for (key => header in sprites) {
                if (header != null && header.sprite != null) {
                    header.sprite.destroy();
                }
            }
            sprites.clear();
        }

        var ceaPath = isDarkWorld ? "romfs:/assets/images/chars/Kris_Dark.cea" : "romfs:/assets/images/chars/Kris_Light.cea";
        var file:String = sys.io.File.getContent(ceaPath);
        var dir:String = ceaPath.substr(0, ceaPath.lastIndexOf("/"));
        
        if (file != "") {
            var i:Int = 0;
            var animationList:Array<String> = [];
            for (line in file.split("\n")) {
                var row:Array<String> = line.split("?");
                if (row.length < 3) break;
                row[3] = row[3].trim();

                if (!animationList.join(" ").contains(row[3])) {
                    animationList.push(row[3]);
                    i = -1;
                }
                i++;

                var n:String = '${row[3]}-$i';
                var sprite:citro.object.CitroSprite = new citro.object.CitroSprite();
                if (!sprite.loadGraphic('$dir/${row[0]}')) {
                    i--;
                    sprite.destroy();
                    continue;
                }

                var resultParse:Array<Null<Float>> = [for (idx in 1...3) Std.parseFloat(row[idx])];
                sprites.set(n, {
                    frameX: resultParse[0] == null ? 0 : resultParse[0],
                    frameY: resultParse[1] == null ? 0 : resultParse[1],
                    sprite: sprite
                });
            }
        }

        play("idle_down");
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
        var up:Bool = HID.keyHeld(HIDKey.UP);
        var down:Bool = HID.keyHeld(HIDKey.DOWN);
        var left:Bool = HID.keyHeld(HIDKey.LEFT);
        var right:Bool = HID.keyHeld(HIDKey.RIGHT);

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