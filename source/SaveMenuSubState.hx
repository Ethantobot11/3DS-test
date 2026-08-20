package;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.state.CitroSubState;
import citro.backend.CitroColor;
import haxe3ds.services.HID;

class SaveMenuSubState extends CitroSubState
{
    var background:CitroSprite;
    var titleText:CitroText;
    var slotTexts:Array<CitroText> = [];
    var selectedSlot:Int = 0;
    
    override public function create()
    {
        super.create();

        background = new CitroSprite(40, 30);
        background.makeGraphic(320, 180, 0xDD000000);
        add(background);

        titleText = new CitroText(60, 40, "=== SAVE MENU ===");
        titleText.color = CitroColor.YELLOW;
        add(titleText);

        if (CitroG.save.data.slots == null) {
            CitroG.save.data.slots = [
                {exists: false, details: "Empty Slot"},
                {exists: false, details: "Empty Slot"},
                {exists: false, details: "Empty Slot"}
            ];
        }

        for (i in 0...3) {
            var slotData = CitroG.save.data.slots[i];
            var displayString = 'Slot ${i + 1}: ${slotData.exists ? slotData.details : "Empty"}';
            
            var t = new CitroText(60, 90 + (i * 35), displayString);
            t.color = CitroColor.WHITE;
            slotTexts.push(t);
            add(t);
        }
        
        updateSlotColors();
    }

    override public function update(dt:Int)
    {
        super.update(dt);

        if (HID.keyPressed(HIDKey.UP)) {
            selectedSlot--;
            if (selectedSlot < 0) selectedSlot = 2;
            updateSlotColors();
        }
        else if (HID.keyPressed(HIDKey.DOWN)) {
            selectedSlot++;
            if (selectedSlot > 2) selectedSlot = 0;
            updateSlotColors();
        }

        if (HID.keyPressed(HIDKey.A)) {
            CitroG.save.data.slots[selectedSlot] = {
                exists: true,
                details: "Progress Saved!"
            };
            CitroG.save.flush();
            
            slotTexts[selectedSlot].text = 'Slot ${selectedSlot + 1}: Progress Saved!';
        }

        if (HID.keyPressed(HIDKey.B)) {
            close();
        }
    }

    private function updateSlotColors()
    {
        for (i in 0...slotTexts.length) {
            slotTexts[i].color = (i == selectedSlot) ? CitroColor.GREEN : CitroColor.WHITE;
        }
    }
}

#end
