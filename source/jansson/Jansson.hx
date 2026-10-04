package jansson;

import cpp.Pointer;
import cpp.ConstCharStar;
import cpp.NativeArray;
import cpp.Char;
import cpp.SizeT;
import cpp.Int;

@:native("json_error_t")
@:structAccess
extern class Json_error_t {
    public var line:Int;
    public var column:Int;
    public var position:Int;
    public var source:NativeArray<Char>;
    public var text:NativeArray<Char>;
    public function new() {}
}

@:native("json_type")
extern enum Json_type {
    JSON_OBJECT;
    JSON_ARRAY;
    JSON_STRING;
    JSON_INTEGER;
    JSON_REAL;
    JSON_TRUE;
    JSON_FALSE;
    JSON_NULL;
}

@:native("json_t")
@:structAccess
extern class Json_t {
    public var type:Json_type;
    public var refcount:SizeT;
    public function new() {}
}

extern class Jansson {
    @:native("json_loads") extern public static function json_loads(input:ConstCharStar, flags:SizeT, error:Pointer<Json_error_t>):Pointer<Json_t>;
    @:native("json_load_file") extern public static function json_load_file(filename:ConstCharStar, flags:SizeT, error:Pointer<Json_error_t>):Pointer<Json_t>;
    @:native("json_decref") extern public static function json_decref(json:Pointer<Json_t>):Void;

    @:native("json_object_get") extern public static function json_object_get(object:Pointer<Json_t>, key:ConstCharStar):Pointer<Json_t>;
    @:native("json_array_get") extern public static function json_array_get(array:Pointer<Json_t>, index:Int):Pointer<Json_t>;
    @:native("json_string_value") extern public static function json_string_value(string:Pointer<Json_t>):ConstCharStar;
    @:native("json_integer_value") extern public static function json_integer_value(integer:Pointer<Json_t>):Int;
    @:native("json_real_value") extern public static function json_real_value(real:Pointer<Json_t>):Float;
    @:native("json_number_value") extern public static function json_number_value(number:Pointer<Json_t>):ConstCharStar;
    @:native("json_boolean_value") extern public static function json_boolean_value(boolean:Pointer<Json_t>):Int;

    @:native("json_array_size") extern public static function json_array_size(array:Pointer<Json_t>):Int;

    @:native("json_is_object") extern public static function json_is_object(json:Pointer<Json_t>):Int;
    @:native("json_is_array") extern public static function json_is_array(json:Pointer<Json_t>):Int;
    @:native("json_is_string") extern public static function json_is_string(json:Pointer<Json_t>):Int;
    @:native("json_is_integer") extern public static function json_is_integer(json:Pointer<Json_t>):Int;
    @:native("json_is_real") extern public static function json_is_real(json:Pointer<Json_t>):Int;
    @:native("json_is_number") extern public static function json_is_number(json:Pointer<Json_t>):Int;
    @:native("json_is_true") extern public static function json_is_true(json:Pointer<Json_t>):Int;
    @:native("json_is_false") extern public static function json_is_false(json:Pointer<Json_t>):Int;
    @:native("json_is_boolean") extern public static function json_is_boolean(json:Pointer<Json_t>):Int;
    @:native("json_is_null") extern public static function json_is_null(json:Pointer<Json_t>):Int;
}