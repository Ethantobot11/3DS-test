package sdl2;

import cpp.Pointer;
import cpp.ConstCharStar;
import cpp.RawPointer;
import cpp.Void;
import cpp.UInt8;
import cpp.UInt16;
import cpp.UInt32;

@:native("MIX_InitFlags")
extern enum MIX_InitFlags {
    @:native("MIX_INIT_FLAC") MIX_INIT_FLAC;
    @:native("MIX_INIT_MOD") MIX_INIT_MOD;
    @:native("MIX_INIT_MP3") MIX_INIT_MP3;
    @:native("MIX_INIT_OGG") MIX_INIT_OGG;
    @:native("MIX_INIT_MID") MIX_INIT_MID;
    @:native("MIX_INIT_OPUS") MIX_INIT_OPUS;
}

@:native("Mix_Chunk")
@:structAccess
extern class Mix_Chunk {
    public var allocated:Int;
    public var abuf:Pointer<UInt8>;
    public var alen:UInt32;
    public var volume:UInt8;
    public function new() {}
}

@:native("Mix_Fading")
extern enum Mix_Fading {
    @:native("MIX_NO_FADING") MIX_NO_FADING;
    @:native("MIX_FADING_OUT") MIX_FADING_OUT;
    @:native("MIX_FADING_IN") MIX_FADING_IN;
}

@:native("Mix_MusicType")
extern enum Mix_MusicType {
    @:native("MUS_NONE") MUS_NONE;
    @:native("MUS_CMD") MUS_CMD;
    @:native("MUS_WAV") MUS_WAV;
    @:native("MUS_MOD") MUS_MOD;
    @:native("MUS_MID") MUS_MID;
    @:native("MUS_OGG") MUS_OGG;
    @:native("MUS_MP3") MUS_MP3;
    @:native("MUS_FLAC") MUS_FLAC;
    @:native("MUS_OPUS") MUS_OPUS;
}

@:native("Mix_Music")
extern class Mix_Music {}

extern class SDL_Mixer {
    @:native("MIX_CHANNELS") extern public static var MIX_CHANNELS:Int;
    @:native("MIX_DEFAULT_FORMAT") extern public static var MIX_DEFAULT_FORMAT:Dynamic;
    @:native("MIX_MAX_VOLUME") extern public static var MIX_MAX_VOLUME:Int;

    @:native("Mix_Init") extern public static function Mix_Init(flags:MIX_InitFlags):Int;
    @:native("Mix_Quit") extern public static function Mix_Quit():Void;
    @:native("Mix_OpenAudio") extern public static function Mix_OpenAudio(freq:Int, format:UInt16, channels:Int, chunksize:Int):Int;
    @:native("Mix_OpenAudioDevice") extern public static function Mix_OpenAudioDevice(freq:Int, format:UInt16, channels:Int, chunksize:Int, device:ConstCharStar, flags:Int):Int;
    @:native("Mix_QuerySpec") extern public static function Mix_QuerySpec(outfreq:Pointer<Int>, format:Pointer<UInt16>, channels:Pointer<Int>):Int;
    @:native("Mix_AllocateChannels") extern public static function Mix_AllocateChannels(numchannels:Int):Void;
    @:native("Mix_LoadMUS") extern public static function Mix_LoadMUS(file:ConstCharStar):Pointer<Mix_Music>;
    @:native("Mix_LoadWAV") extern public static function Mix_LoadWAV(file:ConstCharStar):Pointer<Mix_Chunk>;
    @:native("Mix_FreeChunk") extern public static function Mix_FreeChunk(chunk:Pointer<Mix_Chunk>):Void;
    @:native("Mix_FreeMusic") extern public static function Mix_FreeMusic(music:Pointer<Mix_Music>):Void;
    @:native("Mix_PlayMusic") extern public static function Mix_PlayMusic(music:Pointer<Mix_Music>, loops:Int):Int;
    @:native("Mix_GetError") extern public static function Mix_GetError():ConstCharStar;
    @:native("Mix_Volume") extern public static function Mix_Volume(channel:Int, volume:Int):Void;
    @:native("Mix_VolumeChunk") extern public static function Mix_VolumeChunk(chunk:Pointer<Mix_Chunk>, volume:Int):Void;
    @:native("Mix_VolumeMusic") extern public static function Mix_VolumeMusic(volume:Int):Void;
    @:native("Mix_HaltChannel") extern public static function Mix_HaltChannel(channel:Int):Void;
    @:native("Mix_HaltMusic") extern public static function Mix_HaltMusic():Void;
    @:native("Mix_PlayChannel") extern public static function Mix_PlayChannel(channel:Int, chunk:Pointer<Mix_Chunk>, loops:Int):Int;
    @:native("Mix_PlayingMusic") extern public static function Mix_PlayingMusic():Int;
    @:native("Mix_PausedMusic") extern public static function Mix_PausedMusic():Int;
    @:native("Mix_PauseMusic") extern public static function Mix_PauseMusic():Void;
    @:native("Mix_ResumeMusic") extern public static function Mix_ResumeMusic():Void;
    @:native("Mix_RewindMusic") extern public static function Mix_RewindMusic():Void;
    @:native("Mix_HookMusicFinished") extern public static function Mix_HookMusicFinished(onFinishedFunc:Void->RawPointer<Void>):Void;
}