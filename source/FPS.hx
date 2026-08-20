package;

#if haxe3ds
import citro.object.CitroText;
import citro.backend.CitroTimer;
import citro.CitroG;

class FPS extends CitroText
{
    public static var instance:FPS;

    public function new(x:Float = 2, y:Float = 2)
    {
        super(x, y, "FPS: 60");
        color = 0xFFFFFF00;
        instance = this;
        
        trace("Starting FPS Counter for 3DS Application...");

        CitroTimer.start(0.25, function() {
            var dt = CitroG.deltaTime;
            var fps:Int = dt > 0 ? Std.int(1000 / dt) : 60;
            text = 'FPS: $fps';
        }, -1);
    }

    override public function destroy() {
        CitroTimer.reset();
        super.destroy();
    }
}
#end
