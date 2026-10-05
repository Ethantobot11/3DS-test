package citro.c2d;

/**
 * Class for processing time and other utilities.
 * Note: These are 3DS-specific Citro3D metrics. On Wii U, they safely return 0.
 */
class CitroProcessor {
	#if HAXE3DS
	@:cppInclude("citro3d.h")
	/**
	 * Retrieves the current command buffer usage.
	 */
	public static var bufferUsage(get, null):Float;
	static function get_bufferUsage():Float
		return untyped __cpp__('C3D_GetCmdBufUsage()');

	/**
	 * Gets time spent by the GPU during last render.
	 */
	public static var drawTime(get, null):Float;
	static function get_drawTime():Float
		return untyped __cpp__('C3D_GetDrawingTime()');

	/**
	 * Gets time elapsed between last `C3D_FrameBegin()` and `C3D_FrameEnd()`. 
	 */
	public static var processingTime(get, null):Float;
	static function get_processingTime():Float
		return untyped __cpp__('C3D_GetProcessingTime()');
	#else
	/**
	 * Retrieves the current command buffer usage. (Stubbed for Wii U)
	 */
	public static var bufferUsage(get, null):Float;
	static function get_bufferUsage():Float return 0.0;

	/**
	 * Gets time spent by the GPU during last render. (Stubbed for Wii U)
	 */
	public static var drawTime(get, null):Float;
	static function get_drawTime():Float return 0.0;

	/**
	 * Gets time elapsed between last frame. (Stubbed for Wii U)
	 */
	public static var processingTime(get, null):Float;
	static function get_processingTime():Float return 0.0;
	#end
}
