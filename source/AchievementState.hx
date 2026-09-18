package;

#if (!wiiu || !cafe)
import citro.CitroG;
import citro.object.CitroObject;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.state.CitroState;
import haxe3ds.services.HID;

class AchievementState extends CitroState {
    private var selectedIndex:Int = 0;
    private var achievements:Array<{id:String, title:String, desc:String, unlocked:Bool}> = [];
    private var uiElements:Array<CitroSprite> = [];
    private var iconElements:Array<CitroSprite> = [];
    private var soulCursor:CitroSprite;

    override public function create() {
        super.create();

        loadAchievements();

        var bg = new CitroSprite(0, 0);
        bg.makeGraphic(CitroG.WIDTH, CitroG.HEIGHT, 0xFF0A0A1E);
        add(bg);

        var titleText = new CitroText(50, 10, "ACHIEVEMENTS");
        titleText.color = 0xFFFFFFFF;
        add(titleText);

        for (i in 0...achievements.length) {
            var ach = achievements[i];
            
            var box = new CitroSprite(40, 35 + (i * 45));
            box.makeGraphic(320, 40, ach.unlocked ? 0xFF1B3B1B : 0xFF222244);
            add(box);
            uiElements.push(box);

            var icon = new CitroSprite(45, 39 + (i * 45));
            var assetPath = 'romfs:/assets/sprites/achievements/${ach.id}.t3x';
            
            if (!icon.loadGraphic(assetPath)) {
                icon.makeGraphic(32, 32, ach.unlocked ? 0xFF00FF00 : 0xFF555555);
            }
            add(icon);
            iconElements.push(icon);

            var displayText = ach.unlocked ? '${ach.title}\n${ach.desc}' : '???\nLocked Achievement';
            var txt = new CitroText(85, 39 + (i * 45), displayText);
            txt.color = ach.unlocked ? 0xFFFFFFFF : 0xFF888888;
            add(txt);
        }

        soulCursor = new CitroSprite(25, 51);
        soulCursor.makeGraphic(8, 8, 0xFFFF0000);
        add(soulCursor);

        updateVisualSelection();
    }

    override public function update(delta:Int) {
        super.update(delta);

        if (HID.keyPressed(HIDKey.UP) || HID.keyPressed(HIDKey.CPAD_UP)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            selectedIndex--;
            if (selectedIndex < 0) selectedIndex = achievements.length - 1;
            updateVisualSelection();
        }

        if (HID.keyPressed(HIDKey.DOWN) || HID.keyPressed(HIDKey.CPAD_DOWN)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            selectedIndex++;
            if (selectedIndex >= achievements.length) selectedIndex = 0;
            updateVisualSelection();
        }

        if (HID.keyPressed(HIDKey.B)) {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_select.cwav');
            CitroG.switchState(new ThreeDSMainMenuState());
        }
    }

    private function loadAchievements() {
        if (CitroG.save.data.achievements == null) {
            CitroG.save.data.achievements = {
                first_steps: false,
                boss_defeated: false,
                secret_hunter: false
            };
            CitroG.save.flush();
        }

        var saved = CitroG.save.data.achievements;

        achievements = [
            { id: "play_DELTARUNE_3DS", title: "Play DELTARUNE 3DS", desc: "Play for the first time.", unlocked: saved.play_DELTARUNE_3DS },
            { id: "first_steps", title: "First Steps", desc: "Awaken in the dark room.", unlocked: saved.first_steps },
            { id: "boss_defeated", title: "Challenger", desc: "Defeat your first encounter.", unlocked: saved.boss_defeated },
            { id: "secret_hunter", title: "Secret Hunter", desc: "Discover a hidden pathway.", unlocked: saved.secret_hunter }
        ];
    }

    private function updateVisualSelection() {
        for (i in 0...uiElements.length) {
            var ach = achievements[i];
            if (i == selectedIndex) {
                uiElements[i].makeGraphic(320, 40, ach.unlocked ? 0xFF2A5A2A : 0xFF444488);
            } else {
                uiElements[i].makeGraphic(320, 40, ach.unlocked ? 0xFF1B3B1B : 0xFF222244);
            }
        }
        soulCursor.y = 51 + (selectedIndex * 45);
    }
}
#end
