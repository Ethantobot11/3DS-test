package;

import citro.object.CitroSprite;
import citro.object.CitroObject;
import citro.CitroG;

using StringTools;

class HealthIcon extends CitroSprite
{
    public var sprTracker:CitroObject = null;
    private var char:String = '';
    private var frameWidth:Float = 150;
    private var frameHeight:Float = 150;

    public function new(char:String = 'bf')
    {
        super(0, 0);
        changeIcon(char);
    }

    override public function update():Bool
    {
        if (sprTracker != null) {
            this.x = sprTracker.x + sprTracker.width + 12;
            this.y = sprTracker.y - 30;
        }
        return super.update();
    }

    public function changeIcon(newChar:String):Void {
        if(this.char != newChar) {
            var path:String = 'romfs:/assets/images/icons/icon-' + newChar + '.t3x';
            
            if (!sys.FileSystem.exists(path)) {
                path = 'romfs:/assets/images/icons/icon-face.t3x';
            }

            this.loadGraphic(path);
            this.char = newChar;
        }
    }
}
