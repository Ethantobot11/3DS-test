package;

import citro.CitroG;
import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.math.CitroMath;
import citro.backend.CitroColor;
import haxe3ds.services.HID;
import haxe3ds.services.HID.HIDKey;
import Song.SwagSong;

using StringTools;

class FreeplayState extends CitroState
{
    var songs:Array<SongMetadata> = [];
    var curSelected:Int = 0;
    var curDifficulty:Int = 0;
    
    var difficulties:Array<String> = ["easy", "normal", "hard"];

    var scoreText:CitroText;
    var diffText:CitroText;

    private var songTexts:Array<CitroText> = [];
    private var iconArray:Array<HealthIcon> = [];

    var bg:CitroSprite;
    
    override function create()
    {
        songs.push(new SongMetadata("bopeebo", "dad", 0xFF9271FD));
        songs.push(new SongMetadata("fresh", "dad", 0xFF9271FD));
        songs.push(new SongMetadata("dad-battle", "dad", 0xFF9271FD));

        bg = new CitroSprite();
        bg.loadGraphic('romfs:/assets/images/menuBG.t3x');
        bg.scale.set(0.35, 0.35);
        bg.screenCenter();
        add(bg);

        var listBG = new CitroSprite(20, 40);
        listBG.makeGraphic(CitroG.WIDTH - 40, 120, 0x88000000);
        add(listBG);

        for (i in 0...songs.length) {
            var songText:CitroText = new CitroText(0, 50 + (i * 30), songs[i].songName);
            songText.scale.set(0.6, 0.6);
            songText.color = 0xFFFFFFFF;
            
            songText.x = (400 / 2) - ((songText.width * 0.6) / 2); 
            
            songTexts.push(songText);
            add(songText);

            var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
            icon.sprTracker = songText;
            icon.scale.set(0.4, 0.4);
            icon.x = songText.x - 40; 
            icon.y = songText.y - 5;
            iconArray.push(icon);
            add(icon);
        }

        scoreText = new CitroText(CitroG.WIDTH - 10, 5, "BEST: 0");
        scoreText.alignment = RIGHT;
        scoreText.scale.set(0.5, 0.5);
        scoreText.color = 0xFFFFFFFF;
        add(scoreText);

        diffText = new CitroText(0, 160, "< normal >");
        diffText.scale.set(0.6, 0.6);
        diffText.color = 0xFFFFFFFF;
        diffText.screenCenter(X);
        add(diffText);

        var textBG:CitroSprite = new CitroSprite(0, CitroG.HEIGHT - 16).makeGraphic(CitroG.WIDTH, 16, 0xCC000000);
        add(textBG);

        var text:CitroText = new CitroText(5, textBG.y + 2, "A:Play  B:Back  L/R:Diff");
        text.alignment = LEFT;
        text.scale.set(0.4, 0.4);
        text.color = 0xFFFFFFFF;
        add(text);
        
        changeSelection();
        changeDiff();
        
        super.create();
    }

    override function update(delta:Int) 
    {
        if (HID.keyPressed(HIDKey.UP) || HID.keyPressed(HIDKey.CPAD_UP)) changeSelection(-1);
        if (HID.keyPressed(HIDKey.DOWN) || HID.keyPressed(HIDKey.CPAD_DOWN)) changeSelection(1);

        if (HID.keyPressed(HIDKey.LEFT) || HID.keyPressed(HIDKey.CPAD_LEFT)) changeDiff(-1);
        if (HID.keyPressed(HIDKey.RIGHT) || HID.keyPressed(HIDKey.CPAD_RIGHT)) changeDiff(1);

        if (HID.keyPressed(HIDKey.B)) {
            SoundPlayer.playSound('romfs:/assets/sounds/cancelMenu.cwav');
            trace("Backing out of Freeplay...");
            CitroG.switchState(new PlayState());
        }

        if (HID.keyPressed(HIDKey.A)) {
            SoundPlayer.playSound('romfs:/assets/sounds/confirmMenu.cwav');
            
            var songName = songs[curSelected].songName.toLowerCase().replace(" ", "-");
            var chart = ChartParser.parse(songName);
            
            if (chart != null) {
                FNFPlaystate.SONG = chart;
                FNFPlaystate.storyDifficulty = curDifficulty;
                CitroG.switchState(new FNFPlaystate());
            } else {
                trace("Chart not found for " + songName);
            }
        }

        super.update(delta);
    }

    function changeDiff(change:Int = 0):Void {
        curDifficulty += change;
        if (curDifficulty < 0) curDifficulty = difficulties.length - 1;
        if (curDifficulty >= difficulties.length) curDifficulty = 0;

        diffText.text = '< ' + difficulties[curDifficulty] + ' >';
    }

    function changeSelection(change:Int = 0) {
        SoundPlayer.playSound('romfs:/assets/sounds/scrollMenu.cwav');
        curSelected += change;
        if (curSelected < 0) curSelected = songs.length - 1;
        if (curSelected >= songs.length) curSelected = 0;

        for (i in 0...iconArray.length) iconArray[i].alpha = 0.6;
        iconArray[curSelected].alpha = 1;

        for (i in 0...songTexts.length) {
            songTexts[i].alpha = 0.6;
            if (i == curSelected) songTexts[i].alpha = 1;
        }
    }
}

class SongMetadata {
    public var songName:String = "";
    public var songCharacter:String = "";
    public var color:CitroColor = 0xFF9271FD;

    public function new(song:String, songCharacter:String, color:CitroColor) {
        this.songName = song;
        this.songCharacter = songCharacter;
        this.color = color;
    }
}
