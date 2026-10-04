package sdl2;

import cpp.Int32;

@:include("SDL2/SDL_rect.h")
@:native("SDL_Point")
@:structAccess
extern class SDL_Point {
    public var x:Int;
    public var y:Int;
    public function new() {}
}

@:include("SDL2/SDL_rect.h")
@:native("SDL_FPoint")
@:structAccess
extern class SDL_FPoint {
    public var x:Float;
    public var y:Float;
    public function new() {}
}

@:include("SDL2/SDL_rect.h")
@:native("SDL_Rect")
@:structAccess
extern class SDL_Rect {
    public var x:Int;
    public var y:Int;
    public var w:Int;
    public var h:Int;
    public function new() {}
}

@:include("SDL2/SDL_rect.h")
@:native("SDL_FRect")
@:structAccess
extern class SDL_FRect {
    public var x:Float;
    public var y:Float;
    public var w:Float;
    public var h:Float;
    public function new() {}
}