package;

import citro.object.CitroAnimate;
using StringTools;

class Noelle extends CitroAnimate
{
    public var isFollowing:Bool = false;
    public var target:Player;
    public var trailDelay:Int = 18; 

    public function new(x:Float, y:Float)
    {
        super("romfs:/assets/images/chars/spr_noelle_walk_down_lw.cea", "spr_noelle_walk_down_lw");
        
        this.x = x;
        this.y = y;
        framerate = 6;
        looped = true;

        loadNoelleAnimations();
        play("spr_noelle_walk_down_lw");
    }

    private function loadNoelleAnimations():Void
    {
        var ceaFiles = [
            "spr_noelle_walk_down_lw.cea",
            "spr_noelle_walk_up_lw.cea",
            "spr_noelle_walk_left_lw.cea",
            "spr_noelle_walk_right_lw.cea"
        ];

        for (ceaFile in ceaFiles) {
            var ceaPath = 'romfs:/assets/images/chars/$ceaFile';
            if (!sys.FileSystem.exists(ceaPath)) continue;

            var file:String = sys.io.File.getContent(ceaPath);
            var dir:String = "romfs:/assets/images/chars";

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

    override public function update():Bool
    {
        if (!isFollowing)
        {
            if (curAnim != "spr_noelle_walk_down_lw") {
                play("spr_noelle_walk_down_lw");
            }
        }
        else
        {
            if (target != null)
            {
                followPathTrail();
            }
        }
        
        return super.update();
    }

    private function followPathTrail()
    {
        if (target != null && target.pathHistory.length > 0)
        {
            var indexToUse = (target.pathHistory.length >= trailDelay) ? (trailDelay - 1) : (target.pathHistory.length - 1);
            var targetFrame = target.pathHistory[indexToUse];

            x = targetFrame.x;
            y = targetFrame.y;

            var desiredAnim = "spr_noelle_walk_down_lw";
            if (targetFrame.anim.indexOf("u") != -1) desiredAnim = "spr_noelle_walk_up_lw";
            else if (targetFrame.anim.indexOf("d") != -1) desiredAnim = "spr_noelle_walk_down_lw";
            else if (targetFrame.anim.indexOf("l") != -1) desiredAnim = "spr_noelle_walk_left_lw";
            else if (targetFrame.anim.indexOf("r") != -1) desiredAnim = "spr_noelle_walk_right_lw";

            if (curAnim != desiredAnim) {
                play(desiredAnim);
            }
        }
    }
}