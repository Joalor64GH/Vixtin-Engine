package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import haxe.Json;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
import sys.FileSystem;
import Song.SwagSong;
#end
import tjson.TJSON;
import flixel.input.keyboard.FlxKey;
#if mobile
import flixel.input.actions.FlxActionInput;
import android.AndroidControls.AndroidControls;
import android.FlxVirtualPad;
#end
using StringTools;
typedef DiscordJson = {
	var intro:String;
	var freeplay:String;
	var mainmenu:String;
};
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	
	static var initialized:Bool = false;
	static public var soundExt:String = ".ogg";
	static public var firstTime = false;

	// doing this shit again because it broke in the last build :grief: (start)
	// doing this shit again because it broke in the last build :grief: (end)

	// defining these variables now so i dont gotta do them later (start)
	public static var discordStuff:DiscordJson = CoolUtil.parseJson(FNFAssets.getJson(SUtil.getPath() + "assets/discord/presence/discord"));
	// defining these variables now so i dont gotta do them later (end)

	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];
	

	function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String) {
		// if function doesn't exist
			if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
				trace("Function doesn't exist, silently skipping...");
				return;
			}
			if (OptionsHandler.options.allowCrashHandler){
			try{
	
		var method = hscriptStates.get(usehaxe).variables.get(func_name);
		switch(args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
			case 2:
				method(args[0], args[1]);
			case 3:
				method(args[0], args[1], args[2]);
			case 4:
				method(args[0], args[1], args[2], args[3]);
			case 5:
				method(args[0], args[1], args[2], args[3], args[4]);
			case 6:
				method(args[0], args[1], args[2], args[3], args[4], args[5]);
			case 7:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
			case 8:
				method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
		}
	}
	catch(e){
		openfl.Lib.application.window.alert(e.message, "your function had some problem...");
	}
}
else{
	if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
		trace("Function doesn't exist, silently skipping...");
		return;
	}
	var method = hscriptStates.get(usehaxe).variables.get(func_name);
	switch(args.length) {
		case 0:
			method();
		case 1:
			method(args[0]);
		case 2:
			method(args[0], args[1]);
		case 3:
			method(args[0], args[1], args[2]);
		case 4:
			method(args[0], args[1], args[2], args[3]);
		case 5:
			method(args[0], args[1], args[2], args[3], args[4]);
		case 6:
			method(args[0], args[1], args[2], args[3], args[4], args[5]);
		case 7:
			method(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
		case 8:
			method(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
	}
}
}

	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		if (OptionsHandler.options.allowCrashHandler){
		try{
		hscriptStates.get(usehaxe).variables.set(name,value);
		}
		catch(e){
			openfl.Lib.application.window.alert(e.message, "your variable had some problem...");
		}
	}
	else
		hscriptStates.get(usehaxe).variables.set(name,value);
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		var theValue = hscriptStates.get(usehaxe).variables.get(name);
		return theValue;
	}
	function setAllHaxeVar(name:String, value:Dynamic) {
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}
	function makeHaxeState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getHscript(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("initialized", initialized);
		interp.variables.set("soundExt", soundExt);
		interp.variables.set("firstTime", firstTime);
		interp.variables.set("makeTransition", makeTransition);
		interp.variables.set("togglePersistUpdate", togglePersistUpdate);
		interp.variables.set("MainMenuState", MainMenuState);
		interp.variables.set("CategoryState", CategoryState);
		interp.variables.set("ChartingState", ChartingState);
		interp.variables.set("Alphabet", Alphabet);
		interp.variables.set("curBeat", 0);
		interp.variables.set("currentTitleState", this);
		interp.variables.set("getRandomObject",getRandomObject);
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
		interp.variables.set("pi", Math.PI);
		interp.variables.set("curMusicName", Main.curMusicName);
		#if mobile
		interp.variables.set("addVirtualPad", addVirtualPad);
		interp.variables.set("removeVirtualPad", removeVirtualPad);
		interp.variables.set("addPadCamera", addPadCamera);
		interp.variables.set("addAndroidControls", addAndroidControls);
		interp.variables.set("_virtualpad", _virtualpad);
		interp.variables.set("dPadModeFromString", dPadModeFromString);
		interp.variables.set("actionModeModeFromString", actionModeModeFromString);
	
		#end
		interp.variables.set("addVirtualPads", addVirtualPads);
		interp.variables.set("visPressed", visPressed);
		try{
			trace("set stuff");
			interp.execute(program);
			hscriptStates.set(usehaxe,interp);
			callHscript("create", [], usehaxe);
			trace('executed');
	}
	catch (e) {
		openfl.Lib.application.window.alert(e.message, "THE TITLE STATE CRASHED!");
		Sys.exit(1);
	}
	}
		function addVirtualPads(dPad:String,act:String){
		#if mobile
		addVirtualPad(dPadModeFromString(dPad),actionModeModeFromString(act));
		#end
	}
	#if mobile
	public function dPadModeFromString(lmao:String):FlxDPadMode{
	switch (lmao){
	case 'up_down':return FlxDPadMode.UP_DOWN;
	case 'left_right':return FlxDPadMode.LEFT_RIGHT;
	case 'up_left_right':return FlxDPadMode.UP_LEFT_RIGHT;
	case 'full':return FlxDPadMode.FULL;
	case 'right_full':return FlxDPadMode.RIGHT_FULL;
	case 'none':return FlxDPadMode.NONE;
	}
	return FlxDPadMode.NONE;
	}
	public function actionModeModeFromString(lmao:String):FlxActionMode{
		switch (lmao){
		case 'a':return FlxActionMode.A;
		case 'b':return FlxActionMode.B;
		case 'd':return FlxActionMode.D;
		case 'a_b':return FlxActionMode.A_B;
		case 'a_b_c':return FlxActionMode.A_B_C;
		case 'a_b_e':return FlxActionMode.A_B_E;
		case 'a_b_7':return FlxActionMode.A_B_7;
		case 'a_b_x_y':return FlxActionMode.A_B_X_Y;
		case 'a_b_c_x_y':return FlxActionMode.A_B_C_X_Y;
		case 'a_b_c_x_y_z':return FlxActionMode.A_B_C_X_Y_Z;
		case 'full':return FlxActionMode.FULL;
		case 'none':return FlxActionMode.NONE;
		}
		return FlxActionMode.NONE;
		}
	#end
	public function visPressed(dumbass:String = ''):Bool{
		#if mobile
		
		return _virtualpad.returnPressed(dumbass);
		#else
		return false;
		#end
	}
	function togglePersistUpdate(toggle:Bool)
	{
		persistentUpdate = toggle;
	}

	function changeCurMusicName(newName:String):String
	{
		Main.curMusicName = newName;
		setAllHaxeVar('curMusicName', newName);
		return (newName);
	}

	function makeTransition()
	{
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
	}
	function getRandomObject(object:Dynamic):Array<Dynamic>
	{
		return (FlxG.random.getObject(object));
	}

	override public function create():Void
	{
		FNFAssets.clearStoredMemory();
		
		#if desktop
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		// Updating Discord Rich Presence
		var customPrecence = discordStuff.intro;
		Discord.DiscordClient.changePresence(customPrecence, null);
		#end
		PluginManager.init();
		DifficultyManager.init();
		ModifierState.init();
		//curWacky = FlxG.random.getObject(getIntroTextShit());
		// DEBUG BULLSHIT
		super.create();
		FlxG.mouse.visible = false;
		FlxG.save.bind("preferredSave", "ElAnthonyVixtin");
		var preferredSave:Int = 0;
		if (Reflect.hasField(FlxG.save.data, "preferredSave")) {
			preferredSave = FlxG.save.data.preferredSave;
		} else {
			FlxG.save.data.preferredSave = 0;
		}

		FlxG.save.close();
		FlxG.save.bind("save"+preferredSave, 'ElAnthonyVixtin');
		PlayerSettings.init();
		Highscore.load();


		#if FREEPLAY
		LoadingState.loadAndSwitchState(new CategoryState());
		#elseif CHARTING
		LoadingState.loadAndSwitchState(new ChartingState());
		#else
		makeHaxeState("title", SUtil.getPath() + "assets/scripts/custom_menus/", "TitleState");
		#end
	}

	override function update(elapsed:Float)
	{
		callAllHScript("update", [elapsed]);
		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();
		FlxG.log.add(curBeat);
		setAllHaxeVar('curBeat', curBeat);
		callAllHScript('beatHit', [curBeat]);
	}

}
