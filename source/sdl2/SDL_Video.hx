package sdl2;

import cpp.Pointer;
import cpp.RawPointer;
import cpp.Void;
import cpp.Int64;
import vorbis.Codec.Vorbis_info;

@:native("OggVorbis_File")
@:include("vorbis/vorbisfile.h")
@:structAccess
extern class OggVorbis_File {
    @:include("vorbis/vorbisfile.h") public var datasource:RawPointer<Void>;
    @:include("vorbis/vorbisfile.h") public var seekable:Int;
    @:include("vorbis/vorbisfile.h") public var offset:Int64;
    @:include("vorbis/vorbisfile.h") public var end:Int64;
    @:include("vorbis/vorbisfile.h") public var links:Int;
    @:include("vorbis/vorbisfile.h") public var offsets:Pointer<Int64>;
    @:include("vorbis/vorbisfile.h") public var dataoffsets:Pointer<Int64>;
    @:include("vorbis/vorbisfile.h") public var serialnos:Pointer<Int>;
    @:include("vorbis/vorbisfile.h") public var pcmlengths:Pointer<Int64>;
    @:include("vorbis/vorbisfile.h") public var vi:Pointer<Vorbis_info>;
    @:include("vorbis/vorbisfile.h") public var pcm_offset:Int64;
    @:include("vorbis/vorbisfile.h") public var ready_state:Int;
    @:include("vorbis/vorbisfile.h") public var current_serialno:Int;
    @:include("vorbis/vorbisfile.h") public var current_link:Int;
    @:include("vorbis/vorbisfile.h") public var bittrack:Float;
    @:include("vorbis/vorbisfile.h") public var samptrack:Float;

    @:haxe.warning("-WExternWithExpr")
    public function new() {}
}

@:include("vorbis/vorbisfile.h")
extern class VorbisFile {
    @:native("ov_fopen")
    @:include("vorbis/vorbisfile.h")
    extern public static function ov_fopen(path:cpp.ConstCharStar, vf:Pointer<OggVorbis_File>):Int;

    @:native("ov_clear")
    @:include("vorbis/vorbisfile.h")
    extern public static function ov_clear(vf:Pointer<OggVorbis_File>):Int;

    @:native("ov_read")
    @:include("vorbis/vorbisfile.h")
    extern public static function ov_read(vf:Pointer<OggVorbis_File>, buffer:Pointer<cpp.Char>, length:Int, bigendianp:Int, word:Int, sgned:Int, bitstream:Pointer<cpp.Int>):Int;

    @:native("ov_time_tell")
    @:include("vorbis/vorbisfile.h")
    extern public static function ov_time_tell(vf:Pointer<OggVorbis_File>):Float;

    @:native("ov_info")
    @:include("vorbis/vorbisfile.h")
    extern public static function ov_info(vf:Pointer<OggVorbis_File>, link:Int):Pointer<Vorbis_info>;

    @:native("ov_time_total")
    @:include("vorbis/vorbisfile.h")
    extern public static function ov_time_total(vf:Pointer<OggVorbis_File>, i:Int):Float;

    @:native("ov_time_seek")
    @:include("vorbis/vorbisfile.h")
    extern public static function ov_time_seek(vf:Pointer<OggVorbis_File>, t:Float):Int;
}