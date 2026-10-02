package;

class Conductor {
    public static var bpm:Float = 100;
    public static var crochet:Float = ((60 / bpm) * 1000);
    public static var stepCrochet:Float = crochet / 4;
    public static var songPosition:Float = 0;
    public static var safeZoneOffset:Float = 150; // ms window to hit a note

    public static function changeBPM(newBpm:Float):Void {
        bpm = newBpm;
        crochet = (60 / bpm) * 1000;
        stepCrochet = crochet / 4;
    }
    
    public static function mapBPMChanges(song:SwagSong):Void {
        // Minimal stub, assumes constant BPM for simplicity
    }
}