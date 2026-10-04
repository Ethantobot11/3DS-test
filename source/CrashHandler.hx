package;

import haxe.CallStack;
import sys.io.File;
import sys.io.FileOutput;
import sys.FileSystem;
import citro.CitroG;
import citro.state.CitroState;

class CrashHandler {
    #if haxe3ds
    private static var basePath:String = "sdmc:/Deltarune/";
    #else
    private static var basePath:String = "/vol/external01/Deltarune/";
    #end

    private static var logsDir:String = basePath + "logs";
    private static var crashDir:String = basePath + "crash";
    
    private static var logPath:String = basePath + "logs/game_log.txt";
    private static var crashPath:String = basePath + "crash/latest_crash.txt";
    
    private static var originalTrace:Dynamic;
    private static var logOutput:FileOutput = null;

    public static function init() {
        try {
            if (!FileSystem.exists(logsDir)) {
                FileSystem.createDirectory(logsDir);
            }
            if (!FileSystem.exists(crashDir)) {
                FileSystem.createDirectory(crashDir);
            }

            logOutput = File.append(logPath, false);
            logOutput.writeString("--- Deltarune Session Started ---\n");
            logOutput.flush();
        } catch (e:Dynamic) {
            trace("CRITICAL: Failed to initialize CrashHandler files: " + e);
        }

        originalTrace = haxe.Log.trace;
        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            if (originalTrace != null) originalTrace(v, infos);

            var fileName = (infos != null && infos.fileName != null) ? infos.fileName : "Unknown";
            var lineNumber = (infos != null) ? infos.lineNumber : 0;
            var msg = '[$fileName:$lineNumber]: $v\n';
            
            appendGeneralLog(msg);
        };
    }

    public static function appendGeneralLog(text:String) {
        try {
            if (logOutput != null) {
                logOutput.writeString(text);
                logOutput.flush();
            } else {
                var file = File.append(logPath, false);
                file.writeString(text);
                file.flush();
                file.close();
            }
        } catch (e:Dynamic) {
            if (originalTrace != null) originalTrace("Failed to write to general log: " + e);
        }
    }

    public static function logException(e:Dynamic, ?customMessage:String = "") {
        var stack = CallStack.toString(CallStack.exceptionStack());
        var fullLog = '\n========================================\n';
        fullLog += '[CRASH/ERROR] ${Date.now().toString()}\n';
        fullLog += 'Message: $customMessage\n';
        fullLog += 'Exception: $e\n';
        fullLog += 'CallStack:\n$stack\n';
        fullLog += '========================================\n';

        try {
            var file = File.write(crashPath, false);
            file.writeString(fullLog);
            file.flush();
            file.close();
            
            var dateNow = Date.now().toString().replace(" ", "_").replace(":", "-");
            var uniqueCrashPath = basePath + 'crash/crash_$dateNow.txt';
            var uniqueFile = File.write(uniqueCrashPath, false);
            uniqueFile.writeString(fullLog);
            uniqueFile.flush();
            uniqueFile.close();
            
        } catch (err:Dynamic) {
            if (originalTrace != null) originalTrace("Failed to write crash file: " + err);
        }

        appendGeneralLog(fullLog);
        
        trace(fullLog);
    }

    public static function protect(action:Void->Void, ?fallbackState:CitroState) {
        try {
            action();
        } catch (e:Dynamic) {
            logException(e, "Runtime Crash Caught in Protected Block!");
            
            try {
                var menuState:CitroState = (fallbackState != null) ? fallbackState : cast new ThreeDSMainMenuState();
                CitroG.switchState(menuState);
            } catch (switchErr:Dynamic) {
                appendGeneralLog("Critical Error: Failed to switch back to menu state: " + switchErr);
                Sys.exit(1);
            }
        }
    }
}