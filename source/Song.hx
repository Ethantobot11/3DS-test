package;

typedef SwagSection = {
    var sectionNotes:Array<Dynamic>;
    var sectionBeats:Float;
    var typeOfSection:Int;
    var mustHitSection:Bool;
    var gfSection:Bool;
    var bpm:Float;
    var changeBPM:Bool;
    var altAnim:Bool;
}

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

class Song {
    public static function parseJSONshit(rawJson:String):SwagSong {
        var swagShit:SwagSong = cast haxe.Json.parse(rawJson).song;
        swagShit.validScore = true;
        if(swagShit.events == null) swagShit.events = [];
        return swagShit;
    }
}