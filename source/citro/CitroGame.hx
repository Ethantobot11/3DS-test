package citro;

import citro.backend.CitroTimer;
import citro.backend.CitroTween;
import citro.state.CitroState;
import haxe3ds.services.APT;
import haxe3ds.services.GFX;
import haxe3ds.services.RomFS;
import haxe3ds.OS;

/**
 * Unified Engine Setup.
 * Handles 3DS (Citro2D/3D) and Wii U (SDL2) initialization and rendering.
 */
#if !wiiu
@:headerCode("
#include <citro2d.h>
#include <citro3d.h>
extern C3D_RenderTarget* topScreen;
extern C3D_RenderTarget* bottomScreen;
")
@:cppFileCode('
C3D_RenderTarget* topScreen = nullptr;
C3D_RenderTarget* bottomScreen = nullptr;
')
#else
@:headerCode("
#include <SDL2/SDL.h>

extern SDL_Window* gWindow;
extern SDL_Renderer* gRenderer;
")
@:cppFileCode('
SDL_Window* gWindow = nullptr;
SDL_Renderer* gRenderer = nullptr;
')
#end

class CitroGame {
	@:noCompletion
	public static var _shouldQuit:Bool = false;

	static function renderObjectsForScreen(state:CitroState, bottom:Bool) {
		for (member in state.members) {
			if (member == null) continue;
			
			if (member.isDestroyed) {
				state.members.remove(member);
				continue;
			}

			#if !wiiu
			if (member.bottom != bottom) continue;
			#end
			member.update();
		}
	}

	static function renderState(state:CitroState) {
		#if !wiiu
		for (i in 0...2) {
			untyped __cpp__("C2D_SceneBegin({0} == 0 ? topScreen : bottomScreen)", i);
			renderObjectsForScreen(state, i == 1);
		}
		#else
		renderObjectsForScreen(state, false);
		#end
	}

	public static function start(state:CitroState) {
		if (state == null) return;

		GFX.init();
		RomFS.init();

		#if !wiiu
		untyped __cpp__('
			C2D_Init(C2D_DEFAULT_MAX_OBJECTS);
			C3D_Init(C3D_DEFAULT_CMDBUF_SIZE);
			C2D_Prepare();

			topScreen = C2D_CreateScreenTarget(GFX_TOP,	GFX_LEFT);
			bottomScreen = C2D_CreateScreenTarget(GFX_BOTTOM, GFX_LEFT);
		');
		#else
		untyped __cpp__('
			SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMECONTROLLER);

			SDL_CreateWindowAndRenderer(1280, 720, 0, &gWindow, &gRenderer);
			SDL_SetRenderDrawBlendMode(gRenderer, SDL_BLENDMODE_BLEND);
			SDL_SetWindowTitle(gWindow, "Deltarune Wii U");
		');
		#end

		(CitroG.state = state).create();
		
		while (APT.mainLoop() && !_shouldQuit) {
			final startTime = OS.time.toInt();

			#if !wiiu
			untyped __cpp__('
				C3D_FrameBegin(C3D_FRAME_SYNCDRAW);
				C2D_TargetClear(topScreen, 0xFF1D1D24);
				C2D_TargetClear(bottomScreen, 0xFF000000);
			');
			#else
			untyped __cpp__('
				SDL_SetRenderDrawColor(gRenderer, 29, 29, 36, 255); // 0xFF1D1D24
				SDL_RenderClear(gRenderer);
			');
			#end

			CitroTween.update();
			CitroTimer.update();
			CitroG.state.update(CitroG.deltaTime);

			final sub = CitroG.substate;
			if (sub != null) sub.update(CitroG.deltaTime);

			renderState(CitroG.state);
			if (sub != null) renderState(sub);

			#if !wiiu
			untyped __cpp__('
				C2D_Flush();
				C3D_FrameEnd(1); // 1 = C3D_FRAME_SYNCDRAW
			');
			#else
			untyped __cpp__('
				SDL_RenderPresent(gRenderer);
			');
			#end

			var elapsed = OS.time.toInt() - startTime;
			if (elapsed < 1) elapsed = 1;
			if (elapsed > 33) elapsed = 33; 
			
			CitroG.deltaTime = elapsed;
		}

		#if !wiiu
		untyped __cpp__('
			C3D_Fini();
			C2D_Fini();
		');
		#else
		untyped __cpp__('
			SDL_DestroyRenderer(gRenderer);
			SDL_DestroyWindow(gWindow);
			SDL_Quit();
		');
		#end

		RomFS.exit();
		GFX.exit();
	}
}
