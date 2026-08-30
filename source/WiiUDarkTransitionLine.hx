package;

#if (!haxe3ds || !nx)

import leafy.objects.LfSprite;
import leafy.Leafy;

class WiiUDarkTransitionLine extends LfSprite
{
    var moveSpeed:Float;
    var floatY:Float;

    public function new(centerX:Float, spawnY:Float)
    {
        var spawnX:Float = centerX + (Math.random() * 320 - 160);
        floatY = spawnY;
        super(Std.int(spawnX), Std.int(floatY));

        var lineThickness:Int = 2;
        var lineLength:Int = Std.int(Math.random() * 40 + 40);
        
        createGraphic(lineThickness, lineLength, [255, 255, 255, 255]);

        alpha = Math.random() * 0.3 + 0.3;
        moveSpeed = Math.random() * 150 + 350;
    }

    override public function update(elapsed:Float):Void
    {
        floatY -= moveSpeed * elapsed;
        y = floatY;
        sdlRect.y = Std.int(floatY);

        if (floatY < -100 || floatY > 720 + 100)
        {
            destroy();
        }

        super.update(elapsed);
    }
}

#end