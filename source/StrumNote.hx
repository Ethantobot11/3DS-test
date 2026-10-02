package;

import citro.object.CitroAnimate;
import citro.CitroG;

class StrumNote extends CitroAnimate {
    public var resetAnim:Float = 0;
    public var noteData:Int = 0;
    private var player:Int;
    
    private var staticNames:Array<String> = ['arrowLEFT', 'arrowDOWN', 'arrowUP', 'arrowRIGHT'];
    
    private var confirmNames:Array<String> = ['left confirm', 'down confirm', 'up confirm', 'right confirm'];

    public function new(x:Float, y:Float, leData:Int, player:Int) {
        super("romfs:/assets/images/NOTE_assets.cea", staticNames[leData]);
        this.x = x;
        this.y = y;
        noteData = leData;
        this.player = player;
        this.scale.set(0.35, 0.35);
    }

    public function playConfirm() {
        play(confirmNames[noteData]);
        resetAnim = 0.25;
    }

    override public function update():Bool {
        var elapsed:Float = CitroG.deltaTime / 1000.0;
        if(resetAnim > 0) {
            resetAnim -= elapsed;
            if(resetAnim <= 0) {
                play(staticNames[noteData]);
                resetAnim = 0;
            }
        }
        return super.update();
    }
}