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
    
    var chunkSize:Int = 15;

    override public function create()
    {
        super.create();
        trace("LoadingState: Initializing asset scanning...");

        var bg = new CitroSprite(0, 0);
        bg.makeGraphic(CitroG.WIDTH, CitroG.HEIGHT, CitroColor.BLACK);
        add(bg);

        loadingText = new CitroText(40, 100, "Scanning directories...");
        loadingText.color = CitroColor.YELLOW;
        add(loadingText);

        var assetsDir = "romfs:/assets";
        if (FileSystem.isDirectory(assetsDir)) {
            scanDirectory(assetsDir);
        } else {
            trace("WARNING: Assets directory not found at romfs:/assets");
        }
        
        totalFiles = filesToLoad.length;
        trace('LoadingState: Found $totalFiles total assets to preload (.cwav & .t3x).');

        if (totalFiles == 0) {
            loadingText.text = "No assets found. Starting...";
            loadComplete = true;
        } else {
            loadingText.text = 'Preloading: 0 / $totalFiles';
        }
    }

    private function scanDirectory(path:String):Void
    {
        try {
            for (item in FileSystem.readDirectory(path)) {
                var fullPath = '$path/$item';
                if (FileSystem.isDirectory(fullPath)) {
                    scanDirectory(fullPath);
                } else if (item.endsWith(".cwav") || item.endsWith(".t3x")) {
                    filesToLoad.push(fullPath);
                }
            }
        } catch (e:Dynamic) {
            trace('Error scanning directory $path: $e');
        }
    }

    override public function update(delta:Int)
    {
        super.update(delta);

        if (loadComplete) {
            waitTimer += delta / 1000.0;
            if (waitTimer >= 0.5) {
                trace("LoadingState: Transitioning to IntroState.");
                CitroG.switchState(new IntroState());
            }
            return;
        }

        var batchCount = 0;
        while (batchCount < 5 && currentIndex < totalFiles) {
            var fullPath = filesToLoad[currentIndex];
            if (fullPath.endsWith(".cwav")) {
                SoundPlayer.preload(fullPath);
            }
            currentIndex++;
            batchCount++;
        }

        loadingText.text = 'Loading: $currentIndex / $totalFiles';
        trace('Loading progress: $currentIndex / $totalFiles');

        if (currentIndex >= totalFiles) {
            trace("LoadingState: All files loaded successfully.");
            loadingText.text = "Complete!";
            loadComplete = true;
        }
    }
}

#end