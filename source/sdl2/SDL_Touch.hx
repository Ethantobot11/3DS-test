package sdl2;

import cpp.Pointer;
import cpp.Int64;
import cpp.Float;
import cpp.UInt32;

@:native("SDL_TouchID")
typedef SDL_TouchID = Int64;

@:native("SDL_FingerID")
typedef SDL_FingerID = Int64;

@:native("SDL_Finger")
@:structAccess
extern class SDL_Finger {
    public var id:SDL_FingerID;
    public var x:Float;
    public var y:Float;
    public var pressure:Float;
    public function new() {}
}

extern class SDL_Touch {
    @:native("SDL_TOUCH_MOUSEID") extern public static var SDL_TOUCH_MOUSEID:UInt32;
    @:native("SDL_GetNumTouchDevices") extern public static function SDL_GetNumTouchDevices():Int;
    @:native("SDL_GetTouchDevice") extern public static function SDL_GetTouchDevice(index:Int):SDL_TouchID;
    @:native("SDL_GetNumTouchFingers") extern public static function SDL_GetNumTouchFingers(touchID:SDL_TouchID):Int;
    @:native("SDL_GetTouchFinger") extern public static function SDL_GetTouchFinger(touchID:SDL_TouchID, index:Int):Pointer<SDL_Finger>;
}