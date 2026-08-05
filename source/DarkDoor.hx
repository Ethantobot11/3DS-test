package;

import citro.object.CitroSprite;

class DarkDoor extends CitroSprite
{
    public static inline var STATE_CLOSED:Int = 0;
    public static inline var STATE_OPEN_FRAME:Int = 1;
    public static inline var STATE_DARK_VOID:Int = 2;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        loadGraphic("romfs:/assets/images/trans/spr_darkdoor_0.t3x");
    }

    public function setDoorState(state:Int)
    {
        switch (state)
        {
            case STATE_CLOSED:
                loadGraphic("romfs:/assets/images/trans/spr_darkdoor_0.t3x");
            case STATE_OPEN_FRAME:
                loadGraphic("romfs:/assets/images/trans/spr_darkdoor_1.t3x");
            case STATE_DARK_VOID:
                loadGraphic("romfs:/assets/images/trans/spr_darkdoor_2.t3x");
        }
    }
}