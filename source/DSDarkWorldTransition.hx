package;

#if (!wiiu || !cafe)

import citro.object.CitroObject;
import citro.object.CitroSprite;
import citro.object.CitroCamera;
import citro.CitroG;
import citro.backend.CitroColor;
import citro.backend.CitroTimer;
using StringTools;

class DSDarkWorldTransition extends CitroObject
{
    var player:DSPlayer;
    var susie:DSPlayer;
    var door:DSDarkDoor;
    var camera:CitroCamera;
    
    var statePhase:Int = 0;
    var timer:Float = 0;
    
    var whiteOverlay:CitroSprite;
    var bgOverlay:CitroSprite;
    var lineSpawnTimer:Float = 0;
    
    var startX:Float = 0;
    var startY:Float = 0;
    var swayBaseX:Float = 0;
    var targetLandingY:Float;
    var fallSpeed:Float = 0;
    var gravity:Float = 1200.0;
    
    var shakeIntensity:Float = 0;
    var shakeDecay:Float = 0;

    var squareSoundCount:Int = 0;
    var squareSoundTimer:Float = 0;
    var flipPlayed:Bool = false;
    var himPlayed:Bool = false;
    var susieLandingPlayed:Bool = false;

    public var onComplete:Void->Void;

    public function new(player:DSPlayer, door:DSDarkDoor = null, camera:CitroCamera = null, susie:DSPlayer = null)
    {
        super();
        this.player = player;
        this.susie = susie;
        this.door = door;
        this.camera = camera;

        startX = player.x;
        startY = player.y;
        swayBaseX = player.x;
        this.targetLandingY = startY + 2200;

        player.isBusy = true;
        if (susie != null) susie.isBusy = true;

        player.reloadCEA("romfs:/assets/images/trans/kris_dark_trans.cea", "spr_krisu_run");
        player.framerate = 8;
        player.looped = true;
        player.play("spr_krisu_run");

        whiteOverlay = new CitroSprite(0, 0);
        whiteOverlay.makeGraphic(CitroG.WIDTH, CitroG.HEIGHT, 0xFFFFFFFF);
        whiteOverlay.visible = false;
        whiteOverlay.alpha = 0;
        if (camera != null) camera.add(whiteOverlay);

        if (susie != null) {
            susie.reloadCEA("romfs:/assets/images/trans/susie_dark_trans.cea", "spr_susie_run");
            susie.framerate = 8;
            susie.looped = true;
            susie.play("spr_susie_run");
            susie.x = startX + 40;
            susie.y = startY;
        }

        statePhase = 0; 
    }

    override public function update():Bool
    {
        var elapsed:Float = CitroG.deltaTime / 1000.0;
        timer += elapsed;

        if (shakeIntensity > 0 && camera !=7) 
                positionOverlay();
                spawnLines(elapsed);
                
                if (timer >= 0.6)
                {
                    player.framerate = 12;
                    player.looped = true;
                    player.play("spr_kris_fall_ball");
                    
                    if (susie != null) {
                        susie.framerate = 12;
                        susie.looped = true;
                        susie.play("spr_susie_fall_ball");
                    }
                    
                    fallSpeed = 400;
                    statePhase = 8;
                    timer = 0;
                }

            case 8:
                positionOverlay();
                
                fallSpeed += gravity * elapsed;
                player.y += fallSpeed * elapsed;
                
                if (susie != null) {
                    susie.y += (fallSpeed * 0.95) * elapsed; 
                }

                if (timer < 0.4) spawnLines(elapsed);

                if (!flipPlayed && timer >= 0.65)
                {
                    flipPlayed = true;
                    SoundPlayer.playSound('romfs:/assets/sounds/audiogroup_default/external/snd_dtrans_flip.cwav');
                    shakeIntensity = 5;
                }

                if (player.y >= targetLandingY) 
                {
                    player.y = targetLandingY;
                    if (susie != null) susie.y = targetLandingY + 10;
                    
                    player.framerate = 8;
                    player.looped = false;
                    player.play("spr_kris_dw_landed");
                    
                    if (susie != null) {
                        susie.framerate8;
                        susie.looped = false;
                        susie.play("spr_susie_dw_landed");
                    }

                    shakeIntensity = 12;
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

                var animDone = (player.curAnim == "spr_kris_dw_landed" && player.frame >= player.totalFrames - 1);
                if ((animDone || timer >= 1.5) && timer >= 0.5)
                {
                    player.setDarkWorld(true);
                    player.isBusy = false;
                    
                    if (susie != null) {
                        susie.setDarkWorld(true);
                        susie.isBusy = false;
                    }

                    if (camera != null) {
                        camera.follow(player, true);
                        shakeIntensity = 0;
                    }

                    if (bgOverlay != null) bgOverlay.destroy();
                    if (whiteOverlay != null) whiteOverlay.destroy();

                    if (onComplete != null) onComplete();
                    destroy();
                }
        }

        return super.update();
    }

    function positionOverlay()
    {
        if (bgOverlay != null) {
            bgOverlay.x = player.x - (CitroG.WIDTH * 2);
            bgOverlay.y = player.y - (CitroG.HEIGHT * 8);
        }
    }

    function spawnLines(elapsed:Float)
    {
        lineSpawnTimer += elapsed;
        var spawnRate = 0.035 + (fallSpeed > 0 ? (fallSpeed / 10000) : 0);
        if (lineSpawnTimer >= spawnRate) 
        {
            lineSpawnTimer = 0;
            var line = new DSDarkTransitionLine(player.x, player.y + 200);
            if (camera != null) camera.add(line);
        }
    }
}
#end
