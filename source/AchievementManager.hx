import citro.CitroG;
import citro.CitroSave;

class AchievementManager {
    public static function unlock(achievementID:String) {
        if (CitroG.save.data.achievements == null) {
            CitroG.save.data.achievements = {};
        }

        var currentStatus = Reflect.field(CitroG.save.data.achievements, achievementID);
        if (currentStatus != true) {
            Reflect.setField(CitroG.save.data.achievements, achievementID, true);
            CitroG.save.flush();
            
            trace('Achievement Unlocked: $achievementID');
            SoundPlayer.playSound('romfs:/assets/sounds/snd_save.cwav');
        }
    }
}
