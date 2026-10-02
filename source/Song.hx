package;

import Section.SwagSection;
import haxe.Json;

typedef SwagSong = {
    var song:String;
    var notes:Array<SwagSection>;
    var events:Array<Dynamic>;
    var bpm:Float;
    var needsVoices:Bool;
    var speed:Float;
    var player1:String;
    var player2:String;
    var gfVersion:String;
    var stage:String;
    var arrowSkin:String;
    var splashSkin:String;
    var validScore:Bool;
}

class Song
{
    public static function parseJSONshit(rawJson:String):SwagSong {
        var swagShit:SwagSong = cast Json.parse(rawJson).song;
        swagShit.validScore = true;
        
        if(swagShit.events == null) {
            swagShit.events = [];
            for (secNum in 0...swagShit.notes.length) {
                var sec:SwagSection = swagShit.notes[secNum];
                var i:Int = 0;
                var notes:Array<Dynamic> = sec.sectionNotes;
                var len:Int = notes.length;
                while(i < len) {
                    var note:Array<Dynamic> = notes[i];
                    if(note[1] < 0) {
                        swagShit.events.push([note[0], [[note[2], note[3], note[4]]]]);
                        notes.remove(note);
                        len = notes.length;
                    } else i++;
                }
            }
        }
        return swagShit;
    }
}
