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
        super.create();

        CrashHandler.init();

        background = new CitroSprite(40, 30);
        background.makeGraphic(320, 180, 0xDD000000);
        add(background);

        titleText = new CitroText(60, 40, "=== SAVE MENU ===");
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
            
            var t = new CitroText(80, 90 + (i * 35), displayString);
            t.color = CitroColor.WHITE;
            slotTexts.push(t);
            add(t);
        }

        soulCursor = new CitroSprite(60, 98);
        soulCursor.makeGraphic(8, 8, 0xFFFF0000); 
        add(soulCursor);
        
        //updateSlotSelection();
    }

    override public function update(dt:Int)
    {
        super.update(dt);

        var previousSlot = selectedSlot;

        if (HID.keyPressed(HIDKey.UP)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            selectedSlot--;
            if (selectedSlot < 0) selectedSlot = 2;
            updateSlotSelection(previousSlot);
        }
        else if (HID.keyPressed(HIDKey.DOWN)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            selectedSlot++;
            if (selectedSlot > 2) selectedSlot = 0;
            updateSlotSelection(previousSlot);
        }

        if (HID.keyPressed(HIDKey.A)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_save.cwav');
            CitroG.save.data.slots[selectedSlot] = {
                created: true,
                name: "KRIS",
                playTime: 100,
                room: "room_save"
            };
            CitroG.save.flush();
            
            slotTexts[selectedSlot].text = 'Slot ${selectedSlot + 1}: KRIS';
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

        var targetY = 98 + (selectedSlot * 35);
        CitroTween.cancelTweensFrom(soulCursor);
        CitroTween.tweenObject(soulCursor, ["y" => targetY], 0.1, { ease: QUAD_OUT });
    }
}

#end
