package;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.state.CitroSubState;
import citro.backend.CitroColor;
import citro.backend.CitroTween;
import haxe3ds.services.HID;

class SaveMenuSubState extends CitroSubState
{
    var background:CitroSprite;
    var titleText:CitroText;
    var slotTexts:Array<CitroText> = [];
    var selectedSlot:Int = 0;
    
    var soulCursor:CitroSprite;

    override public function create()
    {
        background = new CitroSprite(40, 20);
        background.makeGraphic(320, 200, 0xDD000000);
        add(background);

        titleText = new CitroText(60, 30, "=== SAVE MENU ===");
        titleText.color = CitroColor.YELLOW;
        add(titleText);

        if (CitroG.save.data.slots == null) {
            CitroG.save.data.slots = [
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" },
                { created: false, name: "EMPTY", playTime: 0, room: "R_START" }
            ];
            CitroG.save.flush();
        }

        for (i in 0...3) {
            var slotData = CitroG.save.data.slots[i];
            var displayString = slotData.created ? 'Slot ${i + 1}: ${slotData.name}' : 'Slot ${i + 1}: EMPTY';
            
            var t = new CitroText(80, 75 + (i * 35), displayString);
            t.color = CitroColor.WHITE;
            slotTexts.push(t);
            add(t);
        }

        var menuText = new CitroText(80, 75 + (3 * 35), "Return to Main Menu");
        menuText.color = CitroColor.WHITE;
        slotTexts.push(menuText);
        add(menuText);

        soulCursor = new CitroSprite(60, 83);
        soulCursor.makeGraphic(8, 8, 0xFFFF0000); 
        add(soulCursor);

        super.create();
    }

    override public function update(dt:Int)
    {
        super.update(dt);

        var previousSlot = selectedSlot;

        if (HID.keyPressed(HIDKey.UP)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            selectedSlot--;
            if (selectedSlot < 0) selectedSlot = 3;
            updateSlotSelection(previousSlot);
        }
        else if (HID.keyPressed(HIDKey.DOWN)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            selectedSlot++;
            if (selectedSlot > 3) selectedSlot = 0; 
            updateSlotSelection(previousSlot);
        }

        if (HID.keyPressed(HIDKey.A)) {
            if (selectedSlot < 3) {
                // Save game logic for slots 0, 1, 2
                SoundPlayer.playSound('romfs:/assets/sounds/snd_save.cwav');
                CitroG.save.data.slots[selectedSlot] = {
                    created: true,
                    name: "KRIS",
                    playTime: 100,
                    room: "room_save"
                };
                CitroG.save.flush();
                
                slotTexts[selectedSlot].text = 'Slot ${selectedSlot + 1}: KRIS';
            } else {
                SoundPlayer.playSound('romfs:/assets/sounds/snd_shineselect.cwav');
                close();
                CitroG.switchState(new ThreeDSMainMenuState());
            }
        }

        if (HID.keyPressed(HIDKey.B)) {
            close();
        }
    }

    private function updateSlotSelection(previousSlot:Int)
    {
        for (i in 0...slotTexts.length) {
            slotTexts[i].color = (i == selectedSlot) ? CitroColor.GREEN : CitroColor.WHITE;
        }

        var targetY = 83 + (selectedSlot * 35);
        CitroTween.cancelTweensFrom(soulCursor);
        CitroTween.tweenObject(soulCursor, ["y" => targetY], 0.1, { ease: QUAD_OUT });
    }
}

#end
