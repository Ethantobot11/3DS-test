package;

import citro.CitroG;
import citro.object.CitroObject;
import citro.object.CitroSprite;
import haxe3ds.services.HID;
import citro.state.CitroState;

class OptionsState extends CitroState {

    /**
     * Current selected option index in the menu.
     */
    private var selectedIndex:Int = 0;

    /**
     * Total number of options available.
     */
    private final MAX_OPTIONS:Int = 3;

    /**
     * FPS Counter display properties.
     */
    private static var showFps:Bool = true;
    private var fpsSprite:CitroSprite;
    
    private var controlScheme:String = "Default (A: Confirm, B: Cancel)";

    public function new() {
        super();
    }

    override public function create() {
        super.create();

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

        trace("OptionsState loaded. Use UP/DOWN to navigate, A to toggle/change, B to exit.");
    }

    override public function update(delta:Int) {
        super.update(delta);

        if (HID.keyPressed(HIDKey.KEY_UP) || HID.keyPressed(HIDKey.CPAD_UP)) {
            selectedIndex--;
            if (selectedIndex < 0) selectedIndex = MAX_OPTIONS - 1;
            trace('Selected Option Index: $selectedIndex');
        }

        if (HID.keyPressed(HIDKey.KEY_DOWN) || HID.keyPressed(HIDKey.CPAD_DOWN)) {
            selectedIndex++;
            if (selectedIndex >= MAX_OPTIONS) selectedIndex = 0;
            trace('Selected Option Index: $selectedIndex');
        }

        if (HID.keyPressed(HIDKey.A)) {
            executeOptionAction(selectedIndex);
        }

        if (HID.keyPressed(HIDKey.B)) {
            executeOptionAction(selectedIndex);
            trace("Exiting Options Menu...");
        }

        if (showFps) {
            renderFpsCounter(delta);
        }
    }

    /**
     * Executes the action for the currently highlighted option.
     */
    private function executeOptionAction(index:Int) {
        switch (index) {
            case 0:
                showFps = !showFps;
                CitroG.save.data.options.fpsEnabled = showFps;
                CitroG.save.flush();
                trace('FPS Counter toggled: ${showFps ? "ON" : "OFF"}');

            case 1:
                var currentType:Int = CitroG.save.data.options.controlType;
                currentType = (currentType == 0) ? 1 : 0;
                CitroG.save.data.options.controlType = currentType;
                
                controlScheme = (currentType == 0) ? "Default (A: Confirm, B: Cancel)" : "Alternative (A: Action, X: Menu)";
                CitroG.save.flush();
                trace('Control Scheme changed to: $controlScheme');

            case 2:
                trace("Returning to Main Menu...");
                CitroG.switchState(new MainMenuState());
        }
    }

    /**
     * Simple utility to calculate and draw a basic text/frame update indicator on the top left.
     */
    private function renderFpsCounter(delta:Int) {
        // Calculate current FPS from delta time safely
        var currentFps:Int = delta > 0 ? Std.int(1000 / delta) : 60;
        
        // Note: If your engine has a text rendering utility (like CitroText), 
        // you would draw `currentFps` at coordinates X: 4, Y: 4 here.
        //CitroG.renderText('FPS: $currentFps', 4, 4, 0xFFFFFFFF);
    }

    override public function destroy() {
        super.destroy();
    }
}