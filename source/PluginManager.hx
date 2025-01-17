package;

import flixel.system.frontEnds.CameraFrontEnd;
import flixel.system.frontEnds.BitmapFrontEnd;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSoundGroup;
import flixel.system.frontEnds.SoundFrontEnd;
import openfl.display.DisplayObject;
import flixel.input.keyboard.FlxKeyboard;
import flixel.system.frontEnds.InputFrontEnd;
import flixel.math.FlxRect;
import animateatlas.AtlasFrameMaker;
import flixel.text.FlxText;
import flixel.FlxState;
import openfl.filters.ShaderFilter;
import openfl.display.Stage;
import flixel.FlxGame;
import flixel.input.gamepad.FlxGamepadManager;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.addons.effects.FlxTrail;
import plugins.tools.MetroSprite;
import hscript.InterpEx;
import hscript.Interp;
import openfl.Assets;
import openfl.display.BlendMode;
import flixel.FlxG;
import flixel.addons.editors.pex.FlxPexParser;
import flixel.addons.text.FlxTypeText;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import Type.ValueType;
import hscript.Parser;
import hscript.ParserEx;
import hscript.ClassDeclEx;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.addons.effects.chainable.FlxRainbowEffect;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.addons.effects.chainable.FlxTrailEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.IFlxEffect;
#if VIDEOS_ALLOWED
import hxcodec.flixel.FlxVideo as FlxVideo;
import hxcodec.flixel.FlxVideoSprite;
#end
import flixel.group.FlxGroup;
import flxgif.FlxGifSprite;
#if mobile
import android.FlxHitbox;
import android.FlxVirtualPad;
import flixel.ui.FlxButton;
#end
#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end
import flixel.system.FlxAssets.FlxGraphicAsset;
using StringTools;
class DynamicPexParser extends FlxPexParser
{
    public static function parse<T:FlxEmitter>(data:Dynamic, particleGraphic:FlxGraphicAsset, ?emitter:T, scale:Float = 1):T{
        if (emitter == null)
            {
                emitter = cast new FlxEmitter();
            }
            if ((particleGraphic is String)) {
                var datapng = FNFAssets.getBitmapData(particleGraphic);
            }

            var config:Access = FlxPexParser.getAccessNode(data);
    
            // Need to extract the particle graphic information
            var particle:FlxParticle = new FlxParticle();
            particle.loadGraphic(particleGraphic);
    
            var emitterType = Std.parseInt(config.node.emitterType.att.value);
            if (emitterType != PexEmitterType.GRAVITY)
            {
                FlxG.log.warn("FlxPexParser: This emitter type isn't supported. Only the 'Gravity' emitter type is supported.");
            }
    
            var maxParticles:Int = Std.parseInt(config.node.maxParticles.att.value);
    
            var lifespan = FlxPexParser.minMax("particleLifeSpan", "particleLifespanVariance", config);
            var speed = FlxPexParser.minMax("speed", config);
    
            var angle = FlxPexParser.minMax("angle", config);
    
            var startSize = FlxPexParser.minMax("startParticleSize", config);
            var finishSize = FlxPexParser.minMax("finishParticleSize", "finishParticleSizeVariance", config);
            var rotationStart = FlxPexParser.minMax("rotationStart", config);
            var rotationEnd = FlxPexParser.minMax("rotationEnd", config);
    
            var sourcePositionVariance = FlxPexParser.xy("sourcePositionVariance", config);
            var gravity = FlxPexParser.xy("gravity", config);
    
            var startColors = FlxPexParser.color("startColor", config);
            var finishColors = FlxPexParser.color("finishColor", config);
    
            emitter.launchMode = FlxEmitterMode.CIRCLE;
            emitter.loadParticles(particleGraphic, maxParticles);
    
            emitter.width = (sourcePositionVariance.x == 0 ? 1 : sourcePositionVariance.x * 2) * scale;
            emitter.height = (sourcePositionVariance.y == 0 ? 1 : sourcePositionVariance.y * 2) * scale;
    
            emitter.lifespan.set(lifespan.min, lifespan.max);
    
            emitter.acceleration.set(gravity.x * scale, gravity.y * scale);
    
            emitter.launchAngle.set(angle.min, angle.max);
    
            emitter.speed.start.set(speed.min * scale, speed.max * scale);
            emitter.speed.end.set(speed.min * scale, speed.max * scale);
    
            emitter.angle.set(rotationStart.min, rotationStart.max, rotationEnd.min, rotationEnd.max);
    
            emitter.scale.start.min.set(startSize.min / particle.frameWidth * scale, startSize.min / particle.frameHeight * scale);
            emitter.scale.start.max.set(startSize.max / particle.frameWidth * scale, startSize.max / particle.frameHeight * scale);
            emitter.scale.end.min.set(finishSize.min / particle.frameWidth * scale, finishSize.min / particle.frameHeight * scale);
            emitter.scale.end.max.set(finishSize.max / particle.frameWidth * scale, finishSize.max / particle.frameHeight * scale);
    
            emitter.alpha.set(startColors.minColor.alphaFloat, startColors.maxColor.alphaFloat, finishColors.minColor.alphaFloat,
                finishColors.maxColor.alphaFloat);
            emitter.color.set(startColors.minColor, startColors.maxColor, finishColors.minColor, finishColors.maxColor);
    
            if (config.hasNode.blendFuncSource && config.hasNode.blendFuncDestination)
            {
                /**
                 * ParticleDesigner blend function values:
                 *
                 * 0x000: ZERO
                 * 0x001: ONE
                 * 0x300: SOURCE_COLOR
                 * 0x301: ONE_MINUS_SOURCE_COLOR
                 * 0x302: SOURCE_ALPHA
                 * 0x303: ONE_MINUS_SOURCE_ALPHA
                 * 0x304: DESTINATION_ALPHA
                 * 0x305: ONE_MINUS_DESTINATION_ALPHA
                 * 0x306: DESTINATION_COLOR
                 * 0x307: ONE_MINUS_DESTINATION_COLOR
                **/
    
                var src = Std.parseInt(config.node.blendFuncSource.att.value),
                    dst = Std.parseInt(config.node.blendFuncDestination.att.value);
    
                emitter.blend = switch ((src << 12) | dst)
                {
                    case 0x306303:
                        BlendMode.MULTIPLY;
                    case 0x001301:
                        BlendMode.SCREEN;
                    case 0x001303, 0x302303:
                        BlendMode.NORMAL;
                    default:
                        BlendMode.ADD;
                }
            }
            else
            {
                emitter.blend = BlendMode.ADD;
            }
            emitter.keepScaleRatio = true;
            return emitter;

    }
}
class PluginManager {
    public static var interp = new InterpEx();
    public static var hscriptClasses:Array<String> = [];
    public static var hscriptInstances:Array<Dynamic> = [];
    //private static var nextId:Int = 1;
	@:access(hscript.InterpEx)
    public static function init() 
    {
        //checks if the text file that has the names of the classes stored exists, otherwise this function will do nothing.
        if (!FNFAssets.exists("assets/scripts/plugin_classes/classes.txt"))
            return;
        
        //split lines of text, given to separate them into different names. something basic but powerful.
        var filelist = hscriptClasses = CoolUtil.coolTextFile("assets/scripts/plugin_classes/classes.txt");
		addVarsToInterp(interp); //this little thing is responsible for adding the corresponding variables.
        HscriptGlobals.init();
        for (file in filelist) {
            if (FNFAssets.exists("assets/scripts/plugin_classes/" + file + ".hx")) {
				interp.addModule(FNFAssets.getText("assets/scripts/plugin_classes/" + file + '.hx'));
            }
        }
        trace(InterpEx._scriptClassDescriptors);
    }

