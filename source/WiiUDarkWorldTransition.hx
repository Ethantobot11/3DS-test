package;

#if (!haxe3ds || !nx)

import leafy.objects.LfSprite;
import leafy.backend.LeafyDebug;
import leafy.backend.sdl.LfWindow;
import leafy.filesystem.LfSystemPaths;

class WiiUDarkWorldTransition extends LfSprite
{
    var player:WiiUPlayer;
    var door:WiiUDarkDoor;
    var statePhase:Int = 0;
    var timer:Float = 0;
    
    var bgOverlay:LfSprite;
    var lineSpawnTimer:Float = 0;
    
    var targetLandingY:Float;
    var floatY:Float;

    public var onComplete:Void->Void;

    public function new(player:WiiUPlayer, door:WiiUDarkDoor = null)
    {
        floatY = player.y;
        super(Std.int(player.x), Std.int(floatY));
        this.player = player;
        this.door = door;

        this.targetLandingY = player.y + 2200;

        loadGraphicFromXml("assets/images/trans/kris_dark_trans.png", "assets/images/trans/kris_dark_trans.xml");

        addAnimationByPrefix("run_up", "spr_krisu_run_", 8, true);
        addAnimationByPrefix("fall_lw", "spr_krisu_fall_lw_", 8, true);
        addAnimationByPrefix("turnaround", "spr_kris_fall_turnaround_", 10, false);
        
        addAnimationByPrefix("fall_down_lw", "spr_kris_fall_d_lw_", 6, true);

        var whiteFrames:Array<String> = [
            "spr_kris_fall_d_white_00000",
            "spr_kris_fall_d_white_10000",
            "spr_kris_fall_d_white_20000"
        ];
        animationsMap.set("fall_down_white", new LfAnimation("fall_down_white", whiteFrames, 6, true));
        
        addAnimationByPrefix("fall_down_dw", "spr_kris_fall_d_dw_", 6, true);
        addAnimationByPrefix("smear", "spr_kris_fall_smear_", 15, false);
        addAnimationByPrefix("ball", "spr_kris_fall_ball_", 12, true);
        addAnimationByPrefix("landed", "spr_kris_dw_landed_", 8, false);

        player.isVisible = false;
        player.isBusy = true;
        
        startTransition();
    }

    function startTransition():Void
    {
        statePhase = 1; 
        playAnimation("run_up");
        velocity = {x: 0, y: -50}; 
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        timer += elapsed;
        
        floatY += velocity.y * elapsed;
        y = floatY;

        if (statePhase >= 3 && statePhase <= 7)
        {
            lineSpawnTimer += elapsed;
            if (lineSpawnTimer >= 0.035) 
            {
                lineSpawnTimer = 0;
                var line = new WiiUDarkTransitionLine(Std.int(x), Std.int(floatY + 200));
            }
        }

        switch (statePhase)
        {
            case 1:
                if (timer >= 0.4)
                {
                    if (door != null)
                        door.setDoorState(WiiUDarkDoor.STATE_OPEN_FRAME);

                    velocity = {x: 0, y: -70};
                    playAnimation("fall_lw");
                    statePhase = 2;
                    timer = 0;
                }

            case 2:
                if (timer >= 0.6)
                {
                    if (door != null)
                        door.setDoorState(WiiUDarkDoor.STATE_DARK_VOID);

                    bgOverlay = new LfSprite(0, 0);
                    bgOverlay.createGraphic(1280 * 4, 720 * 16, [0, 0, 0, 255]);

                    velocity = {x: 0, y: 0};
                    playAnimation("turnaround");
                    statePhase = 3;
                    timer = 0;
                }

            case 3:
                if (timer >= 0.5 && velocity.y == 0)
                {
                    velocity = {x: 0, y: 90};
                    playAnimation("fall_down_lw");
                }

                if (timer >= 2.0)
                {
                    statePhase = 4;
                    timer = 0;
                    velocity = {x: 0, y: 130};
                    playAnimation("fall_down_white");
                }

            case 4:
                if (timer >= 1.2)
                {
                    statePhase = 5;
                    timer = 0;
                    velocity = {x: 0, y: 180};
                    playAnimation("fall_down_dw");
                }

            case 5:
                if (timer >= 1.6)
                {
                    statePhase = 6;
                    timer = 0;
                    velocity = {x: 0, y: 380};
                    playAnimation("smear");
                }

            case 6:
                if (timer >= 0.3)
                {
                    statePhase = 7;
                    timer = 0;
                    velocity = {x: 0, y: 650};
                    playAnimation("ball");
                }

            case 7:
                if (floatY >= targetLandingY) 
                {
                    floatY = targetLandingY;
                    y = floatY;
                    velocity = {x: 0, y: 0};
                    playAnimation("landed");
                    
                    statePhase = 8;
                    timer = 0;
                }

            case 8:
                if (currentAnimation != null && currentAnimation.name == "landed" && finished)
                {
                    player.x = x;
                    player.y = floatY;
                    
                    player.loadDarkWorld();
                    player.isVisible = true;
                    player.isBusy = false;

                    if (bgOverlay != null)
                    {
                        bgOverlay.destroy();
                        bgOverlay = null;
                    }

                    if (onComplete != null)
                        onComplete();

                    destroy();
                }
        }
    }
}

#end