package citro.object;

#if (!wiiu || !cafe)

import sys.io.File;
import citro.object.CitroSprite;

using StringTools;

final keys:Array<String> = ["acceleration", "alpha", "angle", "bottom", "color", "scale"];
private typedef CitroAnimateHeader = {
    var frameX:Float;
    var frameY:Float;
    var sprite:CitroSprite;
}

/**
 * A class for animation purpose.
 */
class CitroAnimate extends CitroObject {

    var timeLeft:Float = 0;
    var sprites:Map<String, CitroAnimateHeader> = [];

    /**
     * The framerate for this animation to use.
     */
    public var framerate:Float = 24;

    /**
     * The current frame for this animation playing.
     */
    public var frame:Int = 0;

    /**
     * The current playing animation name that's gonna be used.
     */
    public var curAnim:String = "";

    /**
     * Whetever or not the animation that's currently playing has finished.
     */
    public var finished:Bool = false;

    /**
     * Whetever or not it should loop the entire animation when finished.
     */
    public var looped:Bool = false;

    /**
     * Constructs this sprite.
     * @param ceaFile Path to the `.cea` (Citro Engine Animate) file to parse.
     * @param defaultAnim The default animation that's going to be used, if string is empty then uses the first animation that was parsed.
     */
    public function new(ceaFile:String, defaultAnim:String = "") {
        super();

        final file:String = File.getContent(ceaFile);
        var dir:String = ceaFile.substr(0, ceaFile.lastIndexOf("/"));
        if (dir == "") dir = ".";

        if (file != "") {
            var firstAnimFound:String = "";

            for (line in file.split("\n")) {
                if (line.trim() == "") continue;
                final row:Array<String> = line.split("?");
                if (row.length < 4) continue; 

                final fullKey:String = row[3].trim();
                
                final dashIndex:Int = fullKey.lastIndexOf("-");
                final animName:String = dashIndex != -1 ? fullKey.substr(0, dashIndex) : fullKey;

                if (firstAnimFound == "") firstAnimFound = animName;

                final sprite:CitroSprite = new CitroSprite();
                if (!sprite.loadGraphic('$dir/${row[0]}')) {
                    sprite.destroy();
                    continue;
                }

                final resultParse:Array<Null<Float>> = [for (i in 1...3) Std.parseFloat(row[i])];
                sprites.set(fullKey, {
                    frameX: resultParse[0] == null ? 0 : resultParse[0],
                    frameY: resultParse[1] == null ? 0 : resultParse[1],
                    sprite: sprite
                });
            }

            if (defaultAnim == "") defaultAnim = firstAnimFound;
        }

        play(defaultAnim);
    }

    /**
     * Plays a new animation that's found in the sprite's map.
     * @param animation Animation name to play.
     */
    public function play(animation:String):Bool {
        if (isDestroyed) {
            return false;
        }
        
        final animFormat:String = '$animation-0';
        if (sprites.exists(animFormat)) {
            timeLeft = 1000 / framerate;
            finished = false;
            curAnim = animation;
            frame = 0;

            final spr:CitroSprite = sprites[animFormat].sprite;
            width  = spr.width;
            height = spr.height;
            return true;
        }

        return false;
    }

    inline function format() {
        return '${curAnim}-$frame';
    }

    override function update():Bool {
        if (isDestroyed) {
            return false;
        }

        if ((timeLeft -= CitroG.deltaTime) < 1) {
            timeLeft = 1000 / framerate;
            frame++;
            if (!sprites.exists(format())) {
                finished = true;
                if (looped) {
                    frame = 0;
                } else {
                    frame--;
                }
            } else {
                final header:CitroSprite = sprites.get(format()).sprite;
                width = header.width;
                height = header.height;
            }
        }

        if (sprites.exists(format()) && visible) {
            final header:CitroAnimateHeader = sprites.get(format());
            final sprite:CitroSprite = header.sprite;

            for (key in keys) Reflect.setProperty(sprite, key, Reflect.getProperty(this, key));
            sprite.x = x - (header.frameX * scale.x);
            sprite.y = y - (header.frameY * scale.y);
            return sprite.update();
        }

        return false;
    }

    override function destroy() {
        if (sprites != null) {
            for (header in sprites) {
                if (header != null && header.sprite != null) {
                    header.sprite.destroy();
                }
            }
            sprites = null;
        }
        super.destroy();
    }
}

#end