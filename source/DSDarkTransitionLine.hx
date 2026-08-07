package;

#if (!wiiu || !cafe)

import citro.object.CitroSprite;
import citro.backend.CitroColor;
import citro.CitroG;

class DSDarkTransitionLine extends CitroSprite
{
    var moveSpeed:Float;

    public function new(centerX:Float, spawnY:Float)
    {
        var spawnX = centerX + (Math.random() * 320 - 160);
        super(spawnX, spawnY);

        var lineThickness:Int = 2;
        var lineLength:Int = Std.int(Math.random() * 40 + 40);
        
        makeGraphic(lineThickness, lineLength, CitroColor.WHITE);

        alpha = Math.random() * 0.3 + 0.3;
        
        moveSpeed = Math.random() * 150 + 350;
    }

    override public function update():Bool
    {
        var elapsed:Float = CitroG.deltaTime / 1000.0;
        y -= moveSpeed * elapsed;

        if (y < -100 || y > CitroG.HEIGHT + 100)
        {
            destroy();
            return false;
        }

        return super.update();
    }
}

#end