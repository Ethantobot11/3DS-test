package source;

package;

import citro.object.CitroAnimate;
import citro.CitroG;

class StrumNote extends CitroAnimate {
    public var resetAnim:Float = 0;
    public var noteData:Int = 0;
    private var player:Int;
    private var dirNames:Array<String> = ['purple', 'blue', 'green', 'red'];

    public function new(x:Float, y:Float, leData:Int, player:Int) {
        // Loads standard FNF NOTE_assets.cea
        super("romfs:/assets/images/NOTE_assets.cea", dirNames[leData] + "Scroll");
        this.x = x;
        this.y = y;
        noteData = leData;
        this.player = player;
        this.scale.set(0.35, 0.35);
    }

    public function playConfirm() {
        play(dirNames[noteData] + " confirm");
        resetAnim = 0.15;
    }

    override public function update():Bool {
        var elapsed:Float = CitroG.deltaTime / 1000.0;
        if(resetAnim > 0) {
            resetAnim -= elapsed;
            if(resetAnim <= 0) {
                play(dirNames[noteData] + "Scroll");
                resetAnim = 0;
            }
        }
        return super.update();
    }
}