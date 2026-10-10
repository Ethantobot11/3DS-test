package;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.object.CitroAnimate;
import citro.object.CitroObject;
import citro.math.CitroMath;
using StringTools;

class DSSusie extends CitroAnimate
{
    public var target:CitroObject;
    public var isFollowing:Bool = false;
    public var isDarkWorld:Bool = false;
    public var moveSpeed:Float = 80;
    public var facingDir:String = "down";
    public var isBusy:Bool = false;

    private var followDelay:Float = 0.15;
    private var followTimer:Float = 0;

    public function new(x:Float, y:Float, darkWorld:Bool = false) {
        isDarkWorld = darkWorld;
        super(ceaPath(), "");
        this.x = x;
        this.y = y;
        framerate = 6;
        looped = true;
        play(animFor("walk", facingDir));
    }

    function ceaPath():String {
        var suffix = isDarkWorld ? "_dark" : "";
        return 'romfs:/assets/images/chars/spr_susie${suffix}.cea';
    }

    function animFor(action:String, dir:String):String {
        var suffix = isDarkWorld ? "_dark" : "";
        var dirChar = switch (dir) {
            case "up": "u";
            case "left": "l";
            case "right": "r";
            default: "d";
        };
        return 'spr_susie${dirChar}${suffix}';
    }

    public function setDarkWorld(darkWorld:Bool):Void {
        if (isDarkWorld == darkWorld) return;
        isDarkWorld = darkWorld;
        reloadCEA(ceaPath(), animFor("walk", facingDir));
        frame = 0;
        timeLeft = 999999;
    }

    override public function update():Bool {
        if (!isBusy && isFollowing && target != null) {
            handleFollow();
        } else if (!isBusy && !isFollowing) {
            frame = 0;
            timeLeft = 999999;
        }
        return super.update();
    }

    private function handleFollow() {
        var dx = target.x - x;
        var dy = target.y - y;
        var distance = Math.sqrt(dx * dx + dy * dy);

        if (distance > 45) {
            followTimer += CitroG.deltaTime / 1000.0;
            if (followTimer >= followDelay) {
                var vx:Float = 0;
                var vy:Float = 0;
                var desiredAnim = "";

                if (Math.abs(dx) > Math.abs(dy)) {
                    if (dx > 0) { vx = moveSpeed; facingDir = "right"; desiredAnim = animFor("walk", "right"); }
                    else { vx = -moveSpeed; facingDir = "left"; desiredAnim = animFor("walk", "left"); }
                } else {
                    if (dy > 0) { vy = moveSpeed; facingDir = "down"; desiredAnim = animFor("walk", "down"); }
                    else { vy = -moveSpeed; facingDir = "up"; desiredAnim = animFor("walk", "up"); }
                }

                var dt = CitroG.deltaTime / 1000.0;
                x += vx * dt;
                y += vy * dt;

                if (curAnim != desiredAnim) {
                    play(desiredAnim);
                }
            }
        } else {
            followTimer = 0;
            var idleAnim = animFor("walk", facingDir);
            if (curAnim != idleAnim) {
                play(idleAnim);
                frame = 0;
                timeLeft = 999999;
            }
        }
    }
}
#end
