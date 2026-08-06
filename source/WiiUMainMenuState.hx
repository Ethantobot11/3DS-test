package;

import leafy.Leafy;
import leafy.states.LfState;
import leafy.objects.LfSprite;
import leafy.objects.LfText;
import leafy.gamepad.LfGamepad.LfGamepadButton;

class MainMenuState extends LfState {
    
    /**
     * Currently selected index (0 to 2 for save slots, 3 for Options menu).
     */
    private var selectedIndex:Int = 0;

    /**
     * Total items selectable in the main menu (3 Save Slots + 1 Options Button).
     */
    private final TOTAL_MENU_ITEMS:Int = 4;

    /**
     * Visual UI elements for background and text displays.
     */
    private var menuBackground:LfSprite;
    private var titleText:LfText;

    public function new() {
        super();
    }

    override public function create():Void {
        super.create();

        if (Leafy.save.data.slots == null) {
            Leafy.save.data.slots = [
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" }
            ];
            Leafy.save.flush();
        }

        menuBackground = new LfSprite(0, 0);
        menuBackground.createGraphic(Leafy.screenWidth, Leafy.screenHeight, [10, 10, 30]); 
        addObject(menuBackground);

        titleText = new LfText(0, 40, "DELTARUNE - MAIN MENU", 32, "LeafyGame/font.ttf");
        titleText.center(CENTER_X);
        titleText.setColor(255, 255, 255);
        addObject(titleText);

        trace("MainMenuState loaded on Wii U. Use D-Pad UP/DOWN to navigate, A to select, X to erase slots.");
    }

    override public function update(delta:Float):Void {
        super.update(delta);

        if (Leafy.wiiuGamepad.justPressed(BUTTON_UP)) {
            selectedIndex--;
            if (selectedIndex < 0) selectedIndex = TOTAL_MENU_ITEMS - 1;
            updateSelectionLog();
        }
        
        if (Leafy.wiiuGamepad.justPressed(BUTTON_DOWN)) {
            selectedIndex++;
            if (selectedIndex >= TOTAL_MENU_ITEMS) selectedIndex = 0;
            updateSelectionLog();
        }

        if (Leafy.wiiuGamepad.justPressed(BUTTON_A)) {
            if (selectedIndex < 3) {
                selectSlot(selectedIndex);
            } else {
                trace("Opening Options Menu...");
                //Leafy.switchState(new OptionsState());
            }
        }

        if (Leafy.wiiuGamepad.justPressed(BUTTON_X) && selectedIndex < 3) {
            eraseSlot(selectedIndex);
        }

        if (Leafy.wiiuGamepad.justPressed(BUTTON_Y)) {
            trace("Opening Options Menu...");
            //Leafy.switchState(new OptionsState());
        }
    }

    private function updateSelectionLog():Void {
        if (selectedIndex < 3) {
            trace('Selected: Save Slot ${selectedIndex + 1}');
        } else {
            trace('Selected: Options Menu');
        }
    }

    private function selectSlot(slotIndex:Int):Void {
        var slots:Array<Dynamic> = Leafy.save.data.slots;
        var currentSlotData = slots[slotIndex];

        Leafy.save.data.currentSlot = slotIndex;

        if (!currentSlotData.created) {
            currentSlotData.created = true;
            currentSlotData.name = "KRIS";
            currentSlotData.room = "room_clost";
            trace('Created new save data in Slot ${slotIndex + 1}');
        } else {
            trace('Loaded existing save data from Slot ${slotIndex + 1} (${currentSlotData.name})');
        }

        Leafy.save.flush();

        Leafy.switchState(new WiiUPlayState());
    }

    private function eraseSlot(slotIndex:Int):Void {
        var slots:Array<Dynamic> = Leafy.save.data.slots;
        slots[slotIndex] = { created: false, name: "EMPTY", playTime: 0, room: "R_START" };
        
        Leafy.save.flush();
        trace('Erased Slot ${slotIndex + 1}');
    }

    override public function destroy():Void {
        super.destroy();
    }
}