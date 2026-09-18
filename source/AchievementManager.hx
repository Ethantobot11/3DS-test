package;

import citro.CitroG;

class AchievementManager {
    public static var registry:Map<String, {title:String, desc:String, iconPath:String}> = [
        "play_DELTARUNE_3DS" => {
            title: "Play DELTARUNE 3DS",
            desc: "Play for the first time.",
            iconPath: "romfs:/assets/sprites/achievements/play_DELTARUNE_3DS.t3x"
        },
        "first_steps" => {
            title: "First Steps",
            desc: "Awaken in the dark room.",
            iconPath: "romfs:/assets/sprites/achievements/first_steps.t3x"
        },
        "boss_defeated" => {
            title: "Challenger",
            desc: "Defeat your first encounter.",
            iconPath: "romfs:/assets/sprites/achievements/boss_defeated.t3x"
        },
        "secret_hunter" => {
            title: "Secret Hunter",
            desc: "Discover a hidden pathway.",
            iconPath: "romfs:/assets/sprites/achievements/secret_hunter.t3x"
        }
    ];

    /**
     * Unlocks an achievement using only its string ID.
     */
    public static function unlock(id:String) {
        if (CitroG.save.data.achievements == null) {
            CitroG.save.data.achievements = {};
        }

        var currentStatus = Reflect.field(CitroG.save.data.achievements, id);
        if (currentStatus != true) {
            Reflect.setField(CitroG.save.data.achievements, id, true);
            CitroG.save.flush();

            var info = registry.get(id);
            if (info != null) {
                AchievementPopup.show(info.title, info.desc, info.iconPath);
                trace('Achievement Unlocked: ${info.title}');
            } else {
                trace('Warning: Unlocked achievement ID "$id" but it was not found in the registry.');
            }
        }
    }
}
