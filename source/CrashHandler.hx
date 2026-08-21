package;

#if (!wiiu || !cafe)

import haxe.CallStack;
import sys.io.File;
import sys.FileSystem;
import citro.CitroG;
import citro.state.CitroState;

class CrashHandler {
    private static var logsDir:String = "sdmc:/Deltarune/logs";
    private static var crashDir:String = "sdmc:/Deltarune/crash";
    
    private static var logPath:String = "sdmc:/Deltarune/logs/game_log.txt";
    private static var crashPath:String = "sdmc:/Deltarune/crash/latest_crash.txt";
    
    private static var originalTrace:Dynamic;

    /**
     * Initializes the crash handler, ensures both directories exist, and redirects traces.
     */
    public static function init() {
        try {
            if (!FileSystem.isDirectory(logsDir)) {
                FileSystem.createDirectory(logsDir);
            }
            if (!FileSystem.isDirectory(crashDir)) {
                FileSystem.createDirectory(crashDir);
            }

            File.saveContent(logPath, "--- Citro Engine 3DS Session Started ---\n");
        } catch (e:Dynamic) {
        }

        originalTrace = haxe.Log.trace;
        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            originalTrace(v, infos);

            var msg = '${infos.fileName}:${infos.lineNumber}: $v\n';
            appendGeneralLog(msg);
        };
    }

    /**
     * Appends standard trace messages instantly to the logs folder.
     */
    public static function appendGeneralLog(text:String) {
        try {
            var file = File.append(logPath, false);
            file.writeString(text);
            file.flush();
            file.close();
        } catch (e:Dynamic) {
        }
    }

    /**
     * Logs fatal exceptions and full call stacks into the crash folder.
     */
    public static function logException(e:Dynamic, ?customMessage:String = "") {
        var stack = CallStack.toString(CallStack.exceptionStack());
        var fullLog = '\n[CRASH/ERROR] $customMessage\nException: $e\nCallStack:\n$stack\n-------------------\n';

        try {
            var file = File.write(crashPath, false);
            file.writeString(fullLog);
            file.flush();
            file.close();
        } catch (err:Dynamic) {
        }

        appendGeneralLog(fullLog);
    }

    /**
     * Wraps execution in a try-catch block. If a crash occurs, it logs the error 
     * to the crash folder and safely returns the user back to the Main Menu.
     */
    public static function protect(action:Void->Void, ?fallbackState:CitroState) {
        try {
            action();
        } catch (e:Dynamic) {
            logException(e, "Runtime Crash Caught!");
            
            try {
                var menuState = fallbackState != null ? fallbackState : new ThreeDSMainMenuState();
                CitroG.switchState(menuState);
            } catch (switchErr:Dynamic) {
                appendGeneralLog("Critical Error: Failed to switch back to menu state: " + switchErr);
            }
        }
    }
}

#end
