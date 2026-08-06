package objects;

import leafy.objects.LfSprite;

class WiiUDarkDoor extends LfSprite
{
    public static inline var STATE_CLOSED:Int = 0;
    public static inline var STATE_OPEN_FRAME:Int = 1;
    public static inline var STATE_DARK_VOID:Int = 2;

    public function new(x:Float, y:Float)
    {
        super(Std.int(x), Std.int(y));
        
        loadImage("assets/images/trans/spr_darkdoor_0.png");
        immovable = true;
    }

    public function setDoorState(state:Int):Void
    {
        switch (state)
        {
            case STATE_CLOSED:
                loadImage("assets/images/trans/spr_darkdoor_0.png");
            case STATE_OPEN_FRAME:
                loadImage("assets/images/trans/spr_darkdoor_1.png");
            case STATE_DARK_VOID:
                loadImage("assets/images/trans/spr_darkdoor_2.png");
        }
    }
}