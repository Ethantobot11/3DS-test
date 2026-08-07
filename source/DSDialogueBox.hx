package;
#if (!wiiu || !cafe)

import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.backend.CitroColor;
import citro.backend.CitroTimer;
import citro.CitroG;
using StringTools;

class DSDialogueBox extends citro.object.CitroObject
{
    var boxBg:CitroSprite;
    var boxBorder:CitroSprite;
    public var portrait:CitroSprite;
    var textDisplay:CitroText;

    public var soulCursor:CitroSprite;
    var optionYesText:CitroText;
    var optionNoText:CitroText;

    var fullText:String = "";
    var currentText:String = "";
    var charIndex:Int = 0;
    var soundAsset:String = "snd_txtnoe.cwav";

    public var isFinished:Bool = false;
    public var hasChoices:Bool = false;
    public var isChoosing:Bool = false;
    public var selectedIndex:Int = 0;

    public function new(xPos:Float, yPos:Float)
    {
        super();
        this.x = xPos;
        this.y = yPos;

        boxBorder = new CitroSprite(0, 0);
        boxBorder.makeGraphic(280, 68, CitroColor.WHITE);

        boxBg = new CitroSprite(3, 3);
        boxBg.makeGraphic(274, 62, CitroColor.BLACK);

        // Portrait is now an animated sprite inheriting/using CitroAnimate capabilities via portrait object or frame-switching
        portrait = new CitroSprite(8, 6);
        portrait.visible = false;

        textDisplay = new CitroText(15, 10, "");
        textDisplay.color = CitroColor.WHITE;

        soulCursor = new CitroSprite(0, 0);
        try {
            if (sys.FileSystem.exists("romfs:/assets/images/soul/iconOG.png")) {
                soulCursor.loadGraphic("romfs:/assets/images/soul/iconOG.png");
            } else {
                soulCursor.makeGraphic(8, 8, CitroColor.RED);
            }
        } catch (e:Dynamic) {
            soulCursor.makeGraphic(8, 8, CitroColor.RED);
        }
        soulCursor.visible = false;

        optionYesText = new CitroText(210, 18, "YES");
        optionYesText.color = CitroColor.WHITE;
        optionYesText.visible = false;

        optionNoText = new CitroText(210, 36, "NO");
        optionNoText.color = CitroColor.WHITE;
        optionNoText.visible = false;

        visible = false;
    }

    public function startDialogue(text:String, faceAtlas:String = null, expressionFrame:String = null, style:String = "light", withChoices:Bool = false, snd:String = "snd_txtnoe.cwav")
    {
        boxBorder.makeGraphic(280, 68, (style == "dark") ? 0xFF000080 : CitroColor.WHITE);

        fullText = text;
        currentText = "";
        charIndex = 0;
        isFinished = false;
        hasChoices = withChoices;
        isChoosing = false;
        soundAsset = snd;
        visible = true;

        soulCursor.visible = false;
        optionYesText.visible = false;
        optionNoText.visible = false;

        if (faceAtlas != null && expressionFrame != null)
        {
            var ceaPath = 'romfs:/assets/images/${faceAtlas}.cea';
            if (sys.FileSystem.exists(ceaPath))
            {
                var file:String = sys.io.File.getContent(ceaPath);
                var dir:String = "romfs:/assets/images/chars";
                
                for (line in file.split("\n"))
                {
                    if (line.trim() == "") continue;
                    var row:Array<String> = line.split("?");
                    if (row.length < 3) continue;
                    var frameKey = row[3].trim();
                    
                    if (frameKey == expressionFrame || frameKey.indexOf(expressionFrame) != -1)
                    {
                        portrait.loadGraphic('$dir/${row[0]}');
                        break;
                    }
                }
            }
            portrait.visible = true;
            textDisplay.x = x + 68;
        }

        textDisplay.text = "";
        typeNextLetter();
    }

    private function typeNextLetter()
    {
        if (charIndex < fullText.length)
        {
            var char = fullText.charAt(charIndex);
            currentText += char;
            textDisplay.text = currentText;

            if (char != " " && char != "\n")
            {
                SoundPlayer.playSound('romfs:/assets/sounds/${soundAsset}');
            }

            charIndex++;
            CitroTimer.start(0.03, typeNextLetter, 1);
        }
        else
        {
            onDialogueFinished();
        }
    }

    public function skipTyping()
    {
        currentText = fullText;
        textDisplay.text = currentText;
        onDialogueFinished();
    }

    private function onDialogueFinished()
    {
        isFinished = true;

        if (hasChoices)
        {
            showChoices();
        }
    }

    private function showChoices()
    {
        isChoosing = true;
        selectedIndex = 0;

        optionYesText.visible = true;
        optionNoText.visible = true;
        soulCursor.visible = true;

        updateCursorPosition();
    }

    public function navigateChoices(up:Bool, down:Bool)
    {
        if (!isChoosing) return;

        if (up && selectedIndex > 0)
        {
            selectedIndex = 0;
            SoundPlayer.playSound("romfs:/assets/sounds/snd_text.cwav");
            updateCursorPosition();
        }
        else if (down && selectedIndex < 1)
        {
            selectedIndex = 1;
            SoundPlayer.playSound("romfs:/assets/sounds/snd_text.cwav");
            updateCursorPosition();
        }
    }

    private function updateCursorPosition()
    {
        soulCursor.x = x + 196;
        soulCursor.y = y + (selectedIndex == 0 ? 20 : 38);
    }

    override public function update():Bool
    {
        if (!visible) return false;

        boxBorder.x = x;
        boxBorder.y = y;
        boxBorder.update();

        boxBg.x = x + 3;
        boxBg.y = y + 3;
        boxBg.update();

        if (portrait.visible)
        {
            portrait.x = x + 8;
            portrait.y = y + 6;
            portrait.update();
        }

        textDisplay.x = portrait.visible ? (x + 68) : (x + 15);
        textDisplay.y = y + 10;
        textDisplay.update();

        if (optionYesText.visible)
        {
            optionYesText.x = x + 210;
            optionYesText.y = y + 18;
            optionYesText.update();
        }

        if (optionNoText.visible)
        {
            optionNoText.x = x + 210;
            optionNoText.y = y + 36;
            optionNoText.update();
        }

        if (soulCursor.visible)
        {
            soulCursor.update();
        }

        return true;
    }

    override public function destroy()
    {
        if (boxBg != null) boxBg.destroy();
        if (boxBorder != null) boxBorder.destroy();
        if (portrait != null) portrait.destroy();
        if (textDisplay != null) textDisplay.destroy();
        if (soulCursor != null) soulCursor.destroy();
        if (optionYesText != null) optionYesText.destroy();
        if (optionNoText != null) optionNoText.destroy();
        super.destroy();
    }
}

#end