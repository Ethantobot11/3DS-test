package;

#if haxe3ds
import citro.object.CitroText;
import citro.backend.CitroTimer;

class FPS extends CitroText
{
    private var currentDelta:Int = 16;
    public static var instance:FPS;

    public function new(x:Float = 2, y:Float = 2)
    {
        super(x, y, "FPS: 60");
        color = 0xFFFFFF00;
        instance = this;
        
        trace("Starting FPS Counter for 3DS Application...");

        CitroTimer.start(0.25, function() {
            var fps:Int = currentDelta > 0 ? Std.int(1000 / currentDelta) : 60;
            text = 'FPS: $fps';
        }, -1);
    }

    public function update(delta:Int)
    {
        currentDelta = delta;
    }

    public function destroy() {
        CitroTimer.reset();
    }
    #end
}
