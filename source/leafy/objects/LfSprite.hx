package leafy.objects;

import Std;
import haxe.Xml;
import haxe.ds.StringMap;

import sdl2.SDL_Image;
import sdl2.SDL_Render;
import sdl2.SDL_Surface.SDL_Surface;
import sdl2.SDL_Surface.SDL_SurfaceClass;
import sdl2.SDL_Rect;
import sdl2.SDL_Error;
import sdl2.SDL_Pixels;

import leafy.backend.sdl.LfWindow;
import leafy.utils.LfStringUtils;
import leafy.backend.LeafyDebug;
import leafy.objects.LfObject;
import leafy.utils.LfUtils;
import leafy.filesystem.LfFile;
import leafy.filesystem.LfSystemPaths;

/**
 * A frame rectangle structure for animations
 */
typedef LfFrameRect = {
    var x:Int;
    var y:Int;
    var width:Int;
    var height:Int;
}

/**
 * An animation definition container
 */
class LfAnimation {
    public var name:String;
    public var frames:Array<String>;
    public var framerate:Float;
    public var looped:Bool;

    public function new(name:String, frames:Array<String>, framerate:Float = 24.0, looped:Bool = true) {
        this.name = name;
        this.frames = frames;
        this.framerate = framerate;
        this.looped = looped;
    }
}

/**
 * A sprite object, used to display images and animations on the screen
 * * Author: Slushi
 */
class LfSprite extends LfObject {
    public var imagePath:String;

    // Animation & Frames Fields
    public var animationsMap:StringMap<LfAnimation> = new StringMap<LfAnimation>();
    public var framesMap:StringMap<LfFrameRect> = new StringMap<LfFrameRect>();
    public var currentAnimation:LfAnimation = null;
    public var currentAnimName:String = "";
    private var animCurFrameIndex:Int = 0;
    private var animTimer:Float = 0;
    public var finished:Bool = true;

    // Custom SDL Source Rect for sub-rect rendering (spritesheets)
    public var sourceRect:SDL_Rect;

    public function new(x:Int, y:Int) {
        super();
        this.x = x;
        this.y = y;
        this.type = ObjectType.SPRITE;
        this.width = 0;
        this.height = 0;
        this.angle = 0;
        this.scale = {x: 1, y: 1};
        this.isVisible = true;
        this.alpha = 1.0;
        this.sdlTexturePtr = null;
        this.sdlSurfacePtr = null;
        this.sdlRect = new SDL_Rect();
        this.sourceRect = new SDL_Rect();
        this.readyToRender = false;

        this.imagePath = "";
        this.velocity = {x: 0, y: 0};
        this.acceleration = {x: 0, y: 0};
        this.drag = {x: 0, y: 0};
        this.maxVelocity = {x: 0, y: 0};
        this.gravity = 0;
        this.immovable = false;
        this.alive = true; 
    }

    /**
     * Load a standard static image (.png)
     */
    public function loadImage(imgPath:String):Void {
        var correctPath:String = LfSystemPaths.getConsolePath() + imgPath;

        if (imgPath == null || imgPath == "") {
            LeafyDebug.log("Image path cannot be null or empty", ERROR);
            return;
        }
        if (!LfStringUtils.stringEndsWith(correctPath, ".png")) {
            LeafyDebug.log("Image must be a PNG file", ERROR);
            return;
        }
        if (!LfSystemPaths.exists(correctPath)) {
            LeafyDebug.log("Image path does not exist: " + imgPath, ERROR);
            return;
        }

        this.readyToRender = false;
        this.imagePath = correctPath;
        this.name = LfUtils.removeSDDirFromPath(this.imagePath);

        cleanupTextures();

        this.sdlSurfacePtr = SDL_Image.IMG_Load(ConstCharPtr.fromString(this.imagePath));
        if (this.sdlSurfacePtr == null) {
            LeafyDebug.log("Failed to load image: " + SDL_Error.SDL_GetError().toString(), ERROR);
            return;
        }

        this.sdlTexturePtr = SDL_Render.SDL_CreateTextureFromSurface(LfWindow.currentRenderer, this.sdlSurfacePtr);
        if (this.sdlTexturePtr == null) {
            LeafyDebug.log("Failed to create texture from surface: " + SDL_Error.SDL_GetError().toString(), ERROR);
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            return;
        }

        SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
        this.sdlSurfacePtr = null;

        SDL_Render.SDL_SetTextureBlendMode(this.sdlTexturePtr, SDL_BLENDMODE_BLEND);
        SDL_Render.SDL_QueryTexture(this.sdlTexturePtr, untyped __cpp__("NULL"), untyped __cpp__("NULL"), sdlRect.w, sdlRect.h);

        sourceRect.x = 0;
        sourceRect.y = 0;
        sourceRect.w = sdlRect.w;
        sourceRect.h = sdlRect.h;

        this.width = sdlRect.w;
        this.height = sdlRect.h;
        this.readyToRender = true;
    }

