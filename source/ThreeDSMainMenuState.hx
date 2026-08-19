package;

#if (!wiiu || !cafe)
import citro.CitroG;
import citro.object.CitroObject;
import citro.object.CitroSprite;
import citro.object.CitroText; 
import citro.state.CitroState;
import haxe3ds.services.HID;

class ThreeDSMainMenuState extends CitroState {
    
    private var selectedIndex:Int = 0;
    private final TOTAL_MENU_ITEMS:Int = 4;

    private var menuBackground:CitroSprite;

    private var slotUIElements:Array<CitroSprite> = [];
    private var slotTexts:Array<CitroText> = [];

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
        
        var slots:Array<Dynamic> = CitroG.save.data.slots;
        for (i in 0...3) {
            var slotBox = new CitroSprite(40, 40 + (i * 50));
            slotBox.makeGraphic(240, 40, 0xFF222244);
            add(slotBox);
            slotUIElements.push(slotBox);

            
           slots[i].name;
           slots[i].playTime;
        
        var optionsBox = new CitroSprite(40, 40 + (3 * 50));
        optionsBox.makeGraphic(240, 40, 0xFF222244);
        add(optionsBox);
        slotUIElements.push(optionsBox);

        updateVisualSelection();
        trace("MainMenuState loaded.");
    }

    override public function update(delta:Int) {
        super.update(delta);

        var changed = false;

        if (HID.keyPressed(HIDKey.UP) || HID.keyPressed(HIDKey.CPAD_UP)) {
            selectedIndex--;
            if (selectedIndex < 0) selectedIndex = TOTAL_MENU_ITEMS - 1;
            changed = true;
        }
        
        if (HID.keyPressed(HIDKey.DOWN) || HID.keyPressed(HIDKey.CPAD_DOWN)) {
            selectedIndex++;
            if (selectedIndex >= TOTAL_MENU_ITEMS) selectedIndex = 0;
            changed = true;
        }

        if (changed) {
            updateSelectionLog();
            updateVisualSelection();
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

    private function updateVisualSelection() 
        for (i in 0...slotUIElements.length) {
            if (i == selectedIndex) {
                slotUIElements[i].makeGraphic(240, 40, 0xFF444488); // Brighter highlight color
            } else {
                slotUIElements[i].makeGraphic(240, 40, 0xFF222244); // Normal color
            }
        }
    }

    private function updateSelectionLog() {
        if (selectedIndex < 3) {
            trace('Selected: Save Slot ${selectedIndex + 1}');
        } else {
            trace('Selected: Options Menu');
        }
    }

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
#end