    /**
     * Create a simple interp, that already added all the needed shit
     * This is what has all the default things for hscript.
     * @see https://github.com/TheDrawingCoder-Gamer/Funkin/wiki/HScript-Commands
     * @return Interp
     */
    public static function createSimpleInterp():Interp {
        var reterp = new Interp();
        reterp = addVarsToInterp(reterp);
        return reterp;
    }

    public static function instanceExClass(classname:String, args:Array<Dynamic> = null) {
		return interp.createScriptClassInstance(classname, args);
	}
    public static function addCamera():FlxCamera{
	    var dummyCam = new FlxCamera();
	    dummyCam.bgColor.alpha = 0;
	    FlxG.cameras.add(dummyCam);
	    return dummyCam;
    }
    static function addEffectSpriteVars<T:Interp>(interp:T):T{
        interp.variables.set("FlxEffectSprite", FlxEffectSprite);
		interp.variables.set("FlxOutlineEffect", FlxOutlineEffect);
        interp.variables.set("FlxRainbowEffect", FlxRainbowEffect);
        interp.variables.set("FlxShakeEffect", FlxShakeEffect);
        interp.variables.set("FlxTrailEffect", FlxTrailEffect);
		interp.variables.set("FlxWaveEffect", FlxWaveEffect);
        interp.variables.set("IFlxEffect", IFlxEffect);
        interp.variables.set("FlxGlitchDirection", FlxGlitchDirection);
        interp.variables.set("FlxOutlineMode", FlxOutlineMode);
        interp.variables.set("FlxWaveMode", FlxWaveMode);
        interp.variables.set("FlxWaveDirection", FlxWaveDirection);
        interp.variables.set("FlxGlitchEffect", FlxGlitchEffect);
        return interp;
        
    }
    public static function addVarsToInterp<T:Interp>(interp:T):T {
        #if mobile
        interp.variables.set("FlxActionMode", FlxActionMode);
        interp.variables.set("FlxDPadMode", FlxDPadMode);
        interp.variables.set("FlxVirtualPad", FlxVirtualPad);
        #end
        interp.variables.set("blendModeFromString", function(blend){
            switch(blend.toLowerCase().trim()) {
                case 'add': return ADD;
                case 'alpha': return ALPHA;
                case 'darken': return DARKEN;
                case 'difference': return DIFFERENCE;
                case 'erase': return ERASE;
                case 'hardlight': return HARDLIGHT;
                case 'invert': return INVERT;
                case 'layer': return LAYER;
                case 'lighten': return LIGHTEN;
                case 'multiply': return MULTIPLY;
                case 'overlay': return OVERLAY;
                case 'screen': return SCREEN;
                case 'shader': return SHADER;
                case 'subtract': return SUBTRACT;
            }
            return NORMAL;
        });
		interp.variables.set("Conductor", Conductor);
	    interp.variables.set("addCamera", addCamera);
        interp.variables.set("FlxGifSprite", FlxGifSprite);
		interp.variables.set("FlxSprite", DynamicSprite);
        interp.variables.set("CustomSprite", CustomSprite);
		interp.variables.set("FlxSound", DynamicSound);
        interp.variables.set("FlxPexParser", DynamicPexParser);
        interp.variables.set("FlxAnimate", flxanimate.FlxAnimate);
        interp.variables.set("FlxParticle", FlxParticle);
        interp.variables.set("FlxEmitter", FlxEmitter);
		interp.variables.set("FlxAtlasFrames", DynamicSprite.DynamicAtlasFrames);
		interp.variables.set("FlxGroup", flixel.group.FlxGroup);
		interp.variables.set("FlxAngle", flixel.math.FlxAngle);
		interp.variables.set("FlxMath", flixel.math.FlxMath);
		interp.variables.set("TitleState", TitleState);
		interp.variables.set("makeRangeArray", CoolUtil.numberArray);
		interp.variables.set("FNFAssets", FNFAssets);
        interp.variables.set("CoolUtil", CoolUtil);
        interp.variables.set("Main", Main);
        interp.variables.set("AtlasFrameMaker", AtlasFrameMaker);
        interp.variables.set("FlxCamera", FlxCamera);
        interp.variables.set("ShaderCustom", ShaderCustom);
        interp.variables.set("ShaderFilter", ShaderFilter);
        #if VIDEOS_ALLOWED
        interp.variables.set("FlxVideo", FlxVideo);
        interp.variables.set("FlxVideoSprite", FlxVideoSprite);
#end
#if mobile
interp.variables.set("mobile", true);
#else
interp.variables.set("mobile", false);
#end
addEffectSpriteVars(interp);
		// : )
		interp.variables.set("FlxG", HscriptGlobals);
		interp.variables.set("FlxTimer", flixel.util.FlxTimer);
		interp.variables.set("FlxTween", flixel.tweens.FlxTween);
		interp.variables.set("Std", Std);
        interp.variables.set("SUtil", SUtil);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("MetroSprite", MetroSprite);
		interp.variables.set("FlxTrail", FlxTrail);
        interp.variables.set("Map", haxe.ds.StringMap);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("Reflect", Reflect);
		interp.variables.set("Character", Character);
		interp.variables.set("OptionsHandler", OptionsHandler);
        interp.variables.set("FlxText", FlxText);
        interp.variables.set("FlxTextBorderStyle", FlxTextBorderStyle);
        interp.variables.set("FlxBackdrop", FlxBackdrop);
        interp.variables.set("LoadingState", LoadingState);
        interp.variables.set("FlxRect", FlxRect);
        interp.variables.set("FlixG", FlxG);
        interp.variables.set("PluginManager", PluginManager);
        interp.variables.set("callExternClass", instanceExClass); //Call modules?? :D
		interp.variables.set("globalVars", Main.globalVars);
		interp.variables.set('addHaxeLibrary', function (libName:String, ?libFolder:String = '',varName:String = '') {
			try {
				if (varName == null || varName == '')
                    varName = libName;
				var str:String = '';
				if(libFolder.length > 0)
					str = libFolder + '.';
				interp.variables.set(varName, Type.resolveClass(str + libName));
			}
			catch (e) {
				openfl.Lib.application.window.alert(e.message, "ADD LIBRARY FAILED BRUH");
			}
		});

        //interp.variables.set("GitarooPause", GitarooPause);
		#if debug
		interp.variables.set("debug", true);
		#else
		interp.variables.set("debug", false);
		#end

        return interp;
    }
}
class HscriptGlobals {
    public static var VERSION = FlxG.VERSION;
    public static var autoPause(get, set):Bool;
    public static var bitmap(get, never):BitmapFrontEnd;
    // no bitmapLog
    public static var camera(get ,set):FlxCamera;
    public static var cameras(get, never):CameraFrontEnd;
    // no console frontend
    // no debugger frontend
    public static var drawFramerate(get, set):Int;
    public static var elapsed(get, never):Float;
    public static var fixedTimestep(get, set):Bool;
    public static var fullscreen(get, set):Bool;
    public static var game(get, never):FlxGame;
    public static var gamepads(get, never):FlxGamepadManager;
    public static var height(get, never):Int;
    public static var initialHeight(get, never):Int;
    public static var initialWidth(get, never):Int;
    //public static var initialZoom(get, never):Float;
    public static var inputs(get, never):InputFrontEnd;
    public static var keys(get, never):FlxKeyboard;
    // no log
    public static var maxElapsed(get, set):Float;
    public static var mouse = FlxG.mouse;
    // no plugins
    public static var random= FlxG.random;
    public static var renderBlit(get, never):Bool;
    public static var renderMethod(get, never):FlxRenderMethod;
    public static var renderTile(get, never):Bool;
    // no save because there are other ways to access it and i don't trust you guys
    public static var sound(default, null):HscriptSoundFrontEndWrapper;
    public static var stage(get, never):Stage;
    public static var state(get, never):FlxState;
    // no swipes because no mobile : ) YOU FOOL WE NEED MOBILE
    public static var timeScale(get, set):Float;
    // no touch because no mobile : )
    public static var updateFramerate(get,set):Int;
    // no vcr : )
    // no watch : )
    public static var width(get, never):Int;
    public static var worldBounds(get, never):FlxRect;
    public static var worldDivisions(get, set):Int;
    public static function init() {
        sound = new HscriptSoundFrontEndWrapper(FlxG.sound);
    }
    static function get_bitmap() {
        return FlxG.bitmap;
    }
    static function get_cameras() {
        return FlxG.cameras;
    }
    static function get_autoPause():Bool {
        return FlxG.autoPause;
    }
    static function set_autoPause(b:Bool):Bool {
        return FlxG.autoPause = b;
    }
	static function get_drawFramerate():Int
	{
		return FlxG.drawFramerate;
	}

