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
    var bgOverlayCreated:Bool = false;
    var lineSpawnTimer:Float = 0;
    
    var startX:Float = 0;
    var startY:Float = 0;
    var swayBaseX:Float = 0;
    var targetLandingY:Float;
    var fallSpeed:Float = 0;

    var squareSoundCount:Int = 0;
    var squareSoundTimer:Float = 0;
    var flipPlayed:Bool = false;
    var himPlayed:Bool = false;

    public var onComplete:Void->Void;

    public function new(player:DSPlayer, door:DSDarkDoor = null, camera:CitroCamera = null)
    {
        super();
        this.player = player;
        this.door = door;
        this.camera = camera;

        startX = player.x;
        startY = player.y;
        swayBaseX = player.x;
        this.targetLandingY = startY + 2200;

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

        switch (statePhase)
        {
            case 0:
                player.y -= 72 * elapsed;
                if (timer >= 0.5)
                {
                    if (door != null) door.setDoorState(DSDarkDoor.STATE_OPEN_FRAME);
                    SoundPlayer.playSound('romfs:/assets/sounds/snd_locker.cwav');
                    statePhase = 1;
                    timer = 0;
                }

            case 1:
                if (timer >= 0.3)
                {
                    player.framerate = 8;
                    player.play("spr_krisu_fall_lw");
                    statePhase = 2;
                    timer = 0;
                }

            case 2:
                squareSoundTimer += elapsed;
                if (squareSoundTimer >= 0.2 && squareSoundCount < 6)
                {
                    squareSoundTimer = 0;
                    squareSoundCount++;
                    SoundPlayer.playSound('romfs:/assets/sounds/audiogroup_default/external/snd_dtrans_square.cwav');
                }
                if (timer >= 1.4)
                {
                    if (door != null) door.setDoorState(DSDarkDoor.STATE_DARK_VOID);
                    player.framerate = 10;
                    player.looped = false;
                    player.play("spr_kris_fall_turnaround");
                    SoundPlayer.playSound('romfs:/assets/sounds/audiogroup_default/external/snd_dtrans_drone.cwav');
                    statePhase = 3;
                    timer = 0;
                }

            case 3:
                player.x = swayBaseX + (Math.sin((timer * 150) * (Math.PI / 180)) * 60);
                if (timer >= 0.7)
                {
                    player.x = swayBaseX;
                    player.framerate = 6;
                    player.looped = true;
                    player.play("spr_kris_fall_d_lw");
                    statePhase = 4;
                    timer = 0;
                }

            case 4:
                spawnLines(elapsed);
                if (timer >= 0.3)
                {
                    player.framerate = 15;
                    player.looped = false;
                    player.play("spr_kris_fall_d_white");
                    statePhase = 5;
                    timer = 0;
                }

            case 5:
                var sweep:Float = timer / 1.2;
                if (sweep > 1) sweep = 1;
                player.setClip(sweep);

                spawnLines(elapsed);

                if (timer >= 2.5)
                {
                    player.setClip(1);
                    statePhase = 6;
                    timer = 0;
                    player.framerate = 6;
                    player.play("spr_kris_fall_d_dw");
                }

            case 6:
                if (!bgOverlayCreated)
                {
                    bgOverlayCreated = true;
                    bgOverlay = new CitroSprite(0, 0);
                    bgOverlay.makeGraphic(CitroG.WIDTH * 4, CitroG.HEIGHT * 16, 0xFF000000);
                    if (camera != null) {
                        var idx = camera.members.indexOf(player);
                        if (idx == -1) camera.add(bgOverlay);
                        else camera.insert(idx, bgOverlay);
                    }
                }
                positionOverlay();

                if (timer >= 0.3)
                {
                    SoundPlayer.stopSound('romfs:/assets/sounds/audiogroup_default/external/snd_dtrans_drone.cwav');
                    player.framerate = 15;
                    player.looped = false;
                    player.play("spr_kris_fall_smear");
                    statePhase = 7;
                    timer = 0;
                }

            case 7:
                positionOverlay();
                spawnLines(elapsed);
                if (timer >= 0.6)
                {
                    player.framerate = 12;
                    player.looped = true;
                    player.play("spr_kris_fall_ball");
                    fallSpeed = 780;
                    statePhase = 8;
                    timer = 0;
                }

            case 8:
                positionOverlay();
                player.y += fallSpeed * elapsed;

                if (timer < 0.3) spawnLines(elapsed);

                if (!flipPlayed && timer >= 0.65)
                {
                    flipPlayed = true;
                    SoundPlayer.playSound('romfs:/assets/sounds/audiogroup_default/external/snd_dtrans_flip.cwav');
                }

                if (player.y >= targetLandingY) 
                {
                    player.y = targetLandingY;
                    player.framerate = 8;
                    player.looped = false;
                    player.play("spr_kris_dw_landed");
                    statePhase = 9;
                    timer = 0;
                }

            case 9: 
                positionOverlay();

                if (!himPlayed && timer >= 0.45)
                {
                    himPlayed = true;
                    SoundPlayer.playSound('romfs:/assets/sounds/audiogroup_default/external/snd_him_quick.cwav');
                }

                if (player.finished && timer >= 0.5)
                {
                    player.setDarkWorld(true);
                    player.isBusy = false;

                    if (camera != null) camera.follow(player, true);

                    if (bgOverlay != null) bgOverlay.destroy();

                    if (onComplete != null) onComplete();

                    destroy();
                }
        }

        return super.update();
    }

    function positionOverlay()
    {
        if (bgOverlay != null) {
            bgOverlay.x = player.x - CitroG.WIDTH * 2;
            bgOverlay.y = player.y - CitroG.HEIGHT * 8;
        }
    }

    function spawnLines(elapsed:Float)
    {
        lineSpawnTimer += elapsed;
        if (lineSpawnTimer >= 0.035) 
        {
            lineSpawnTimer = 0;
            var line = new DSDarkTransitionLine(player.x, player.y + 200);
            if (camera != null) camera.add(line);
        }
    }
}
#end
