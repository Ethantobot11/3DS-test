package citro.backend;

class CitroSoundSystem {
    public var volume:Float = 1.0;
    public var muted:Bool = false;
    public var activeSounds:Array<CitroSound> = [];

    public function new() {
        #if (!wiiu || !cafe)
        untyped __cpp__("cwavUseEnvironment(0)");
        #end
    }

    public function play(path:String, ?vol:Float = 1.0, ?looped:Bool = false):CitroSound {
        var sound = new CitroSound(path);
        sound.volume = muted ? 0.0 : (vol != null ? vol : this.volume);
        sound.looped = looped;
        sound.play();
        activeSounds.push(sound);
        return sound;
    }

    public function load(path:String):CitroSound {
        var sound = new CitroSound(path);
        sound.volume = muted ? 0.0 : this.volume;
        sound.load();
        activeSounds.push(sound);
        return sound;
    }

    public function stopSound(sound:CitroSound):Void {
        if (sound != null) {
            sound.stop();
            activeSounds.remove(sound);
        }
    }

    public function stop(path:String):Void {
        stopByPath(path);
    }

    public function stopByPath(path:String):Void {
        var i = activeSounds.length;
        while (i-- > 0) {
            var sound = activeSounds[i];
            if (sound != null && sound.path == path) {
                sound.stop();
                activeSounds.remove(sound);
            }
        }
    }

    public function stopAll():Void {
        for (sound in activeSounds) {
            if (sound != null) {
                sound.stop();
            }
        }
        activeSounds = [];
    }

    public function update():Void {
        var i = activeSounds.length;
        while (i-- > 0) {
            var sound = activeSounds[i];
            if (sound != null) {
                sound.update();
                if (!sound.looped && !sound.isPlaying && sound.wasPlaying) {
                    activeSounds.remove(sound);
                }
            }
        }
    }
}