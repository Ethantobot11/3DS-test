package;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.object.CitroAnimate;
import haxe3ds.services.HID;
using StringTools;

typedef PositionFrame = {
    var x:Float;
    var y:Float;
    var anim:String;
}

class DSPlayer extends CitroAnimate
{
    public var moveSpeed:Float = 120;
    public var facingDir:String = "down";
    public var isBusy:Bool = false;
    public var isDarkWorld:Bool = false;
    public var charName:String = "kris";
    public var pathHistory:Array<PositionFrame> = [];
    
    private var lastPlayedFrame:Int = -1;

    public function new(x:Float, y:Float, darkWorld:Bool = false, char:String = "kris") {
        charName = char;
        isDarkWorld = darkWorld;
        
        super(ceaPath(), "");
        
        this.x = x;
        this.y = y;
        framerate = 6;
        looped = true;

        play(animFor("walk", facingDir));
        frame = 0;
        timeLeft = 999999;

        for (i in 0...25) {
            pathHistory.push({x: x, y: y, anim: curAnim});
        }
    }

    function ceaPath():String {
        if (charName == "lacie") return "romfs:/assets/images/chars/lacie_spritesheet_playable.cea";
        var suffix = isDarkWorld ? "_dark" : "";
        return 'romfs:/assets/images/chars/spr_kris${suffix}.cea';
    }

    function animFor(action:String, dir:String):String {
        if (charName == "lacie") {
            var hints = [action + "_" + dir, action + dir];
            var found = getAnimByHint(hints);
            if (found == "" && action != "walk") return animFor("walk", dir);
            if (found == "" && dir != "down") return animFor(action, "down");
            return found;
        }
        var suffix = isDarkWorld ? "_dark" : "";
        return switch (dir) {
            case "up":    'spr_krisu$suffix';
            case "left":  'spr_krisl$suffix';
            case "right": 'spr_krisr$suffix';
            default:      'spr_krisd$suffix';
        }
    }

    public function setDarkWorld(darkWorld:Bool):Void
    {
        if (isDarkWorld == darkWorld) return;
        isDarkWorld = darkWorld;
        if (charName == "lacie") return; 
        reloadCEA(ceaPath(), animFor("walk", facingDir));
        frame = 0;
        timeLeft = 999999;
    }

    override public function update():Bool {
        if (!isBusy) handleMovement();
        else { frame = 0; timeLeft = 999999; }

        var curAnimName = (curAnim != "") ? curAnim : animFor("walk", "down");
        pathHistory.unshift({x: x, y: y, anim: curAnimName});
        if (pathHistory.length > 100) pathHistory.pop();

        return super.update();
    }

    private function handleMovement()
    {
        var up:Bool = HID.keyHeld(HIDKey.UP);
        var down:Bool = HID.keyHeld(HIDKey.DOWN);
        var left:Bool = HID.keyHeld(HIDKey.LEFT);
        var right:Bool = HID.keyHeld(HIDKey.RIGHT);
        var run:Bool = HID.keyHeld(HIDKey.B);
    
        if (up && down) up = down = false;
        if (left && right) left = right = false;
    
        var vx:Float = 0;
        var vy:Float = 0;
        
        var action:String = "walk";
        if (charName == "lacie" && run) {
            action = "run";
        }
        
        var currentSpeed:Float = moveSpeed;
        var currentFramerate:Float = 6;
        if (action == "run") {
            currentSpeed = moveSpeed * 1.8; 
            currentFramerate = 12;        
        }
    
        if (up || down || left || right)
        {
            var desiredAnim = "";
    
            if (up) { vy = -currentSpeed; facingDir = "up"; desiredAnim = animFor(action, "up"); }
            else if (down) { vy = currentSpeed; facingDir = "down"; desiredAnim = animFor(action, "down"); }
    
            if (left) { vx = -currentSpeed; facingDir = "left"; desiredAnim = animFor(action, "left"); }
            else if (right) { vx = currentSpeed; facingDir = "right"; desiredAnim = animFor(action, "right"); }
    
            var dt = CitroG.deltaTime / 1000; 
            x += vx * dt;
            y += vy * dt;
            
            framerate = currentFramerate;
    
            if (curAnim != desiredAnim) {
                play(desiredAnim);
                lastPlayedFrame = -1;
            }
    
            if (Std.int(frame) != lastPlayedFrame) {
                lastPlayedFrame = Std.int(frame);
            
                if (lastPlayedFrame == 0) {
                    SoundPlayer.playSound('romfs:/assets/sounds/snd_step1.cwav');
                }
            }
        }
        else
        {
            var idleAction = (charName == "lacie") ? "idle" : "walk";
            var currentStanding = animFor(idleAction, facingDir);
            
            if (curAnim != currentStanding) {
                play(currentStanding);
            }
    
            timeLeft = 999999;
            frame = 0;
            lastPlayedFrame = -1;
            framerate = 6;
        }
    }
}
#end
