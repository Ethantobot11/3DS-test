package;

import citro.CitroG;
import citro.object.CitroObject;
import citro.object.CitroSprite;
import citro.state.CitroState;
import haxe3ds.services.HID;

class MainMenuState extends CitroState {
    
    /**
     * Currently selected index (0 to 2 for save slots, 3 for Options menu).
     */
    private var selectedIndex:Int = 0;

    /**
     * Total items selectable in the main menu (3 Save Slots + 1 Options Button).
     */
    private final TOTAL_MENU_ITEMS:Int = 4;

    /**
     * Visual UI elements for background.
     */
    private var menuBackground:CitroSprite;

    public function new() {
        super();
    }

    override public function create() {
        super.create();

        if (CitroG.save.data.slots == null) {
            CitroG.save.data.slots = [
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" }
            ];
            CitroG.save.flush();
        }

        menuBackground = new CitroSprite(0, 0);
        menuBackground.makeGraphic(CitroG.WIDTH, CitroG.HEIGHT, 0xFF0A0A1E); 
        add(menuBackground);

        trace("MainMenuState loaded. Use UP/DOWN to navigate, A to select, X to erase slots.");
    }

    override public function update(delta:Int) {
        super.update(delta);

        if (HID.keyPressed(HIDKey.UP) || HID.keyPressed(HIDKey.CPAD_UP)) {
            selectedIndex--;
            if (selectedIndex < 0) selectedIndex = TOTAL_MENU_ITEMS - 1;
            updateSelectionLog();
        }
        
        if (HID.keyPressed(HIDKey.DOWN) || HID.keyPressed(HIDKey.CPAD_DOWN)) {
            selectedIndex++;
            if (selectedIndex >= TOTAL_MENU_ITEMS) selectedIndex = 0;
            updateSelectionLog();
        }

        if (HID.keyPressed(HIDKey.A)) {
            if (selectedIndex < 3) {
                selectSlot(selectedIndex);
            } else {
                trace("Opening Options Menu...");
                CitroG.switchState(new OptionsState());
            }
        }

        if (HID.keyPressed(HIDKey.X) && selectedIndex < 3) {
            eraseSlot(selectedIndex);
        }

        if (HID.keyPressed(HIDKey.Y)) {
            CitroG.switchState(new OptionsState());
        }
    }

    private function updateSelectionLog() {
        if (selectedIndex < 3) {
            trace('Selected: Save Slot ${selectedIndex + 1}');
        } else {
            trace('Selected: Options Menu');
        }
    }

    /**
     * Handles loading or creating a save file for the chosen slot.
     */
    private function selectSlot(slotIndex:Int) {
        var slots:Array<Dynamic> = CitroG.save.data.slots;
        var currentSlotData = slots[slotIndex];

        CitroG.save.data.currentSlot = slotIndex;

        if (!currentSlotData.created) {
            currentSlotData.created = true;
            currentSlotData.name = "KRIS";
            currentSlotData.room = "room_clost";
            trace('Created new save data in Slot ${slotIndex + 1}');
        } else {
            trace('Loaded existing save data from Slot ${slotIndex + 1} (${currentSlotData.name})');
        }

        CitroG.save.flush();

        CitroG.switchState(new PlayState());
    }

    /**
     * Wipes data clean for a specific slot.
     */
    private function eraseSlot(slotIndex:Int) {
        var slots:Array<Dynamic> = CitroG.save.data.slots;
        slots[slotIndex] = { created: false, name: "EMPTY", playTime: 0, room: "R_START" };
        
        CitroG.save.flush();
        trace('Erased Slot ${slotIndex + 1}');
    }

    override public function destroy() {
        super.destroy();
    }
}