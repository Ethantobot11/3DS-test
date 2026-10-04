package citro.backend;

import cpp.Pointer;
import cpp.Void;

typedef VoidPtr = Pointer<Void>;

@:cppFileCode('
#include <cwav.h>
#include <citro2d.h>

void SUPER_FREE(void **ptr2ptr) {
	if (ptr2ptr && *ptr2ptr) {
		free(*ptr2ptr);
		*ptr2ptr = NULL;
	}
}
')

class CitroCache {
	public var cache:Map<String, VoidPtr> = new Map();

	public function new() {}

	public function get(path:String):VoidPtr {
		if (cache.exists(path)) {
			return cache[path];
		}
		return null;
	}

	public function set(path:String, ptr:VoidPtr) {
		if (cache.exists(path)) {
			var _ptr = cache[path];
			if (ptr == _ptr) {
				return;
			}
			freeMemory(path);
		}
		cache[path] = ptr;
	}

	public function remove(path:String) {
		if (cache.exists(path)) {
			freeMemory(path);
			cache.remove(path);
		}
	}

	public function keyValueIterator() {
		return cache.keyValueIterator();
	}

	function freeMemory(key:String) {
		final ptr = cache[key];
		untyped __cpp__('if (!{0}) return;', ptr);

		var extension = key.split(".");
		var ext = extension[extension.length - 1].toLowerCase();
		
		switch (ext) {
			case "t3x":
				untyped __cpp__('C2D_SpriteSheetFree((C2D_SpriteSheet){0});', ptr);
			case "bcfnt":
				untyped __cpp__('C2D_FontFree((C2D_Font){0});', ptr);
			case "cwav":
				untyped __cpp__('cwavFileFree((CWAV*){0}); free({0});', ptr);
			#if !haxe3ds
			case "png":
				untyped __cpp__('SDL_FreeSurface((SDL_Surface*){0});', ptr);
			case "ttf":
				untyped __cpp__('TTF_CloseFont((TTF_Font*){0});', ptr);
			#end
			default:
				untyped __cpp__('SUPER_FREE((void**)&{0});', ptr);
		}
	}

	public function clear() {
		for (key in cache.keys()) {
			freeMemory(key);
		}
		cache.clear();
	}
}