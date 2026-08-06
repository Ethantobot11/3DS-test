package;

import citro.object.CitroSprite;

class 3DSDarkDoor extends CitroSprite
{
    public static inline var STATE_CLOSED:Int = 0;
    public static inline var STATE_OPEN_FRAME:Int = 1;
    public static inline var STATE_DARK_VOID:Int = 2;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        if (!loadGraphic("romfs:/assets/images/trans/spr_darkdoor_0.t3x")) {
            trace("ERROR: Failed to load initial door graphic!");
        }
    }

    public function setDoorState(state:Int)
    {
        trace('Setting Door State to: $state');
        switch (state)
        {
            case STATE_CLOSED:
                loadGraphic("romfs:/assets/images/trans/spr_darkdoor_0.t3x");
            case STATE_OPEN_FRAME:
                if (!loadGraphic("romfs:/assets/images/trans/spr_darkdoor_1.t3x")) {
                    trace("ERROR: Failed to load spr_darkdoor_1.t3x");
                }
            case STATE_DARK_VOID:
                if (!loadGraphic("romfs:/assets/images/trans/spr_darkdoor_2.t3x")) {
                    trace("ERROR: Failed to load spr_darkdoor_2.t3x");
                }
        }
    }
}