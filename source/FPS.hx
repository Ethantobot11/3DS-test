package;

#if haxe3ds
import citro.object.CitroText;
#else
import leafy.LfEngine;
import leafy.backend.sdl.LfWindowRender;
#end

class FPS
{
    public var fpsText:CitroText;

    public function showfpsbro()
    {
        fpsText = new CitroText(2, 2, "FPS: 60");
        fpsText.color = 0xFFFFFF00;
        add(fpsText);
    }
        
    public function create()
    {
        #if haxe3ds
        
        trace("Starting FPS Counter for 3DS Application...");

        showfpsbro();

        CitroTimer.start(0.25, function() {
            var fps:Int = currentDelta > 0 ? Std.int(1000 / currentDelta) : 60;
            fpsText.text = 'FPS: $fps';
        }, -1);
        
        #else
        LfEngine.initEngine("Deltarune", DRC, new WiiUMainMenuState());
        #end
    }

    public function update(delta:Int)
    {
        currentDelta = delta;
    }

    override public function destroy() {
        CitroTimer.reset();
    }
}
