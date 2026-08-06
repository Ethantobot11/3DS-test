package;

import citro.object.CitroAnimate;

class Noelle extends CitroAnimate
{
    public var isFollowing:Bool = false;
    public var target:Player;
    public var trailDelay:Int = 18; 

    public function new(x:Float, y:Float)
    {
        super("romfs:/assets/images/chars/noelle_walk_down_lw.cea", "spr_noelle_walk_down_lw");
        
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
            "noelle_walk_down_lw.cea",
            "noelle_walk_up_lw.cea",
            "noelle_walk_left_lw.cea",
            "noelle_walk_right_lw.cea"
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
                    if (row.length < 3) break;
                    row[3] = row[3].trim();

                    var sprite:citro.object.CitroSprite = new citro.object.CitroSprite();
                    if (!sprite.loadGraphic('$dir/${row[0]}')) {
                        sprite.destroy();
                        continue;
                    }

                    var resultParse:Array<Null<Float>> = [for (idx in 1...3) Std.parseFloat(row[idx])];
                    sprites.set(row[3], {
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
        if (isFollowing && target != null)
        {
            followPathTrail();
        }
        
        return super.update();
    }

    private function followPathTrail()
    {
        if (target.pathHistory.length >= trailDelay)
        {
            var targetFrame = target.pathHistory[trailDelay - 1];

            if (x != targetFrame.x || y != targetFrame.y)
            {
                x = targetFrame.x;
                y = targetFrame.y;

                if (targetFrame.anim.indexOf("up") != -1) play("spr_noelle_walk_up_lw");
                else if (targetFrame.anim.indexOf("down") != -1) play("spr_noelle_walk_down_lw");
                else if (targetFrame.anim.indexOf("left") != -1) play("spr_noelle_walk_left_lw");
                else if (targetFrame.anim.indexOf("right") != -1) play("spr_noelle_walk_right_lw");
            }
        }
    }
}