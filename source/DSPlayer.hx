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
    public var pathHistory:Array<PositionFrame> = [];
    
    private var lastPlayedFrame:Int = -1;

    public function new(x:Float, y:Float, darkWorld:Bool = false) {
        isDarkWorld = darkWorld;
        var suffix = isDarkWorld ? "_dark" : "";
        
        super('romfs:/assets/images/chars/spr_kris${suffix}.cea', 'spr_krisd$suffix');
        
        this.x = x;
        this.y = y;
        framerate = 6;
        looped = true;

        var initialAnim = isDarkWorld ? "spr_krisd_dark" : "spr_krisd";
        for (i in 0...25) {
            pathHistory.push({x: x, y: y, anim: initialAnim});
        }
    }

    public function setDarkWorld(darkWorld:Bool):Void
    {
        if (isDarkWorld == darkWorld) return;
        isDarkWorld = darkWorld;
        var suffix = isDarkWorld ? "_dark" : "";
        
        reloadCEA('romfs:/assets/images/chars/spr_kris${suffix}.cea', 'spr_krisd$suffix');
    }

    override public function update():Bool {
        if (!isBusy) handleMovement();
        else frame = 0;

        var curAnimName = (curAnim != "") ? curAnim : (isDarkWorld ? "spr_krisd_dark" : "spr_krisd");
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
    
        if (up && down) up = down = false;
        if (left && right) left = right = false;
    
        var vx:Float = 0;
        var vy:Float = 0;
        var suffix = isDarkWorld ? "_dark" : "";
    
        if (up || down || left || right)
        {
            var desiredAnim = "";
    
            if (up) { vy = -moveSpeed; facingDir = "up"; desiredAnim = 'spr_krisu$suffix'; }
            else if (down) { vy = moveSpeed; facingDir = "down"; desiredAnim = 'spr_krisd$suffix'; }
    
            if (left) { vx = -moveSpeed; facingDir = "left"; desiredAnim = 'spr_krisl$suffix'; }
            else if (right) { vx = moveSpeed; facingDir = "right"; desiredAnim = 'spr_krisr$suffix'; }
    
            var dt = CitroG.deltaTime / 1000; 
            x += vx * dt;
            y += vy * dt;
    
            if (curAnim != desiredAnim) {
                play(desiredAnim);
            }
    
            if (Std.int(frame) != lastPlayedFrame) {
                lastPlayedFrame = Std.int(frame);
                if (lastPlayedFrame == 1 || lastPlayedFrame == 4) {
                    SoundPlayer.playSound('romfs:/assets/sounds/snd_step1.cwav');
                } else if (lastPlayedFrame == 2 || lastPlayedFrame == 5) {
                    SoundPlayer.playSound('romfs:/assets/sounds/snd_step2.cwav');
                }
            }
        }
        else
        {
            var currentStanding = isDarkWorld ? "spr_krisd_dark" : "spr_krisd";
            if (facingDir == "up") currentStanding = isDarkWorld ? "spr_krisu_dark" : "spr_krisu";
            else if (facingDir == "left") currentStanding = isDarkWorld ? "spr_krisl_dark" : "spr_krisl";
            else if (facingDir == "right") currentStanding = isDarkWorld ? "spr_krisr_dark" : "spr_krisr";
            
            if (curAnim != currentStanding) {
                play(currentStanding);
            }
    
            frame = 0;
            lastPlayedFrame = -1;
        }
    }
}

#end