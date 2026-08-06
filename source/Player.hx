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
        
        super("romfs:/assets/images/chars/spr_krisd_dark.cea", "spr_krisd_dark");
        
        this.x = x;
        this.y = y;
        framerate = 6;
        looped = true;

        loadPlayerAnimations();
        play(isDarkWorld ? "spr_krisd_dark" : "spr_krisd");
    }

    private function loadPlayerAnimations():Void
    {
        var suffix = isDarkWorld ? "_dark" : "";

        var ceaFiles = [
            'spr_krisd${suffix}.cea',
            'spr_krisl${suffix}.cea',
            'spr_krisr${suffix}.cea',
            'spr_krisu${suffix}.cea'
        ];

        for (ceaFile in ceaFiles) {
            var ceaPath = 'romfs:/assets/images/chars/$ceaFile';
            if (!sys.FileSystem.exists(ceaPath)) continue;

            var file:String = sys.io.File.getContent(ceaPath);
            var dir:String = "romfs:/assets/images/chars";

            if (file != "") {
                for (line in file.split("\n")) {
                    if (line.trim() == "") continue;
                    var row:Array<String> = line.split("?");
                    if (row.length < 3) break;
                    row[3] = row[3].trim();

                    var sprite:citro.object.CitroSprite = new citro.object.CitroSprite();
                    if (!sprite.loadGraphic('$dir/${row[0]}')) {
                        sprite.destroy();
                        continue;
                    }

                    var resultParse:Array<Null<Float>> = [for (idx in 1...3) Std.parseFloat(row[idx])];
                    sprites.set(row[3], {
                        frameX: resultParse[0] == null ? 0 : resultParse[0],
                        frameY: resultParse[1] == null ? 0 : resultParse[1],
                        sprite: sprite
                    });
                }
            }
        }
    }

    public function setDarkWorld(darkWorld:Bool):Void
    {
        if (isDarkWorld == darkWorld) return;
        isDarkWorld = darkWorld;
        loadPlayerAnimations();
        play(isDarkWorld ? "spr_krisd_dark" : "spr_krisd");
    }

    override public function update():Bool
    {
        var oldX = x;
        var oldY = y;

        if (!isBusy)
        {
            handleMovement();
        }
        else
        {
            frame = 0;
        }

        if (x != oldX || y != oldY)
        {
            var curAnimName = (curAnim != "") ? curAnim : (isDarkWorld ? "spr_krisd_dark" : "spr_krisd");
            pathHistory.unshift({x: x, y: y, anim: curAnimName});

            if (pathHistory.length > 100)
            {
                pathHistory.pop();
            }
        }

        return super.update();
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
        var suffix = isDarkWorld ? "_dark" : "";

        if (up || down || left || right)
        {
            if (up) { vy = -moveSpeed; facingDir = "up"; }
            else if (down) { vy = moveSpeed; facingDir = "down"; }

            if (left) { vx = -moveSpeed; facingDir = "left"; }
            else if (right) { vx = moveSpeed; facingDir = "right"; }

            var dt = CitroG.deltaTime / 1000; 
            x += vx * dt;
            y += vy * dt;

            if (up) play('spr_krisu$suffix');
            else if (down) play('spr_krisd$suffix');
            else if (left) play('spr_krisl$suffix');
            else if (right) play('spr_krisr$suffix');
        }
        else
        {
            frame = 0;
        }
    }
}