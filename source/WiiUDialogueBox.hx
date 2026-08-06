package objects;

import leafy.objects.LfSprite;
import leafy.objects.LfText;
import leafy.gamepad.LfGamepad;
import leafy.backend.LeafyDebug;
import leafy.filesystem.LfSystemPaths;

class DialogueBox extends LfSprite
{
    var boxBg:LfSprite;
    var boxBorder:LfSprite;
    public var portrait:LfSprite;
    var textDisplay:LfText;

    public var soulCursor:LfSprite;
    var optionYesText:LfText;
    var optionNoText:LfText;

    var fullText:String = "";
    var currentText:String = "";
    var charIndex:Int = 0;
    var typeTimer:Float = 0;
    var typeInterval:Float = 0.03;
    var soundAsset:String = "snd_txtnoe.wav";

    public var isFinished:Bool = false;
    public var hasChoices:Bool = false;
    public var isChoosing:Bool = false;
    public var selectedIndex:Int = 0;

    private var gamepad:LfGamepad;
    private var defaultFontPath:String = "assets/fonts/determination.ttf"; // Change to your project's font path

    public function new(x:Float, y:Float)
    {
        super(Std.int(x), Std.int(y));
        gamepad = new LfGamepad();

        boxBorder = new LfSprite(Std.int(x), Std.int(y));
        boxBorder.createGraphic(280, 68, [255, 255, 255, 255]);

        boxBg = new LfSprite(Std.int(x + 3), Std.int(y + 3));
        boxBg.createGraphic(274, 62, [0, 0, 0, 255]);

        portrait = new LfSprite(Std.int(x + 8), Std.int(y + 6));
        portrait.isVisible = false;

        // Initialize LfText using standard Leafy constructor (X, Y, Text, Size, FontPath)
        textDisplay = new LfText(Std.int(x + 15), Std.int(y + 10), "", 20, defaultFontPath);

        soulCursor = new LfSprite(0, 0);
        if (LfSystemPaths.exists(LfSystemPaths.getConsolePath() + "assets/images/soul/iconOG.png"))
        {
            soulCursor.loadImage("assets/images/soul/iconOG.png");
        }
        else
        {
            soulCursor.createGraphic(8, 8, [255, 0, 0, 255]);
        }
        soulCursor.isVisible = false;

        optionYesText = new LfText(Std.int(x + 210), Std.int(y + 18), "YES", 20, defaultFontPath);
        optionYesText.isVisible = false;

        optionNoText = new LfText(Std.int(x + 210), Std.int(y + 36), "NO", 20, defaultFontPath);
        optionNoText.isVisible = false;

        isVisible = false;
    }

    public function startDialogue(text:String, faceAtlas:String = null, expressionFrame:String = null, style:String = "light", withChoices:Bool = false, snd:String = "snd_txtnoe.wav"):Void
    {
        if (style == "dark")
        {
            boxBorder.createGraphic(280, 68, [0, 0, 128, 255]);
        }
        else
        {
            boxBorder.createGraphic(280, 68, [255, 255, 255, 255]);
        }

        fullText = text;
        currentText = "";
        charIndex = 0;
        isFinished = false;
        hasChoices = withChoices;
        isChoosing = false;
        soundAsset = snd;
        isVisible = true;

        soulCursor.isVisible = false;
        optionYesText.isVisible = false;
        optionNoText.isVisible = false;

        if (faceAtlas != null && expressionFrame != null)
        {
            portrait.loadGraphicFromXml('assets/images/${faceAtlas}.png', 'assets/images/${faceAtlas}.xml');
            portrait.addAnimationByPrefix("expression", expressionFrame, 0, false);
            portrait.playAnimation("expression");
            portrait.isVisible = true;

            textDisplay.x = Std.int(x + 68);
            textDisplay.sdlRect.x = textDisplay.x;
        }
        else
        {
            portrait.isVisible = false;
            textDisplay.x = Std.int(x + 15);
            textDisplay.sdlRect.x = textDisplay.x;
        }

        textDisplay.setText("");
        typeTimer = 0;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (isVisible && !isFinished)
        {
            typeTimer += elapsed;
            if (typeTimer >= typeInterval)
            {
                typeTimer = 0;
                if (charIndex < fullText.length)
                {
                    var char = fullText.charAt(charIndex);
                    currentText += char;
                    textDisplay.setText(currentText);

                    if (char != " " && char != "\n")
                    {
                        var audioEngine = new leafy.audio.LfAudioEngine();
                        audioEngine.play('assets/sounds/${soundAsset}', false);
                    }
                    charIndex++;
                }
                else
                {
                    onDialogueFinished();
                }
            }
        }
    }

    public function skipTyping():Void
    {
        currentText = fullText;
        textDisplay.setText(currentText);
        onDialogueFinished();
    }

    private function onDialogueFinished():Void
    {
        isFinished = true;

        if (hasChoices)
        {
            showChoices();
        }
    }

    private function showChoices():Void
    {
        isChoosing = true;
        selectedIndex = 0;

        optionYesText.isVisible = true;
        optionNoText.isVisible = true;
        soulCursor.isVisible = true;

        updateCursorPosition();
    }

    public function navigateChoices(up:Bool, down:Bool):Void
    {
        if (!isChoosing) return;

        if (up && selectedIndex > 0)
        {
            selectedIndex = 0;
            updateCursorPosition();
        }
        else if (down && selectedIndex < 1)
        {
            selectedIndex = 1;
            updateCursorPosition();
        }
    }

    private function updateCursorPosition():Void
    {
        soulCursor.x = Std.int(x + 196);
        soulCursor.y = Std.int(y + (selectedIndex == 0 ? 20 : 38));
        soulCursor.sdlRect.x = soulCursor.x;
        soulCursor.sdlRect.y = soulCursor.y;
    }

    override public function destroy():Void
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