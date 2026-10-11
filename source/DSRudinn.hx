package;

#if (!wiiu || !cafe)

import citro.object.CitroAnimate;
import citro.object.CitroObject;
import citro.CitroG;

enum RudinnState {
    WANDERING;
    CHASING;
    HIT;
}

class DSRudinn extends CitroAnimate
{
    public var target:CitroObject;
    public var state:RudinnState = WANDERING;

    public var wanderSpeed:Float = 40;
    public var chaseSpeed:Float = 90;
    
    public var detectionRange:Float = 120;
    public var loseRange:Float = 200;
    
    private var wanderTimer:Float = 0;
    private var wanderDirX:Float = 0;
    private var wanderDirY:Float = 0;
    
    public var isHit:Bool = false;

    public function new(x:Float, y:Float) {
        super("romfs:/assets/images/chars/Rudinn.cea", "spr_diamondm_idle");
        this.x = x;
        this.y = y;
        framerate = 12;
        looped = true;
    }

    override public function update():Bool {
        if (target == null || isHit) {
            return super.update();
        }

        var dx = target.x - x;
        var dy = target.y - y;
        var distance = Math.sqrt(dx * dx + dy * dy);

        switch (state) {
            case WANDERING:
                if (distance < detectionRange) {
                    state = CHASING;
                    play("spr_diamondm_idle"); 
                } else {
                    handleWandering();
                }

            case CHASING:
                if (distance > loseRange) {
                    state = WANDERING;
                    wanderTimer = 0;
                    play("spr_diamondm_idle");
                } else {
                    handleChasing(dx, dy, distance);
                }

            case HIT:
                break;
        }

        return super.update();
    }

    private function handleWandering() {
        wanderTimer -= CitroG.deltaTime / 1000.0;
        if (wanderTimer <= 0) {
            var angle = Math.random() * (Math.PI * 2);
            wanderDirX = Math.cos(angle);
            wanderDirY = Math.sin(angle);
            wanderTimer = 1.0 + Math.random() * 2.0;
        }

        x += wanderDirX * wanderSpeed * (CitroG.deltaTime / 1000.0);
        y += wanderDirY * wanderSpeed * (CitroG.deltaTime / 1000.0);
    }

    private function handleChasing(dx:Float, dy:Float, distance:Float) {
        if (distance > 0) {
            var vx = (dx / distance) * chaseSpeed;
            var vy = (dy / distance) * chaseSpeed;
            
            x += vx * (CitroG.deltaTime / 1000.0);
            y += vy * (CitroG.deltaTime / 1000.0);
        }
    }
    
    public function reset() {
        isHit = false;
        state = WANDERING;
        wanderTimer = 0;
        play("spr_diamondm_idle");
    }
}
#end
