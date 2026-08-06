package citro.backend;

import haxe.CallStack;
import sys.io.File;
import sys.FileSystem;

class CrashHandler {
    private static var logDir:String = "sdmc:/Deltarune/citro_logs";
    private static var logPath:String = "sdmc:/Deltarune/citro_logs/crash.txt";
    private static var originalTrace:Dynamic;

    /**
     * Initializes the crash handler, ensures the directory exists, and redirects traces.
     */
    public static function init() {
        try {
            if (!FileSystem.isDirectory(logDir)) {
                FileSystem.createDirectory(logDir);
            }

            File.saveContent(logPath, "--- Citro Engine 3DS Log Started ---\n");
        } catch (e:Dynamic) {
        }

        originalTrace = haxe.Log.trace;
        haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
            originalTrace(v, infos);
            
            var msg = '${infos.fileName}:${infos.lineNumber}: $v\n';
            appendLog(msg);
        };

        untyped __cpp__(`
            std::set_terminate([]() {
                try {
                    std::rethrow_exception(std::current_exception());
                } catch (const std::exception& e) {
                    hx::SetException(HX_CSTRING(e.what()));
                } catch (...) {
                    hx::SetException(HX_CSTRING("Unknown C++ Exception"));
                }
            });
        `);
    }

    /**
     * Appends a message string safely to the crash log file on the SD card.
     */
    public static function appendLog(text:String) {
        try {
            var file = File.append(logPath, false);
            file.writeString(text);
            file.flush();
            file.close();
        } catch (e:Dynamic) {
        }
    }

    /**
     * Manually log an exception or warning with full call stack.
     */
    public static function logException(e:Dynamic, ?customMessage:String = "") {
        var stack = CallStack.toString(CallStack.exceptionStack());
        var fullLog = '\n[CRASH/ERROR] $customMessage\nException: $e\nCallStack:\n$stack\n-------------------\n';
        
        appendLog(fullLog);
    }
}