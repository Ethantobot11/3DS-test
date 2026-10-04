package vorbis;

import cpp.RawPointer;
import cpp.Void;

@:native("vorbis_info")
@:include("vorbis/codec.h")
@:structAccess
extern class Vorbis_info {
    @:include("vorbis/codec.h")
    public var version:Int;
    @:include("vorbis/codec.h")
    public var channels:Int;
    @:include("vorbis/codec.h")
    public var rate:Int;
    @:include("vorbis/codec.h")
    public var bitrate_upper:Int;
    @:include("vorbis/codec.h")
    public var bitrate_nominal:Int;
    @:include("vorbis/codec.h")
    public var bitrate_lower:Int;
    @:include("vorbis/codec.h")
    public var bitrate_window:Int;
    @:include("vorbis/codec.h")
    public var codec_setup:RawPointer<Void>;
    // i won't fix it because like wanring : D
    // fix is : public function new(); lol
    public function new() {};
}