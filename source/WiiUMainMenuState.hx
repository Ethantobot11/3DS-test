package;

import leafy.Leafy;
import leafy.states.LfState;
import leafy.objects.LfSprite;
import leafy.objects.LfText;
import leafy.gamepad.LfGamepad.LfGamepadButton;

typedef SaveSlot = {
    var created:Bool;
    var name:String;
    var playTime:Int;
    var room:String;
}

class WiiUMainMenuState extends LfState {
    
    private var selectedIndex:Int = 0;
    private final TOTAL_MENU_ITEMS:Int = 4;

    private var menuBackground:LfSprite;
    private var titleText:LfText;

    public function new() {
        super();
    }

    override public function create():Void {
        super.create();

        if (Leafy.save.data.slots == null) {
            var initialSlots:Array<SaveSlot> = [
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" }
            ];
            Leafy.save.data.slots = initialSlots;
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
            }
        }

        if (Leafy.wiiuGamepad.justPressed(BUTTON_X) && selectedIndex < 3) {
            eraseSlot(selectedIndex);
        }

        if (Leafy.wiiuGamepad.justPressed(BUTTON_Y)) {
            trace("Opening Options Menu...");
        }
    }

    private function updateSelectionLog():Void {
        if (selectedIndex < 3) {
            // Replaced string interpolation with explicit concatenation
            trace("Selected: Save Slot " + (selectedIndex + 1));
        } else {
            trace("Selected: Options Menu");
        }
    }

    private function selectSlot(slotIndex:Int):Void {
        // Cast the save slots array explicitly to your SaveSlot typedef type
        var slots:Array<SaveSlot> = cast Leafy.save.data.slots;
        
        // Explicitly type currentSlotData as SaveSlot so C++ knows its layout
        var currentSlotData:SaveSlot = slots[slotIndex];

        Leafy.save.data.currentSlot = slotIndex;

        if (!currentSlotData.created) {
            currentSlotData.created = true;
            currentSlotData.name = "KRIS";
            currentSlotData.room = "room_clost";
            trace("Created new save data in Slot " + (slotIndex + 1));
        } else {
            trace("Loaded existing save data from Slot " + (slotIndex + 1) + " (" + Std.string(currentSlotData.name) + ")");
        }

        Leafy.save.flush();

        //Leafy.switchState(new WiiUPlayState());
    }

    private function eraseSlot(slotIndex:Int):Void {
        var slots:Array<SaveSlot> = cast Leafy.save.data.slots;
        var emptySlot:SaveSlot = { created: false, name: "EMPTY", playTime: 0, room: "R_START" };
        slots[slotIndex] = emptySlot;
        
        Leafy.save.flush();
        trace("Erased Slot " + (slotIndex + 1));
    }

    override public function destroy():Void {
        super.destroy();
    }
}