	static function set_drawFramerate(b:Int):Int
	{
		return FlxG.drawFramerate = b;
	}
    static function get_elapsed():Float {
        return FlxG.elapsed;
    }
	static function get_fixedTimestep():Bool
	{
		return FlxG.fixedTimestep;
	}

	static function set_fixedTimestep(b:Bool):Bool
	{
		return FlxG.fixedTimestep = b;
	}
	static function get_fullscreen():Bool
	{
		return FlxG.fullscreen;
	}

	static function set_fullscreen(b:Bool):Bool
	{
		return FlxG.fullscreen = b;
	}
    static function get_height():Int {
        return FlxG.height;
    }
    static function get_initialHeight():Int {
        return FlxG.initialHeight;
    }
    static function get_camera():FlxCamera {
        return FlxG.camera;
    }
    static function set_camera(c:FlxCamera):FlxCamera {
        return FlxG.camera = c;
    }
    static function get_game():FlxGame {
        return FlxG.game;
    }
    static function get_gamepads():FlxGamepadManager {
        return FlxG.gamepads;
    }
    static function get_initialWidth():Int {
        return FlxG.initialWidth;
    }
    //static function get_initialZoom():Float {
    //    return FlxG.initialZoom;
    //}
    static function get_inputs() {
        return FlxG.inputs;
    }
    static function get_keys() {
        return FlxG.keys;
    }
    static function set_maxElapsed(s) {
        return FlxG.maxElapsed = s;
    }
    static function get_maxElapsed() {
        return FlxG.maxElapsed;
    }
    static function get_renderBlit() {
        return FlxG.renderBlit;
    }
    static function get_renderMethod() {
        return FlxG.renderMethod;
    }
    static function get_renderTile() {
        return FlxG.renderTile;
    }
    static function get_stage() {
        return FlxG.stage;
    }
    static function get_state() {
        return FlxG.state;
    }
    static function set_timeScale(s) {
        return FlxG.timeScale = s;
    }
    static function get_timeScale() {
        return FlxG.timeScale;
    }
    static function set_updateFramerate(s) {
        return FlxG.updateFramerate = s;
    }
    static function get_updateFramerate() {
        return FlxG.updateFramerate;
    }
    static function get_width() {
        return FlxG.width;
    }
    static function get_worldBounds() {
        return FlxG.worldBounds;
    }
    static function get_worldDivisions() {
        return FlxG.worldDivisions;
    }
	static function set_worldDivisions(s)
	{
		return FlxG.worldDivisions = s;
	}

