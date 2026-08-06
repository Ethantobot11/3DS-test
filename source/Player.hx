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
        
        // Pass a dummy or initial CEA file to super, then load our split files manually
        super("romfs:/assets/images/chars/spr_krisd_dark.cea", "spr_krisd_dark");
        
        this.x = x;
        this.y = y;
        
        loadAllAnimations();
        play("spr_kris_down"); // Initial play call
    }

    private function loadAllAnimations():Void
    {
        if (sprites != null) {
            for (key => header in sprites) {
                if (header != null && header.sprite != null) {
                    header.sprite.destroy();
                }
            }
            sprites.clear();
        }

        // Define the prefix based on Dark World vs Light World
        var prefix = isDarkWorld ? "kris" : "kris"; // adjust if light world files have different naming
        var suffix = isDarkWorld ? "_dark" : "";

        // List of all directional CEA files we generated for Kris
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
                var i:Int = 0;
                var currentAnimBase:String = "";
                
                for (line in file.split("\n")) {
                    if (line.trim() == "") continue;
                    var row:Array<String> = line.split("?");
                    if (row.length < 3) break;
                    row[3] = row[3].trim();

                    var lastDash = row[3].lastIndexOf("-");
                    var animName = row[3].substring(0, lastDash);
                    var frameIdx = Std.parseInt(row[3].substring(lastDash + 1));

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
        loadAllAnimations();
        play("spr_krisd_dark-0");
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
            var curAnimName = (curAnim != "") ? curAnim : "spr_krisd_dark";
            pathHistory.unshift({x: x, y: y, anim: curAnimName});

            if (pathHistory.length > 100)
            {
                pathHistory.pop();
            }
        }
        else
        {
            if (facingDir == "up") play("spr_krisu_dark");
            else if (facingDir == "down") play("spr_krisd_dark");
            else if (facingDir == "left") play("spr_krisl_dark");
            else if (facingDir == "right") play("spr_krisr_dark");
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

            if (up) play("spr_krisu_dark");
            else if (down) play("spr_krisd_dark");
            else if (left) play("spr_krisl_dark");
            else if (right) play("spr_krisr_dark");
        }
        else
        {
            if (facingDir == "up") play("spr_krisu_dark");
            else if (facingDir == "down") play("spr_krisd_dark");
            else if (facingDir == "left") play("spr_krisl_dark");
            else if (facingDir == "right") play("spr_krisr_dark");
        }
    }
}