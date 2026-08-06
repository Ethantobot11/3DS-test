package;

import citro.object.CitroAnimate;
import citro.object.CitroSprite;
import citro.object.CitroCamera;
import citro.CitroG;
using StringTools;

class DarkWorldTransition extends CitroAnimate
{
    var player:Player;
    var door:DarkDoor;
    var camera:CitroCamera;
    var statePhase:Int = 0;
    var timer:Float = 0;
    
    var bgOverlay:CitroSprite;
    var lineSpawnTimer:Float = 0;
    
    var targetLandingY:Float;

    public var onComplete:Void->Void;

    public function new(player:Player, door:DarkDoor = null, camera:CitroCamera = null)
    {
        super("romfs:/assets/images/trans/spr_krisu_run.cea", "spr_krisu_run");

        this.x = player.x;
        this.y = player.y;
        this.player = player;
        this.door = door;
        this.camera = camera;

        this.targetLandingY = player.y + 2200;
        this.framerate = 8; 
        this.looped = true;

        loadTransitionAnimations();

        player.visible = false;
        player.isBusy = true;

        if (this.camera != null) {
            this.camera.follow(this);
        }

        startTransition();
    }

    private function loadTransitionAnimations():Void
    {
        var ceaFiles = [
            "spr_krisu_run.cea",
            "spr_krisu_fall_lw.cea",
            "spr_kris_fall_turnaround.cea",
            "spr_kris_fall_d_lw.cea",
            "spr_kris_fall_d_white.cea",
            "spr_kris_fall_d_dw.cea",
            "spr_kris_fall_smear.cea",
            "spr_kris_fall_ball.cea",
            "spr_kris_dw_landed.cea"
        ];

        for (ceaFile in ceaFiles) {
            var ceaPath = 'romfs:/assets/images/trans/$ceaFile';
            if (!sys.FileSystem.exists(ceaPath)) continue;

            var file:String = sys.io.File.getContent(ceaPath);
            var dir:String = "romfs:/assets/images/trans";

            if (file != "") {
                for (line in file.split("\n")) {
                    if (line.trim() == "") continue;
                    var row:Array<String> = line.split("?");
                    if (row.length < 4) continue;
                    
                    final frameKey:String = row[3].trim();
                    var sprite:citro.object.CitroSprite = new citro.object.CitroSprite();
                    if (!sprite.loadGraphic('$dir/${row[0]}')) {
                        sprite.destroy();
                        continue;
                    }

                    var resultParse:Array<Null<Float>> = [for (idx in 1...3) Std.parseFloat(row[idx])];
                    sprites.set(frameKey, {
                        frameX: resultParse[0] == null ? 0 : resultParse[0],
                        frameY: resultParse[1] == null ? 0 : resultParse[1],
                        sprite: sprite
                    });
                }
            }
        }
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
            case 1:
                if (timer >= 0.4)
                {
                    if (door != null) {
                        door.setDoorState(DarkDoor.STATE_OPEN_FRAME);
                    }

                    framerate = 8;
                    play("spr_krisu_fall_lw");
                    statePhase = 2;
                    timer = 0;
                }

            case 2:
                if (timer >= 0.6)
                {
                    if (door != null) {
                        door.setDoorState(DarkDoor.STATE_DARK_VOID);
                    }

                    bgOverlay = new CitroSprite(0, 0);
                    bgOverlay.makeGraphic(CitroG.WIDTH * 4, CitroG.HEIGHT * 16, 0xFF000000);
                    
                    framerate = 10;
                    play("spr_kris_fall_turnaround");
                    looped = false;
                    statePhase = 3;
                    timer = 0;
                }

            case 3:
                if (timer >= 0.5)
                {
                    framerate = 6;
                    looped = true;
                    play("spr_kris_fall_d_lw");
                }

                if (timer >= 2.0)
                {
                    statePhase = 4;
                    timer = 0;
                    framerate = 6;
                    play("spr_kris_fall_d_white");
                }

            case 4:
                if (timer >= 1.2)
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
                        camera.follow(player);
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
                var line = new DarkTransitionLine(x, y + 200);
            }
        }

        return super.update();
    }
}