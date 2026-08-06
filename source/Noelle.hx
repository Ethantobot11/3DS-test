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
                var i:Int = 0;
                final animationList:Array<String> = [];

                for (line in file.split("\n")) {
                    if (line.trim() == "") continue;
                    var row:Array<String> = line.split("?");
                    if (row.length < 3) break;
                    row[3] = row[3].trim();

                    if (!animationList.join(" ").contains(row[3])) {
                        animationList.push(row[3]);
                        i = -1;
                    }
                    i++;

                    final n:String = '${row[3]}-$i';
                    var sprite:citro.object.CitroSprite = new citro.object.CitroSprite();
                    if (!sprite.loadGraphic('$dir/${row[0]}')) {
                        i--;
                        sprite.destroy();
                        continue;
                    }

                    var resultParse:Array<Null<Float>> = [for (idx in 1...3) Std.parseFloat(row[idx])];
                    sprites.set(n, {
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
            play("spr_noelle_walk_down_lw");
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
        if (target.pathHistory.length >= trailDelay)
        {
            var targetFrame = target.pathHistory[trailDelay - 1];

            x = targetFrame.x;
            y = targetFrame.y;

            if (targetFrame.anim.indexOf("u") != -1) play("spr_noelle_walk_up_lw");
            else if (targetFrame.anim.indexOf("d") != -1) play("spr_noelle_walk_down_lw");
            else if (targetFrame.anim.indexOf("l") != -1) play("spr_noelle_walk_left_lw");
            else if (targetFrame.anim.indexOf("r") != -1) play("spr_noelle_walk_right_lw");
        }
    }
}