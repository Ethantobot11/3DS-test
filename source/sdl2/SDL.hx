package sdl2;

import cpp.UInt32;
import cpp.Int32;

@:include("SDL2/SDL.h")
extern class SDL {
    @:native("SDL_INIT_TIMER") extern public static var SDL_INIT_TIMER:UInt32;
    @:native("SDL_INIT_AUDIO") extern public static var SDL_INIT_AUDIO:UInt32;
    @:native("SDL_INIT_VIDEO") extern public static var SDL_INIT_VIDEO:UInt32;
    @:native("SDL_INIT_JOYSTICK") extern public static var SDL_INIT_JOYSTICK:UInt32;
    @:native("SDL_INIT_GAMECONTROLLER") extern public static var SDL_INIT_GAMECONTROLLER:UInt32;
    @:native("SDL_INIT_EVENTS") extern public static var SDL_INIT_EVENTS:UInt32;
    @:native("SDL_INIT_EVERYTHING") extern public static var SDL_INIT_EVERYTHING:UInt32;
    
    @:native("SDL_Init") extern public static function SDL_Init(flags:UInt32):Int32;
    @:native("SDL_Quit") extern public static function SDL_Quit():Void;
}
