package;

#if (!wiiu || !cafe)
import citro.CitroG;
import citro.object.CitroObject;
import citro.object.CitroSprite;
import citro.object.CitroText; 
import citro.state.CitroState;
import citro.backend.CitroTween;
import citro.backend.CitroTimer;
import haxe3ds.services.HID;

class ThreeDSMainMenuState extends CitroState {

    private var menuNo:Int = 0;
    private var menuCoords:Array<Int> = [0, 0, 0, 0, 0, 0, 0, 0];
    
    private var menuBackground:CitroSprite;
    private var slotUIElements:Array<CitroSprite> = [];
    private var slotTexts:Array<CitroText> = [];
    private var actionTexts:Array<CitroText> = [];
    private var headerText:CitroText;
    private var footerText:CitroText;

    private var soulCursor:CitroSprite;

    public function new() {
        super();
    }

    override public function create() {
        trace("Entering Deltarune-style MainMenuState.create()...");

        SoundPlayer.playSound('romfs:/assets/sounds/home.cwav');

        if (CitroG.save.data == null) {
            CitroG.save.data = {};
        }

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

        headerText = new CitroText(8, 4, "CHAPTER 1");
        headerText.color = 0xFFFFFFFF;
        add(headerText);

        var slots:Array<Dynamic> = CitroG.save.data.slots;
        for (i in 0...3) {
            var slotBox = new CitroSprite(55, 55 + (i * 45));
            slotBox.makeGraphic(210, 40, 0xFF111122);
            add(slotBox);
            slotUIElements.push(slotBox);

            var slotData = slots[i];
            var displayText = slotData.created ? '${slotData.name}          ${slotData.playTime}' : '-------          --:--';
            
            var textObj = new CitroText(80, 63 + (i * 45), displayText);
            textObj.color = 0xFF888888;
            add(textObj);
            slotTexts.push(textObj);
        }

        var actionLabels = ["Copy", "Erase", "CH SELECT", "日本語"];
        var actionX = [54, 140, 204, 140];
        var actionY = [190, 190, 190, 210];

        for (i in 0...actionLabels.length) {
            var actText = new CitroText(actionX[i], actionY[i], actionLabels[i]);
            actText.color = 0xFF888888;
            add(actText);
            actionTexts.push(actText);
        }

        soulCursor = new CitroSprite(65, 72);
        soulCursor.loadGraphic("romfs:/assets/soul/soul.t3x");
        //soulCursor.makeGraphic(8, 8, 0xFFFF0000);
        add(soulCursor);

        super.create();
        updateVisualSelection();
        trace("MainMenuState loaded successfully.");
    }

    override public function update(delta:Int) {
        super.update(delta);

        var changed = false;

        if (HID.keyPressed(HIDKey.UP) || HID.keyPressed(HIDKey.CPAD_UP)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            navigateGrid(0, -1);
            changed = true;
        }
        if (HID.keyPressed(HIDKey.DOWN) || HID.keyPressed(HIDKey.CPAD_DOWN)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            navigateGrid(0, 1);
            changed = true;
        }
        if (HID.keyPressed(HIDKey.LEFT) || HID.keyPressed(HIDKey.CPAD_LEFT)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            navigateGrid(-1, 0);
            changed = true;
        }
        if (HID.keyPressed(HIDKey.RIGHT) || HID.keyPressed(HIDKey.CPAD_RIGHT)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            navigateGrid(1, 0);
            changed = true;
        }

        if (changed) {
            updateVisualSelection();
        }

        if (HID.keyPressed(HIDKey.A)) {
            executeAction();
        }

        if (HID.keyPressed(HIDKey.B)) {
            if (menuNo > 0) {
                menuNo = 0;
                SoundPlayer.playSound('romfs:/assets/sounds/snd_error.cwav');
                updateVisualSelection();
            }
        }
    }

    private function navigateGrid(dx:Int, dy:Int) {
        var currentSelection = menuCoords[menuNo];

        if (menuNo == 0) {
            if (dy < 0) {
                if (currentSelection > 0 && currentSelection < 3) currentSelection--;
                else if (currentSelection >= 3) currentSelection = 2;
            } else if (dy > 0) {
                if (currentSelection < 2) currentSelection++;
                else if (currentSelection == 3 || currentSelection == 4) currentSelection = 6;
                else if (currentSelection == 5) currentSelection = 7;
            }
            if (dx > 0) {
                if (currentSelection >= 3 && currentSelection < 5) currentSelection++;
                else if (currentSelection == 5) currentSelection = 3;
            } else if (dx < 0) {
                if (currentSelection > 3 && currentSelection <= 5) currentSelection--;
                else if (currentSelection == 3) currentSelection = 5;
            }
        } else {
            currentSelection += dy;
            if (currentSelection < 0) currentSelection = 3;
            if (currentSelection > 3) currentSelection = 0;
        }
        menuCoords[menuNo] = currentSelection;
    }

    private function updateVisualSelection() {
        var sel = menuCoords[menuNo];
        var targetX = 65;
        var targetY = 72;

        if (menuNo == 0) {
            if (sel <= 2) {
                targetX = 65;
                targetY = 72 + (sel * 45);
            } else if (sel == 3) {
                targetX = 40;
                targetY = 195;
            } else if (sel == 4) {
                targetX = 125;
                targetY = 195;
            } else if (sel == 5) {
                targetX = 190;
                targetY = 195;
            } else if (sel == 6) {
                targetX = 125;
                targetY = 215;
            } else if (sel == 7) {
                targetX = 190;
                targetY = 215;
            }
        }

        CitroTween.cancelTweensFrom(soulCursor);
        CitroTween.tweenObject(soulCursor, ["x" => targetX, "y" => targetY], 0.1, { ease: QUAD_OUT });
    }

    private function executeAction() {
        var sel = menuCoords[menuNo];
        if (menuNo == 0) {
            if (sel <= 2) {
                selectSlot(sel);
            } else if (sel == 3) {
                trace("Switching to Copy Mode");
                menuNo = 2;
            } else if (sel == 4) {
                trace("Switching to Erase Mode");
                menuNo = 5;
            } else if (sel == 6) {
                trace("Toggling Language options...");
            } else if (sel == 7) {
                trace("Exiting game program.");
            }
        }
        SoundPlayer.playSound('romfs:/assets/sounds/snd_shineselect.cwav');
    }

    private function selectSlot(slotIndex:Int) {
        var slots:Array<Dynamic> = CitroG.save.data.slots;
        var currentSlotData = slots[slotIndex];
        CitroG.save.data.currentSlot = slotIndex;

        if (!currentSlotData.created) {
            currentSlotData.created = true;
            currentSlotData.name = "KRIS";
            currentSlotData.room = "room_clost";
        }
        CitroG.save.flush();
        CitroG.switchState(new PlayState());
    }

    override public function destroy() {
        SoundPlayer.stopSound('romfs:/assets/sounds/home.cwav');
        super.destroy();
    }
}
#end
