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

class FNFPlaystate extends CitroState {
    public static var SONG:SwagSong = null;
    public static var storyDifficulty:Int = 1;
    
    public var notes:Array<Note> = [];
    public var unspawnNotes:Array<Note> = [];
    public var playerStrums:Array<StrumNote> = [];
    public var opponentStrums:Array<StrumNote> = [];
    
    public var health:Float = 1;
    public var songScore:Int = 0;
    public var songMisses:Int = 0;
    
    public var startingSong:Bool = false;
    public var startedCountdown:Bool = false;
    
    public var healthBar:CitroSprite;
    public var healthBarBG:CitroSprite;
    public var scoreTxt:CitroText;
    
    public var bf:CitroSprite;
    public var dad:CitroSprite;

    override public function create():Void {
        if (SONG == null) {
            trace("No song loaded!");
            CitroG.switchState(new FreeplayState());
            return;
        }
        
        Conductor.mapBPMChanges(SONG);
        Conductor.changeBPM(SONG.bpm);
        
        var bg = new CitroSprite(0, 0);
        bg.makeGraphic(CitroG.WIDTH, CitroG.HEIGHT, 0xFF111122);
        add(bg);
        
        dad = new CitroSprite(50, 100);
        dad.makeGraphic(40, 60, CitroColor.RED);
        add(dad);
        
        bf = new CitroSprite(250, 100);
        bf.makeGraphic(40, 60, 0xFF00FFFF);
        add(bf);
        
        healthBarBG = new CitroSprite(50, 210);
        healthBarBG.makeGraphic(300, 10, CitroColor.BLACK);
        add(healthBarBG);
        
        healthBar = new CitroSprite(50, 210);
        healthBar.makeGraphic(300, 10, CitroColor.GREEN);
        add(healthBar);
        
        scoreTxt = new CitroText(10, 10, "Score: 0 | Misses: 0");
        scoreTxt.scale.set(0.5, 0.5);
        scoreTxt.color = CitroColor.WHITE;
        add(scoreTxt);
        
        for (i in 0...4) {
            var strum = new StrumNote(20 + (i * 40), 20, i, 0);
            opponentStrums.push(strum);
            add(strum);
        }
        for (i in 0...4) {
            var strum = new StrumNote(220 + (i * 40), 20, i, 1);
            playerStrums.push(strum);
            add(strum);
        }
        
        generateSong();
        startCountdown();
        
        super.create();
    }
    
    function generateSong():Void {
        for (section in SONG.notes) {
            var sectionNotes:Array<Dynamic> = cast section.sectionNotes;
            for (songNotes in sectionNotes) {
                var daStrumTime:Float = songNotes[0];
                var daNoteData:Int = Std.int(songNotes[1] % 4);
                var gottaHitNote:Bool = section.mustHitSection;
                if (songNotes[1] > 3) gottaHitNote = !section.mustHitSection;
                
                var swagNote = new Note(daStrumTime, daNoteData);
                swagNote.mustPress = gottaHitNote;
                unspawnNotes.push(swagNote);
            }
        }
        unspawnNotes.sort((a, b) -> return Std.int(a.strumTime - b.strumTime));
    }
    
    function startCountdown():Void {
        startedCountdown = true;
        startingSong = true;
        Conductor.songPosition = -Conductor.crochet * 4; 
    }
    
    override public function update(delta:Int):Void {
        var elapsed:Float = delta / 1000.0;
        
        if (HID.keyPressed(HIDKey.START) || HID.keyPressed(HIDKey.SELECT)) {
            CitroG.switchState(new FreeplayState());
            return;
        }
        
        if (startedCountdown) {
            Conductor.songPosition += elapsed * 1000;
        }
        
        if (startingSong && Conductor.songPosition >= 0) {
            startSong();
        }
        
        while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < 1500) {
            var dunceNote:Note = unspawnNotes.shift();
            notes.push(dunceNote);
            add(dunceNote);
        }

        var i = notes.length - 1;
        while (i >= 0) {
            var daNote = notes[i];
            
            var strumGroup = daNote.mustPress ? playerStrums : opponentStrums;
            if (strumGroup.length > daNote.noteData) {
                var strumY = strumGroup[daNote.noteData].y;
                var dist = 0.45 * (Conductor.songPosition - daNote.strumTime);
                daNote.y = strumY + dist;
                daNote.x = strumGroup[daNote.noteData].x;
            }
            
            // Auto hit for opponent
            if (!daNote.mustPress && Conductor.songPosition >= daNote.strumTime && !daNote.wasGoodHit) {
                daNote.wasGoodHit = true;
                dad.color = CitroColor.YELLOW; 
            }
            
            // Miss for player
            if (daNote.mustPress && Conductor.songPosition > daNote.strumTime + Conductor.safeZoneOffset && !daNote.wasGoodHit) {
                noteMiss(daNote);
            }
            
            // Destroy note if way past
            if (Conductor.songPosition > daNote.strumTime + 500) {
                remove(daNote);
                notes.remove(daNote);
                daNote.destroy();
            }
            i--;
        }
        
        handleInputs();
        
        // Update Health Bar
        var healthPercent = CitroMath.clamp(health, 0, 2);
        healthBar.width = 300 * (healthPercent / 2);
        
        super.update(delta);
    }
    
    function startSong():Void {
        startingSong = false;
        var songName = SONG.song.toLowerCase().replace(" ", "-");
        // Plays the instrumental!
        SoundPlayer.playSound('romfs:/assets/songs/' + songName + '/Inst.cwav');
    }
    
    function handleInputs():Void {
        if (!startedCountdown || startingSong) return;
        
        var keys = [HIDKey.LEFT, HIDKey.DOWN, HIDKey.UP, HIDKey.RIGHT];
        var cpadKeys = [HIDKey.CPAD_LEFT, HIDKey.CPAD_DOWN, HIDKey.CPAD_UP, HIDKey.CPAD_RIGHT];
        
        for (i in 0...4) {
            var justPressed = HID.keyPressed(keys[i]) || HID.keyPressed(cpadKeys[i]);
            
            if (justPressed) {
                var hitNote:Note = null;
                for (daNote in notes) {
                    if (daNote.noteData == i && daNote.mustPress && daNote.canBeHit && !daNote.wasGoodHit) {
                        hitNote = daNote;
                        break;
                    }
                }
                
                if (hitNote != null) {
                    goodNoteHit(hitNote);
                    playerStrums[i].playConfirm();
                }
            }
        }
    }
    
    function goodNoteHit(note:Note):Void {
        note.wasGoodHit = true;
        health += note.hitHealth;
        if (health > 2) health = 2;
        
        songScore += 100;
        bf.color = CitroColor.YELLOW; 
        
        remove(note);
        notes.remove(note);
        note.destroy();
        
        updateUI();
    }
    
    function noteMiss(note:Note):Void {
        note.wasGoodHit = true; 
        health -= note.missHealth;
        if (health < 0) health = 0;
        
        songMisses++;
        SoundPlayer.playSound('romfs:/assets/sounds/missnote1.cwav'); 
        
        remove(note);
        notes.remove(note);
        note.destroy();
        
        if (health <= 0) {
            trace("Game Over!");
            CitroG.switchState(new FreeplayState());
        }
        
        updateUI();
    }
    
    function updateUI():Void {
        scoreTxt.text = 'Score: $songScore | Misses: $songMisses';
    }
}
