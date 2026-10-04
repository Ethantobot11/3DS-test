package sdl2;

import cpp.Pointer;
import cpp.RawPointer;
import cpp.Void;
import cpp.ConstCharStar;
import cpp.UInt8;
import cpp.UInt16;
import cpp.UInt32;

@:native("SDL_AudioFormat")
typedef SDL_AudioFormat = UInt16;

@:native("SDL_AudioDeviceID")
typedef SDL_AudioDeviceID = UInt32;

@:native("SDL_AudioCallback")
typedef SDL_AudioCallback = (data:RawPointer<Void>, stream:UInt8, len:Int) -> Void;

@:native("SDL_AudioSpec")
@:structAccess
extern class SDL_AudioSpec {
    public var freq:Int;
    public var format:SDL_AudioFormat;
    public var channels:UInt8;
    public var silence:UInt8;
    public var samples:UInt16;
    public var padding:UInt16;
    public var size:UInt32;
    public var callback:SDL_AudioCallback;
    public var userdata:RawPointer<Void>;
    public function new() {}
}

@:native("SDL_AudioStatus")
extern enum SDL_AudioStatus {
    @:native("SDL_AUDIO_STOPPED") SDL_AUDIO_STOPPED;
    @:native("SDL_AUDIO_PLAYING") SDL_AUDIO_PLAYING;
    @:native("SDL_AUDIO_PAUSED") SDL_AUDIO_PAUSED;
}

extern class SDL_Audio {
    @:native("SDL_MIX_MAXVOLUME") extern public static var SDL_MIX_MAXVOLUME:UInt8;
    @:native("AUDIO_S16MSB") extern public static var AUDIO_S16MSB:SDL_AudioFormat;
    @:native("SDL_AUDIO_ALLOW_ANY_CHANGE") extern public static var SDL_AUDIO_ALLOW_ANY_CHANGE:Int;

    @:native("SDL_AudioInit") extern public static function SDL_AudioInit(name:ConstCharStar):Int;
    @:native("SDL_AudioQuit") extern public static function SDL_AudioQuit():Void;
    @:native("SDL_GetCurrentAudioDriver") extern public static function SDL_GetCurrentAudioDriver():ConstCharStar;
    @:native("SDL_OpenAudio") extern public static function SDL_OpenAudio(desired:Pointer<SDL_AudioSpec>, obtained:Pointer<SDL_AudioSpec>):Int;
    @:native("SDL_OpenAudioDevice") extern public static function SDL_OpenAudioDevice(device:ConstCharStar, iscapture:Int, desired:Pointer<SDL_AudioSpec>, obtained:Pointer<SDL_AudioSpec>, allowed_changes:Int):SDL_AudioDeviceID;
    @:native("SDL_PauseAudio") extern public static function SDL_PauseAudio(pause_on:Int):Void;
    @:native("SDL_PauseAudioDevice") extern public static function SDL_PauseAudioDevice(device:SDL_AudioDeviceID, pause_on:Int):Void;
    @:native("SDL_CloseAudio") extern public static function SDL_CloseAudio():Void;
    @:native("SDL_CloseAudioDevice") extern public static function SDL_CloseAudioDevice(device:SDL_AudioDeviceID):Void;
    @:native("SDL_GetAudioStatus") extern public static function SDL_GetAudioStatus():SDL_AudioStatus;
    @:native("SDL_GetAudioDeviceStatus") extern public static function SDL_GetAudioDeviceStatus(device:SDL_AudioDeviceID):SDL_AudioStatus;
    @:native("SDL_FreeWAV") extern public static function SDL_FreeWAV(audio_buf:Pointer<UInt8>):Void;
    @:native("SDL_LoadWAV") extern public static function SDL_LoadWAV(file:ConstCharStar, spec:Pointer<SDL_AudioSpec>, audio_buf:Pointer<UInt8>, audio_len:Pointer<UInt32>):Pointer<UInt8>;
    @:native("SDL_LockAudioDevice") extern public static function SDL_LockAudioDevice(device:SDL_AudioDeviceID):Void;
    @:native("SDL_UnlockAudioDevice") extern public static function SDL_UnlockAudioDevice(device:SDL_AudioDeviceID):Void;
    @:native("SDL_QueueAudio") extern public static function SDL_QueueAudio(device:SDL_AudioDeviceID, audio_buf:Pointer<UInt8>, len:UInt32):Void;
    @:native("SDL_MixAudioFormat") extern public static function SDL_MixAudioFormat(dst:Pointer<UInt8>, src:Pointer<UInt8>, format:SDL_AudioFormat, len:UInt32, volume:UInt8):Void;
}