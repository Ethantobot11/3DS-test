package citro.util;

import haxe3ds.services.FS;

class CitroAssetUtil {
    /**
     * Checks if a file exists inside the RomFS assets folder.
     * @param path Relative path to the asset (e.g., "soul/iconOG.png")
     * @return true if the file exists and can be accessed, false otherwise.
     */
    public static function exists(path:String):Bool {
        var fileHandle = null;
        var exists:Bool = false;

        untyped __cpp__('
            Handle file;
            FS_Path filePath = fsMakePath(PATH_ASCII, path.c_str());
            if (R_SUCCEEDED(FSUSER_OpenFileDirectly(&file, ARCHIVE_ROMFS, (FS_Path){PATH_EMPTY, 0, NULL}, filePath, FS_OPEN_READ, 0))) {
                exists = true;
                FSFILE_Close(file);
            }
        ');

        return exists;
    }
}