    public static function addChildBelowMouse<T:DisplayObject>(Child:T, IndexModifier:Int = 0):T {
        return FlxG.addChildBelowMouse(Child, IndexModifier);
    }
    public static function addPostProcess(postProcess) {
        return FlxG.addPostProcess(postProcess);
    }
    public static function collide(?ObjectOrGroup1, ?ObjectOrGroup2, ?NotifyCallback) {
        return FlxG.collide(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback);
    }
    // no open url because i don't trust you guys

	public static function overlap(?ObjectOrGroup1, ?ObjectOrGroup2, ?NotifyCallback, ?ProcessCallback)
	{
		return FlxG.overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, ProcessCallback);
	}
    public static function pixelPerfectOverlap(Sprite1, Sprite2, AlphaTolerance = 255, ?Camera) {
        return FlxG.pixelPerfectOverlap(Sprite1, Sprite2, AlphaTolerance, Camera);
    }
    public static function removeChild<T:DisplayObject>(Child:T):T {
        return FlxG.removeChild(Child);
    }
    public static function removePostProcess(postProcess) {
        FlxG.removePostProcess(postProcess);
    }
    // no reset game or reset state because i don't trust you guys
    public static function resizeGame(Width, Height) {
        FlxG.resizeGame(Width, Height);
    }
    public static function resizeWindow(Width, Height) {
        FlxG.resizeWindow(Width, Height);
    }
    // no switch state because i don't trust you guys
}