    /**
     * Load a spritesheet image paired with a Sparrow/Flixel XML file
     * @param imgPath Path to the .png atlas
     * @param xmlPath Path to the matching .xml configuration
     */
    public function loadGraphicFromXml(imgPath:String, xmlPath:String):Void {
        // 1. Load the texture via standard PNG loader
        loadImage(imgPath);

        var fullXmlPath = LfSystemPaths.getConsolePath() + xmlPath;
        if (!LfSystemPaths.exists(fullXmlPath)) {
            LeafyDebug.log("XML path does not exist: " + xmlPath, ERROR);
            return;
        }

        var xmlString = LfFile.readFile(fullXmlPath);
        if (xmlString == "") {
            LeafyDebug.log("Failed to read XML file or file is empty: " + xmlPath, ERROR);
            return;
        }

        try {
            var xml = Xml.parse(xmlString);
            var textureAtlas = xml.firstElement();

            for (subTexture in textureAtlas.elementsNamed("SubTexture")) {
                var name = subTexture.get("name");
                var x = Std.parseInt(subTexture.get("x"));
                var y = Std.parseInt(subTexture.get("y"));
                var w = Std.parseInt(subTexture.get("width"));
                var h = Std.parseInt(subTexture.get("height"));

                // Store frame dimensions and coordinates inside framesMap
                framesMap.set(name, {x: x, y: y, width: w, height: h});
            }
            LeafyDebug.log("Successfully parsed XML frames for atlas: " + imgPath, DEBUG);
        } catch (e:Dynamic) {
            LeafyDebug.log("Error parsing XML structure: " + Std.string(e), ERROR);
        }
    }

    /**
     * Add a named animation sequence referencing parsed XML frames
     */
    public function addAnimationByPrefix(name:String, prefix:String, framerate:Float = 24.0, looped:Bool = true):Void {
        var matchingFrames:Array<String> = [];

        for (key in framesMap.keys()) {
            if (key.startsWith(prefix)) {
                matchingFrames.push(key);
            }
        }

        if (matchingFrames.length == 0) {
            LeafyDebug.log("No frames found for animation prefix: " + prefix, WARN);
            return;
        }

        animationsMap.set(name, new LfAnimation(name, matchingFrames, framerate, looped));
    }

    /**
     * Play a registered animation by name
     */
    public function playAnimation(name:String, force:Bool = false):Void {
        if (!animationsMap.exists(name)) {
            LeafyDebug.log("Animation does not exist: " + name, ERROR);
            return;
        }

        if (!force && currentAnimation != null && currentAnimation.name == name) {
            return;
        }

        currentAnimation = animationsMap.get(name);
        currentAnimName = name;
        animCurFrameIndex = 0;
        animTimer = 0;
        finished = false;
        updateCurrentFrame();
    }

    private function updateCurrentFrame():Void {
        if (currentAnimation == null) return;

        var frameName = currentAnimation.frames[animCurFrameIndex];
        var rect = framesMap.get(frameName);

        if (rect != null) {
            sourceRect.x = rect.x;
            sourceRect.y = rect.y;
            sourceRect.w = rect.width;
            sourceRect.h = rect.height;

            this.width = rect.width;
            this.height = rect.height;
            sdlRect.w = rect.width;
            sdlRect.h = rect.height;
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (currentAnimation != null && !finished) {
            animTimer += elapsed;
            var frameDuration = 1.0 / currentAnimation.framerate;

            if (animTimer >= frameDuration) {
                animTimer -= frameDuration;
                animCurFrameIndex++;

                if (animCurFrameIndex >= currentAnimation.frames.length) {
                    if (currentAnimation.looped) {
                        animCurFrameIndex = 0;
                    } else {
                        animCurFrameIndex = currentAnimation.frames.length - 1;
                        finished = true;
                    }
                }
                updateCurrentFrame();
            }
        }
    }

    private function cleanupTextures():Void {
        if (this.sdlTexturePtr != null) {
            SDL_Render.SDL_DestroyTexture(this.sdlTexturePtr);
            this.sdlTexturePtr = null;
        }
        if (this.sdlSurfacePtr != null) {
            SDL_SurfaceClass.SDL_FreeSurface(this.sdlSurfacePtr);
            this.sdlSurfacePtr = null;
        }
    }

    override public function destroy():Void {
        cleanupTextures();
        super.destroy();
        LeafyDebug.log("Sprite destroyed: " + this.name, DEBUG);
    }
}