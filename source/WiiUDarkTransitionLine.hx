package;

#if (!haxe3ds || !nx)

import leafy.objects.LfSprite;
import leafy.Leafy;

class WiiUDarkTransitionLine extends LfSprite
{
    var moveSpeed:Float;

    public function new(centerX:Float, spawnY:Float)
    {
        var spawnX:Float = centerX + (Math.random() * 320 - 160);
        super(Std.int(spawnX), Std.int(spawnY));

        var lineThickness:Int = 2;
        var lineLength:Int = Std.int(Math.random() * 40 + 40);
        
        createGraphic(lineThickness, lineLength, [255, 255, 255, 255]);

        alpha = Math.random() * 0.3 + 0.3;
        moveSpeed = Math.random() * 150 + 350;
    }

    override public function update(elapsed:Float):Void
    {
        y -= moveSpeed * elapsed;
        sdlRect.y = Std.int(y);

        if (y < -100 || y > 720 + 100)
        {
            destroy();
        }

        super.update(elapsed);
    }
}

#end