package;

#if (!wiiu || !cafe)

import citro.object.CitroAnimate;
import citro.object.CitroSprite;
import citro.object.CitroCamera;
import citro.CitroG;
using StringTools;

class DSDarkWorldTransition extends CitroAnimate
{
    var player:DSPlayer;
    var door:DSDarkDoor;
    var camera:CitroCamera;
    var statePhase:Int = 0;
    var timer:Float = 0;
    
    var bgOverlay:CitroSprite;
    var lineSpawnTimer:Float = 0;
    
    var targetLandingY:Float;

    public var onComplete:Void->Void;

    public function new(player:DSPlayer, door:DSDarkDoor = null, camera:CitroCamera = null)
    {
        super("romfs:/assets/images/trans/kris_dark_trans.cea", "spr_krisu_run");

        this.x = player.x;
        this.y = player.y;
        this.player = player;
        this.door = door;
        this.camera = camera;

        this.targetLandingY = player.y + 2200;
        this.framerate = 8; 
        this.looped = true;

        player.visible = false;
        player.isBusy = true;

        if (this.camera != null) {
            this.camera.follow(this, true);
        }

        startTransition();
    }

    function startTransition()
    {
        statePhase = 1; 
        play("spr_krisu_run");
        acceleration.y = -50; 
    }

    override public function update():Bool
    {
        var elapsed:Float = CitroG.deltaTime / 1000.0;
        timer += elapsed;

        switch (statePhase)
        {
            case 0:
                y += 30 * elapsed;
                if (timer >= 0.25)
                {
                    statePhase = 1;
                    timer = 0;
                    play("spr_krisu_run");
                    acceleration.y = -200;
                }

            case 1:
                if (timer >= 0.35)
                {
                    if (door != null) {
                        door.setDoorState(DSDarkDoor.STATE_OPEN_FRAME);
                    }

                    framerate = 8;
                    play("spr_krisu_fall_lw");
                    statePhase = 2;
                    timer = 0;
                }

            case 2:
                if (timer >= 0.5)
                {
                    if (door != null) {
                        door.setDoorState(DSDarkDoor.STATE_DARK_VOID);
                    }

                    bgOverlay = new CitroSprite(0, 0);
                    bgOverlay.makeGraphic(CitroG.WIDTH * 4, CitroG.HEIGHT * 16, 0xFF000000);
                    
                    if (camera != null) {
                        camera.add(bgOverlay);
                    }
                    
                    framerate = 10;
                    play("spr_kris_fall_turnaround");
                    looped = false;
                    statePhase = 3;
                    timer = 0;
                }

            case 3:
                if (timer >= 0.4)
                {
                    framerate = 6;
                    looped = true;
                    play("spr_kris_fall_d_lw");
                }

                if (timer >= 1.8)
                {
                    statePhase = 4;
                    timer = 0;
                    framerate = 15;
                    play("spr_kris_fall_d_white");
                }

            case 4:
                if (timer >= 0.12)
                {
                    statePhase = 5;
                    timer = 0;
                    framerate = 6;
                    play("spr_kris_fall_d_dw");
                }

            case 5:
                if (timer >= 1.6)
                {
                    statePhase = 6;
                    timer = 0;
                    framerate = 15;
                    looped = false;
                    play("spr_kris_fall_smear");
                }

            case 6:
                if (timer >= 0.3)
                {
                    statePhase = 7;
                    timer = 0;
                    framerate = 12;
                    looped = true;
                    play("spr_kris_fall_ball");
                }

            case 7:
                y += 600 * elapsed;
                
                if (bgOverlay != null) {
                    bgOverlay.x = x - CitroG.WIDTH * 2;
                    bgOverlay.y = y - CitroG.HEIGHT * 8;
                }

                if (y >= targetLandingY) 
                {
                    y = targetLandingY;
                    framerate = 8;
                    looped = false;
                    play("spr_kris_dw_landed");
                    
                    statePhase = 8;
                    timer = 0;
                }

            case 8:
                if (finished)
                {
                    player.x = x;
                    player.y = y;
                    
                    player.setDarkWorld(true);
                    player.visible = true;
                    player.isBusy = false;

                    if (camera != null) {
                        camera.follow(player, true);
                    }

                    if (bgOverlay != null)
                        bgOverlay.destroy();

                    if (onComplete != null)
                        onComplete();

                    destroy();
                }
        }

        if (statePhase >= 3 && statePhase <= 7)
        {
            lineSpawnTimer += elapsed;
            if (lineSpawnTimer >= 0.035) 
            {
                lineSpawnTimer = 0;
                var line = new DSDarkTransitionLine(x, y + 200);
                if (camera != null) {
                    camera.add(line);
                }
            }
        }

        return super.update();
    }
}

#end