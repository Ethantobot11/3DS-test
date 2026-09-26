package;

#if (!wiiu || !cafe)

import citro.object.CitroObject;
import citro.object.CitroSprite;
import citro.object.CitroCamera;
import citro.CitroG;
using StringTools;

class DSDarkWorldTransition extends CitroObject
{
    var player:DSPlayer;
    var door:DSDarkDoor;
    var camera:CitroCamera;
    var statePhase:Int = 0;
    var timer:Float = 0;
    
    var bgOverlay:CitroSprite;
    var lineSpawnTimer:Float = 0;
    
    var targetLandingY:Float;
    var flyUpSpeed:Float = -150;
    var fallSpeed:Float = 0;

    public var onComplete:Void->Void;

    public function new(player:DSPlayer, door:DSDarkDoor = null, camera:CitroCamera = null)
    {
        super();
        this.player = player;
        this.door = door;
        this.camera = camera;

        this.targetLandingY = player.y + 2200;

        player.isBusy = true;

        player.reloadCEA("romfs:/assets/images/trans/kris_dark_trans.cea", "spr_krisu_run");
        player.framerate = 8;
        player.looped = true;
        player.play("spr_krisu_run");

        statePhase = 0; 
    }

    override public function update():Bool
    {
        var elapsed:Float = CitroG.deltaTime / 1000.0;
        timer += elapsed;

        if (statePhase == 0) {
            player.y += flyUpSpeed * elapsed;
        } else if (statePhase == 6) {
            player.y += fallSpeed * elapsed;
        }

        switch (statePhase)
        {
            case 0:
                if (timer >= 0.35)
                {
                    if (door != null) door.setDoorState(DSDarkDoor.STATE_OPEN_FRAME);
                    player.framerate = 8;
                    player.play("spr_krisu_fall_lw");
                    statePhase = 1;
                    timer = 0;
                }

            case 1:
                if (timer >= 0.5)
                {
                    if (door != null) door.setDoorState(DSDarkDoor.STATE_DARK_VOID);

                    bgOverlay = new CitroSprite(0, 0);
                    bgOverlay.makeGraphic(CitroG.WIDTH * 4, CitroG.HEIGHT * 16, 0xFF000000);
                    if (camera != null) camera.add(bgOverlay);
                    
                    player.framerate = 10;
                    player.play("spr_kris_fall_turnaround");
                    player.looped = false;
                    statePhase = 2;
                    timer = 0;
                }

            case 2:
                if (timer >= 0.4)
                {
                    player.framerate = 6;
                    player.looped = true;
                    player.play("spr_kris_fall_d_lw");
                }

                if (timer >= 1.8)
                {
                    statePhase = 3;
                    timer = 0;
                    player.framerate = 15;
                    player.play("spr_kris_fall_d_white");
                }

            case 3:
                if (timer >= 0.12)
                {
                    statePhase = 4;
                    timer = 0;
                    player.framerate = 6;
                    player.play("spr_kris_fall_d_dw");
                }

            case 4:
                if (timer >= 1.6)
                {
                    statePhase = 5;
                    timer = 0;
                    player.framerate = 15;
                    player.looped = false;
                    player.play("spr_kris_fall_smear");
                }

            case 5:
                if (timer >= 0.3)
                {
                    statePhase = 6;
                    timer = 0;
                    player.framerate = 12;
                    player.looped = true;
                    player.play("spr_kris_fall_ball");
                    fallSpeed = 600;
                }

            case 6:
                if (bgOverlay != null) {
                    bgOverlay.x = player.x - CitroG.WIDTH * 2;
                    bgOverlay.y = player.y - CitroG.HEIGHT * 8;
                }

                if (player.y >= targetLandingY) 
                {
                    player.y = targetLandingY;
                    player.framerate = 8;
                    player.looped = false;
                    player.play("spr_kris_dw_landed");
                    
                    statePhase = 7;
                    timer = 0;
                }

            case 7:
                if (player.finished)
                {
                    player.setDarkWorld(true);
                    player.isBusy = false;

                    if (camera != null) camera.follow(player, true);

                    if (bgOverlay != null) bgOverlay.destroy();

                    if (onComplete != null) onComplete();

                    destroy();
                }
        }

        if (statePhase >= 2 && statePhase <= 6)
        {
            lineSpawnTimer += elapsed;
            if (lineSpawnTimer >= 0.035) 
            {
                lineSpawnTimer = 0;
                var line = new DSDarkTransitionLine(player.x, player.y + 200);
                if (camera != null) camera.add(line);
            }
        }

        return super.update();
    }
}
#end