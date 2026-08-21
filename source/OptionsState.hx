package;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.object.CitroObject;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.backend.CitroTimer;
import haxe3ds.services.HID;
import citro.state.CitroState;

class OptionsState extends CitroState {

    private var selectedIndex:Int = 0;
    private final MAX_OPTIONS:Int = 3;

    private static var showFps:Bool = true;
    private var controlScheme:String = "Default (A: Confirm, B: Cancel)";

    private var optionBoxes:Array<CitroSprite> = [];
    private var optionTexts:Array<CitroText> = [];

    private var currentDelta:Int = 16;

    public function new() {
        super();
    }

    override public function create() {
        trace("Entering OptionsState.create()...");

        if (CitroG.save.data.options == null) {
            CitroG.save.data.options = {
                fpsEnabled: true,
                controlType: 0
            };
            CitroG.save.flush();
        } else {
            showFps = CitroG.save.data.options.fpsEnabled;
        }

        var bg = new CitroSprite(0, 0);
        bg.makeGraphic(CitroG.WIDTH, CitroG.HEIGHT, 0xFF141428);
        add(bg);

        for (i in 0...MAX_OPTIONS) {
            var box = new CitroSprite(40, 50 + (i * 50));
            box.makeGraphic(240, 40, 0xFF222244);
            add(box);
            optionBoxes.push(box);

            var label = getOptionText(i);
            var textObj = new CitroText(50, 58 + (i * 50), label);
            textObj.color = 0xFFFFFFFF;
            add(textObj);
            optionTexts.push(textObj);
        }

        super.create();

        updateVisualSelection();
        trace("OptionsState loaded.");
    }

    override public function update(delta:Int) {
        super.update(delta);

        var changed = false;

        if (HID.keyPressed(HIDKey.UP) || HID.keyPressed(HIDKey.CPAD_UP)) {
            selectedIndex--;
            if (selectedIndex < 0) selectedIndex = MAX_OPTIONS - 1;
            changed = true;
        }
        
        if (HID.keyPressed(HIDKey.DOWN) || HID.keyPressed(HIDKey.CPAD_DOWN)) {
            selectedIndex++;
            if (selectedIndex >= MAX_OPTIONS) selectedIndex = 0;
            changed = true;
        }

        if (changed) {
            updateVisualSelection();
        }

        if (HID.keyPressed(HIDKey.A)) {
            executeOptionAction(selectedIndex);
            refreshOptionTexts();
        }

        if (HID.keyPressed(HIDKey.B)) {
            trace("Exiting Options Menu...");
            CitroG.switchState(new ThreeDSMainMenuState());
        }

        if (CitroState.fpsText != null) {
            CitroState.fpsText.visible = showFps;
        }
    }

    private function getOptionText(index:Int):String {
        switch (index) {
            case 0: return 'FPS Counter: ${showFps ? "ON" : "OFF"}';
            case 1: return 'Controls: ${CitroG.save.data.options.controlType == 0 ? "Default" : "Alt"}';
            case 2: return "Back to Main Menu";
            default: return "";
        }
    }

    private function refreshOptionTexts() {
        for (i in 0...optionTexts.length) {
            optionTexts[i].text = getOptionText(i);
        }
    }

    private function updateVisualSelection() {
        for (i in 0...optionBoxes.length) {
            if (i == selectedIndex) {
                optionBoxes[i].makeGraphic(240, 40, 0xFF444488);
            } else {
                optionBoxes[i].makeGraphic(240, 40, 0xFF222244);
            }
        }
    }

    private function executeOptionAction(index:Int) {
        switch (index) {
            case 0:
                showFps = !showFps;
                CitroG.save.data.options.fpsEnabled = showFps;
                CitroG.save.flush();
            case 1:
                var currentType:Int = CitroG.save.data.options.controlType;
                currentType = (currentType == 0) ? 1 : 0;
                CitroG.save.data.options.controlType = currentType;
                CitroG.save.flush();
            case 2:
                CitroG.switchState(new ThreeDSMainMenuState());
        }
    }

    override public function destroy() {
        CitroTimer.reset();
        super.destroy();
    }
}

#end
