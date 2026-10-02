package;

import citro.object.CitroAnimate;
import citro.CitroG;

class Note extends CitroAnimate {
    public var strumTime:Float = 0;
    public var mustPress:Bool = false;
    public var noteData:Int = 0;
    public var canBeHit:Bool = false;
    public var tooLate:Bool = false;
    public var wasGoodHit:Bool = false;
    public var hitHealth:Float = 0.023;
    public var missHealth:Float = 0.0475;
    
    private var dirNames:Array<String> = ['purple', 'blue', 'green', 'red'];

    public function new(strumTime:Float, noteData:Int) {
        super("romfs:/assets/images/NOTE_assets.cea", dirNames[noteData % 4] + "Scroll");
        this.strumTime = strumTime;
        this.noteData = noteData;
        this.scale.set(0.35, 0.35);
    }

    override public function update():Bool {
        if (mustPress) {
            canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + Conductor.safeZoneOffset);
            if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit) tooLate = true;
        }
        if (tooLate && this.alpha > 0.3) this.alpha = 0.3;
        return super.update();
    }
}