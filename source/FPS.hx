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
