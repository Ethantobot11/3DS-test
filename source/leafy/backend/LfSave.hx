package leafy.backend;

#if (!haxe3ds || !nx)

import leafy.filesystem.LfFile;
import leafy.filesystem.LfSystemPaths;
import leafy.backend.LeafyDebug;
import leafy.backend.LfJson;

/**
 * Explicit structure definition for save data layout
 */
typedef SaveDataStructure = {
    var slots:Array<Dynamic>;
    var currentSlot:Int;
}

class LfSaveData {
    public function new() {}
}

class LfSave {
    public var data:SaveDataStructure;
    private var savePath:String = "savegame.json";

    public function new() {
        data = {
            slots: null,
            currentSlot: 0
        };
    }

    public function bind(name:String = "savegame.json"):Void {
        savePath = name;
        load();
    }

    public function flush():Void {
        try {
            var fullPath = LfSystemPaths.getConsolePath() + savePath;
            
            // Basic fallback placeholder structure writing 
            // You can serialize slots manually or via JSON strings here
            var dummyJsonString = '{"currentSlot": ' + data.currentSlot + ', "slots": []}';
            
            LfFile.writeFile(fullPath, dummyJsonString);
            LeafyDebug.log("Save data successfully flushed to disk via JSON.", DEBUG);
        } catch (e:Dynamic) {
            LeafyDebug.log("Failed to save data", ERROR);
        }
    }

    public function load():Void {
        var fullPath = LfSystemPaths.getConsolePath() + savePath;
        if (LfSystemPaths.exists(fullPath)) {
            try {
                var content = LfFile.readFile(fullPath);
                if (content != "") {
                    var json = new LfJson(fullPath);
                    var slotVal = json.getNumber("currentSlot");
                    
                    data = {
                        slots: [],
                        currentSlot: untyped __cpp__("(int){0}", slotVal)
                    };
                    
                    json.freeJson();
                    LeafyDebug.log("Save data successfully loaded via LfJson.", DEBUG);
                    return;
                }
            } catch (e:Dynamic) {
                LeafyDebug.log("Failed to load save data, initializing fresh data.", WARNING);
            }
        }
        
        // Fallback default structure with guaranteed static types
        data = {
            slots: null,
            currentSlot: 0
        };
    }
}

#end