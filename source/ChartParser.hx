package;

import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import Song.SwagSong;

using StringTools;

class ChartParser
{
    static public function parse(songName:String):SwagSong
    {
        var path:String = 'romfs:/assets/data/' + songName + '/' + songName + '.json';
        
        if (!FileSystem.exists(path)) {
            var formatted = songName.toLowerCase().replace(" ", "-");
            path = 'romfs:/assets/data/' + formatted + '/' + formatted + '.json';
        }
        
        if (FileSystem.exists(path)) {
            var rawJson:String = File.getContent(path);
            return Song.parseJSONshit(rawJson);
        }
        
        trace('ChartParser: Could not find chart at ' + path);
        return null;
    }
    
    static public function parseSection(songName:String, section:Int):Array<Dynamic>
    {
        var songData = parse(songName);
        if (songData != null && section < songData.notes.length) {
            return songData.notes[section].sectionNotes;
        }
        return [];
    }
}
