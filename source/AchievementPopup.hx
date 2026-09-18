package;

#if (!wiiu || !cafe)
import citro.CitroG;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.backend.CitroTween;
import citro.backend.CitroTimer;

class AchievementPopup {
    private static var background:CitroSprite;
    private static var iconSprite:CitroSprite;
    private static var titleText:CitroText;
    private static var descText:CitroText;
    private static var isShowing:Bool = false;

    /**
     * Triggers an achievement notification banner on screen.
     */
    public static function show(title:String, description:String, iconPath:String) {
        if (isShowing) return;
        isShowing = true;

        SoundPlayer.playSound('romfs:/assets/sounds/snd_save.cwav');

        background = new CitroSprite(40, -60);
        background.makeGraphic(320, 50, 0xFF11112B);
        
        iconSprite = new CitroSprite(46, -54);
        if (!iconSprite.loadGraphic(iconPath)) {
            iconSprite.makeGraphic(32, 32, 0xFF00FF00);
        }

        titleText = new CitroText(84, -54, "ACHIEVEMENT UNLOCKED!");
        titleText.color = 0xFFFFD700;

        descText = new CitroText(84, -36, title);
        descText.color = 0xFFFFFFFF;

        CitroTween.tweenObject(background, ["y" => 10], 0.3, { ease: QUAD_OUT });
        CitroTween.tweenObject(iconSprite, ["y" => 16], 0.3, { ease: QUAD_OUT });
        CitroTween.tweenObject(titleText, ["y" => 16], 0.3, { ease: QUAD_OUT });
        CitroTween.tweenObject(descText, ["y" => 34], 0.3, { ease: QUAD_OUT });

        CitroTimer.start(3.5, function() {
            dismiss();
        });
    }

    private static function dismiss() {
        CitroTween.tweenObject(background, ["y" => -60], 0.3, { ease: QUAD_IN });
        CitroTween.tweenObject(iconSprite, ["y" => -54], 0.3, { ease: QUAD_IN });
        CitroTween.tweenObject(titleText, ["y" => -54], 0.3, { ease: QUAD_IN });
        CitroTween.tweenObject(descText, ["y" => -36], 0.3, { ease: QUAD_IN });

        CitroTimer.start(0.3, function() {
            isShowing = false;
        });
    }
}
#end
