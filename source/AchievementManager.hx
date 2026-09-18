import citro.CitroG;
import citro.CitroSave;

class AchievementManager {
    public static function unlock(id:String, title:String, desc:String, iconPath:String) {
        if (CitroG.save.data.achievements == null) {
            CitroG.save.data.achievements = {};
        }
    
        var currentStatus = Reflect.field(CitroG.save.data.achievements, id);
        if (currentStatus != true) {
            Reflect.setField(CitroG.save.data.achievements, id, true);
            CitroG.save.flush();
    
            AchievementPopup.show(title, desc, iconPath);
        }
    }
}
