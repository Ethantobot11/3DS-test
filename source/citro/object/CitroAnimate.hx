package citro.object;

import sys.io.File;
import citro.object.CitroSprite;
import citro.object.CitroObject;
import citro.CitroG;

using StringTools;

typedef CitroFrame = {
    var srcX:Float;
    var srcY:Float;
    var srcWidth:Float;
    var srcHeight:Float;
    var offsetX:Float;
    var offsetY:Float;
    var frameWidth:Float;
    var frameHeight:Float;
}

class CitroAnimate extends CitroObject {
    var timeLeft:Float = 0;
    var frames:Map<String, CitroFrame>;
    var atlasSprite:CitroSprite = null;
    var atlasPath:String = "";

    public var framerate:Float = 24;
    public var frame:Int = 0;
    public var curAnim:String = "";
    public var finished:Bool = false;
    public var looped:Bool = false;

    public function new(ceaFile:String, defaultAnim:String = "") {
        super();
        frames = new Map();
        loadCEA(ceaFile, defaultAnim);
    }

    function loadCEA(ceaFile:String, defaultAnim:String):Void {
        #if HAXE3DS
        final file:String = File.getContent(ceaFile);
        var dir:String = ceaFile.substr(0, ceaFile.lastIndexOf("/"));
        if (dir == "") dir = ".";

        if (file != "") {
            var firstAnimFound:String = "";
            for (line in file.split("\n")) {
                line = line.trim();
                if (line == "" || line.startsWith("#")) continue; 
                
                final row:Array<String> = line.split("?");
                if (row.length < 10) continue;

                final atlasFile:String = row[0].trim();
                final srcX:Float = Std.parseFloat(row[1]);
                final srcY:Float = Std.parseFloat(row[2]);
                final srcWidth:Float = Std.parseFloat(row[3]);
                final srcHeight:Float = Std.parseFloat(row[4]);
                final offsetX:Float = Std.parseFloat(row[5]);
                final offsetY:Float = Std.parseFloat(row[6]);
                final frameWidth:Float = Std.parseFloat(row[7]);
                final frameHeight:Float = Std.parseFloat(row[8]);
                final fullKey:String = row[9].trim();

                if (atlasPath == "") {
                    atlasPath = '$dir/$atlasFile';
                    atlasSprite = new CitroSprite();
                    if (!atlasSprite.loadGraphic(atlasPath)) {
                        atlasSprite.destroy();
                        atlasSprite = null;
                        return; 
                    }
                }

                final dashIndex:Int = fullKey.lastIndexOf("-");
                final animName:String = dashIndex != -1 ? fullKey.substr(0, dashIndex) : fullKey;
                if (firstAnimFound == "") firstAnimFound = animName;

                frames.set(fullKey, {
                    srcX: srcX, srcY: srcY, srcWidth: srcWidth, srcHeight: srcHeight,
                    offsetX: offsetX, offsetY: offsetY, frameWidth: frameWidth, frameHeight: frameHeight
                });
            }
            if (defaultAnim == "") defaultAnim = firstAnimFound;
        }
        play(defaultAnim);
        #else
        trace("CitroAnimate loadCEA is stubbed for Wii U. Implement loadXML/JSON here.");
        #end
    }

    public function play(animation:String):Bool {
        if (isDestroyed || atlasSprite
