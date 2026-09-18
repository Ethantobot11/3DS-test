package;

#if (!wiiu || !cafe)

import citro.CitroG;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.state.CitroState;
import citro.backend.CitroColor;
import sys.FileSystem;

using StringTools;

class LoadingState extends CitroState
{
    var loadingText:CitroText;
    var filesToLoad:Array<String> = [];
    var currentIndex:Int = 0;
    var totalFiles:Int = 0;
    var loadComplete:Bool = false;
    var waitTimer:Float = 0;

    override public function create()
    {
        super.create();

        var bg = new CitroSprite(0, 0);
        bg.makeGraphic(CitroG.WIDTH, CitroG.HEIGHT, CitroColor.BLACK);
        add(bg);

        loadingText = new CitroText(40, 100, "Scanning assets...");
        loadingText.color = CitroColor.YELLOW;
        add(loadingText);

        var soundDir = "romfs:/assets/sounds";
        if (FileSystem.isDirectory(soundDir)) {
            scanDirectory(soundDir);
        }
        
        totalFiles = filesToLoad.length;

        if (totalFiles == 0) {
            loadingText.text = "No assets found. Starting...";
            loadComplete = true;
        } else {
            loadingText.text = 'Loading assets: 0 / $totalFiles';
        }
    }

    private function scanDirectory(path:String):Void
    {
        for (item in FileSystem.readDirectory(path)) {
            var fullPath = '$path/$item';
            if (FileSystem.isDirectory(fullPath)) {
                scanDirectory(fullPath);
            } else if (item.endsWith(".cwav")) {
                filesToLoad.push(fullPath);
            }
        }
    }

    override public function update(delta:Int)
    {
        super.update(delta);

        if (loadComplete) {
            waitTimer += delta / 1000.0;
            if (waitTimer >= 0.4) {
                CitroG.switchState(new IntroState());
            }
            return;
        }

        if (currentIndex < totalFiles) {
            var fullPath = filesToLoad[currentIndex];
            SoundPlayer.preload(fullPath);
            trace('Preloaded: $fullPath');

            currentIndex++;
            loadingText.text = 'Loading assets: $currentIndex / $totalFiles';

            if (currentIndex >= totalFiles) {
                loadingText.text = "Loading complete!";
                loadComplete = true;
            }
        }
    }
}

#end
