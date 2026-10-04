package citro;

import haxe.Json;
#if haxe3ds
import haxe3ds.Env;
import haxe3ds.services.FS;
#end
import sys.FileSystem;
import sys.io.File;

/**
 * An enum for checking its status to know if it succeeded or not.
 */
enum CitroSaveStatus {
	/**
	 * Save Operation is Successful, It's opened and ready to read and save.
	 */
	SUCCESSFUL;

	/**
	 * Status for calling any FS functions received an error and its not gonna continue.
	 */
	FS_ERROR;

	/**
	 * Status says that Application is using a 3DSX instead of CIA, which doesn't support saves.
	 * (On Wii U, this is not applicable, saves always work).
	 */
	USES_3DSX;
}

/**
 * A class utility for Save Data, this can be used to access, modify, delete, or do some stuff in there.
 *
 * This only works if the Save Status is Successful.
 */
class CitroSave {
	#if haxe3ds
	private static var basePath:String = "sdmc:/Deltarune/";
	#else
	private static var basePath:String = "/vol/external01/Deltarune/";
	#end

	/**
	 * The current status for this save, this can be used to determine if something went wrong, or some other miscellaneous enums.
	 */
	public var status(default, null):CitroSaveStatus;

	/**
	 * Variable for all of the data that's stored, this can be used to set some properties to load everytime the user launches this application.
	 */
	public var data:Dynamic = {};

	/**
	 * Constructor for creating a new Save Data, this can only be used once and it's in the class `CitroG`.
	 * @param files How many files that should be stored in the save data?
	 * @param dirs How many directories that should be stored? Leave at 1 if you just want the root only.
	 */
	public function new(files:Int = 16, dirs:Int = 1) {
		#if haxe3ds
			#if IS_3DSX
				trace('Saves are not supported in 3DSX builds. Please use a CIA.');
				status = USES_3DSX;
			#else
				if (FS.mountSaveData("sdmc", files, dirs).isFail()) {
					status = FS_ERROR;
					trace('Failed to mount save data.');
					return;
				}
				
				ensureDirectoryExists();
				loadSaveData();
				status = SUCCESSFUL;
			#end
		#else
			ensureDirectoryExists();
			loadSaveData();
			status = SUCCESSFUL;
		#end
	}

	private function ensureDirectoryExists():Void {
		if (!FileSystem.exists(basePath)) {
			FileSystem.createDirectory(basePath);
		}
	}

	private function loadSaveData():Void {
		var savePath = basePath + "save.json";
		if (FileSystem.exists(savePath)) {
			try {
				data = Json.parse(File.getContent(savePath));
			} catch(error) {
				trace('Failed to parse save.json, deleting corrupted file.');
				FileSystem.deleteFile(savePath);
				data = {};
			}
		}
	}

	/**
	 * Converts the save to a Compatible JSON Format and saves it to the Save Extension.
	 * @return Bool to indicate that it succeeded or not.
	 */
	public function flush():Bool {
		if (status != SUCCESSFUL) {
			return false;
		}

		try {
			var savePath = basePath + "save.json";
			File.saveContent(savePath, Json.stringify(data));
			
			#if haxe3ds
			#if IS_CIA
			FS.flushAndCommit();
			#end
			#end
			
			return true;
		} catch(e) {
			trace('Failed to flush save data: ' + e);
			return false;
		}
	}

	/**
	 * Function to delete the save data (and maybe reset the Data Variable too).
	 * @param alsoResetData Whether or not it should reset its own data or not, this is a RISKY move.
	 * @return Bool to determine if save is actually deleted or not.
	 */
	public function delete(alsoResetData:Bool = true):Bool {
		if (status != SUCCESSFUL) {
			return false;
		}

		if (alsoResetData) {
			data = {};
		}

		try {
			var savePath = basePath + "save.json";
			if (FileSystem.exists(savePath)) {
				FileSystem.deleteFile(savePath);
				trace('Save data deleted successfully.');
			}
			return true;
		} catch(_) {
			return false;
		}
	}
}