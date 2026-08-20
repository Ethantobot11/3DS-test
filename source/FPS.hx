package;

#if haxe3ds
import citro.object.CitroText;
import citro.backend.CitroTimer;
import citro.state.CitroState;
#else
import leafy.LfEngine;
import leafy.backend.sdl.LfWindowRender;
#end

class FPS extends CitroState
{
    public var fpsText:CitroText;

    private var currentDelta:Int = 16;

    public var instance:FPS;

    public function new()
    {
       super();
        
       instance = this;
    }

    override public function create()
    {
        super.create();
        trace("Starting FPS Counter for 3DS Application...");

        fpsText = new CitroText(2, 2, "FPS: 60");
        fpsText.color = 0xFFFFFF00;
        add(fpsText);

        CitroTimer.start(0.25, function() {
            var fps:Int = currentDelta > 0 ? Std.int(1000 / currentDelta) : 60;
            fpsText.text = 'FPS: $fps';
        }, -1);
    }

    override public function update(delta:Int)
    {
        super.update(delta);
        currentDelta = delta;
    }

    override public function destroy() {
        CitroTimer.reset();
        super.destroy();
    }
}