class HscriptSoundFrontEndWrapper {

    var wrapping:SoundFrontEnd;
    public var defaultMusicGroup(get, set):FlxSoundGroup;
    public var defaultSoundGroup(get, set):FlxSoundGroup;
    public var list(get, never):FlxTypedGroup<FlxSound>;
    public var music (get, set):FlxSound;
    // no mute keys because why do you need that
    // no muted because i don't trust you guys
    // no soundtray enabled because i'm lazy 
    // no volume because i don't trust you guys
    function get_defaultMusicGroup() {
        return wrapping.defaultMusicGroup;
    }
    function set_defaultMusicGroup(a) {
        return wrapping.defaultMusicGroup = a;
    }
    function get_defaultSoundGroup() {
        return wrapping.defaultSoundGroup;
    }
    function set_defaultSoundGroup(a) {
        return wrapping.defaultSoundGroup = a;
    }
    function get_list() {
        return wrapping.list;
    }
    function get_music() {
        return wrapping.music;
    }
    function set_music(a) {
        return wrapping.music = a;
    }
    public function load(?EmbeddedSound:FlxSoundAsset, Volume = 1.0, Looped = false, ?Group, AutoDestroy = false, AutoPlay = false, ?URL, ?OnComplete) {
        if ((EmbeddedSound is String)) {
            var sound = FNFAssets.getSound(EmbeddedSound);
            return wrapping.load(sound, Volume, Looped, Group, AutoDestroy, AutoPlay, URL, OnComplete);
        }
        return wrapping.load(EmbeddedSound, Volume, Looped, Group, AutoDestroy, AutoPlay, URL, OnComplete);
    }
    public function pause() {
        wrapping.pause();
    }
    public function play(EmbeddedSound:FlxSoundAsset, Volume = 1.0, Looped = false, ?Group, AutoDestroy = true, ?OnComplete) {
        if ((EmbeddedSound is String)) {
            var sound = FNFAssets.getSound(EmbeddedSound);
            return wrapping.play(sound, Volume, Looped, Group, AutoDestroy, OnComplete);
        }
        return wrapping.play(EmbeddedSound, Volume, Looped, Group, AutoDestroy, OnComplete);
    }

    public function playMusic(Music:FlxSoundAsset,Volume= 1.0, Looped = true, ?Group ) {
        if ((Music is String)) {
            var sound = FNFAssets.getSound(Music);
            wrapping.playMusic(sound, Volume, Looped, Group);
            return;
        }
        wrapping.playMusic(Music, Volume, Looped, Group);        

    }
    public function resume() {
        wrapping.resume();
    }
    public function new(wrap:SoundFrontEnd) {
        wrapping = wrap;
    }
}
