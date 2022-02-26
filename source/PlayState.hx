package;

import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flash.system.System;
// Lua
#if cpp
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
#end
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
#if windows
import Discord.DiscordClient;
#end
#if cpp
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public static var instance:PlayState;

	private var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var cpuStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	public static var misses:Int = 0;

	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var campause:FlxCamera;
	private var camcustom:FlxCamera;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	public var songName:FlxText;

	// QT Week
	var hazardRandom:Int = 1; // This integer is randomised upon song start between 1-5.
	var cessationTroll:FlxSprite;
	var streetBG:FlxSprite;
	var qt_tv01:FlxSprite;
	// For detecting if the song has already ended internally for Careless's end song dialogue or something -Haz.
	var qtCarelessFin:Bool = false; // If true, then the song has ended, allowing for the school intro to play end dialogue instead of starting dialogue.
	var qtCarelessFinCalled:Bool = false; // Used for terminates meme ending to stop it constantly firing code when song ends or something.
	// For Censory Overload -Haz
	var qt_gas01:FlxSprite;
	var qt_gas02:FlxSprite;
	var vignette1:FlxSprite;
	var vignette2:FlxSprite;

	public static var cutsceneSkip:Bool = false;

	// For changing the visuals -Haz
	var streetBGerror:FlxSprite;
	var streetFrontError:FlxSprite;
	var dad404:Character;
	var gf404:Character;
	var boyfriend404:Boyfriend;
	var qtIsBlueScreened:Bool = false;

	// Termination-playable
	var bfDodging:Bool = false;
	var bfCanDodge:Bool = false;
	var bfDodgeTiming:Float = 0.22625;
	var bfDodgeCooldown:Float = 0.1135;
	var kb_attack_saw:FlxSprite;
	var kb_attack_alert:FlxSprite;
	var pincer1:FlxSprite;
	var pincer2:FlxSprite;
	var pincer3:FlxSprite;
	var pincer4:FlxSprite;

	public static var deathBySawBlade:Bool = false;

	var canSkipEndScreen:Bool = false; // This is set to true at the "thanks for playing" screen. Once true, in update, if enter is pressed it'll skip to the main menu.

	var noGameOver:Bool = false; // If on debug mode, pressing 5 would toggle this variable, making it impossible to die!

	var vignette:FlxSprite;

	var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	var camX:Int = 0;
	var camY:Int = 0;
	var cameramove:Bool = true;
	var forcecameramove:Bool = false;

	var kbsawbladecamXdad:Int = 0;
	var kbsawbladecamXbf:Int = 0;
	var forcecameratoplayer2:Bool = false;

	var fc:Bool = true;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	var dacamera:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	private var executeModchart = false;

	public var qtcantalknow1:FlxText;
	public var qtcantalknow2:FlxText;
	public var qtcantalknow3:FlxText;
	public var qtcantalknow4:FlxText;

	// LUA SHIT
	#if cpp
	public static var lua:State = null;

	function callLua(func_name:String, args:Array<Dynamic>, ?type:String):Dynamic
	{
		var result:Any = null;

		Lua.getglobal(lua, func_name);

		for (arg in args)
		{
			Convert.toLua(lua, arg);
		}

		result = Lua.pcall(lua, args.length, 1, 0);

		if (getLuaErrorMessage(lua) != null)
			if (Lua.tostring(lua, result) != null)
				throw(func_name + ' LUA CALL ERROR ' + Lua.tostring(lua, result));
			else
				trace(func_name + ' prolly doesnt exist lol');
		if (result == null)
		{
			return null;
		}
		else
		{
			return convert(result, type);
		}
	}

	function getType(l, type):Any
	{
		return switch Lua.type(l, type)
		{
			case t if (t == Lua.LUA_TNIL): null;
			case t if (t == Lua.LUA_TNUMBER): Lua.tonumber(l, type);
			case t if (t == Lua.LUA_TSTRING): (Lua.tostring(l, type) : String);
			case t if (t == Lua.LUA_TBOOLEAN): Lua.toboolean(l, type);
			case t: throw 'you don goofed up. lua type error ($t)';
		}
	}

	function getReturnValues(l)
	{
		var lua_v:Int;
		var v:Any = null;
		while ((lua_v = Lua.gettop(l)) != 0)
		{
			var type:String = getType(l, lua_v);
			v = convert(lua_v, type);
			Lua.pop(l, 1);
		}
		return v;
	}

	private function convert(v:Any, type:String):Dynamic
	{ // I didn't write this lol
		if (Std.isOfType(v, String) && type != null)
		{
			var v:String = v;
			if (type.substr(0, 4) == 'array')
			{
				if (type.substr(4) == 'float')
				{
					var array:Array<String> = v.split(',');
					var array2:Array<Float> = new Array();

					for (vars in array)
					{
						array2.push(Std.parseFloat(vars));
					}

					return array2;
				}
				else if (type.substr(4) == 'int')
				{
					var array:Array<String> = v.split(',');
					var array2:Array<Int> = new Array();

					for (vars in array)
					{
						array2.push(Std.parseInt(vars));
					}

					return array2;
				}
				else
				{
					var array:Array<String> = v.split(',');
					return array;
				}
			}
			else if (type == 'float')
			{
				return Std.parseFloat(v);
			}
			else if (type == 'int')
			{
				return Std.parseInt(v);
			}
			else if (type == 'bool')
			{
				if (v == 'true')
				{
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return v;
			}
		}
		else
		{
			return v;
		}
	}

	function getLuaErrorMessage(l)
	{
		var v:String = Lua.tostring(l, -1);
		Lua.pop(l, 1);
		return v;
	}

	public function setVar(var_name:String, object:Dynamic)
	{
		// trace('setting variable ' + var_name + ' to ' + object);

		Lua.pushnumber(lua, object);
		Lua.setglobal(lua, var_name);
	}

	public function getVar(var_name:String, type:String):Dynamic
	{
		var result:Any = null;

		// trace('getting variable ' + var_name + ' with a type of ' + type);

		Lua.getglobal(lua, var_name);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if (result == null)
		{
			return null;
		}
		else
		{
			var result = convert(result, type);
			// trace(var_name + ' result: ' + result);
			return result;
		}
	}

	function getActorByName(id:String):Dynamic
	{
		// pre defined names
		switch (id)
		{
			case 'boyfriend':
				return boyfriend;
			case 'girlfriend':
				return gf;
			case 'dad':
				return dad;
			case 'pincer1': // Termination shit
				return pincer1;
			case 'pincer2':
				return pincer2;
			case 'pincer3':
				return pincer3;
			case 'pincer4':
				return pincer4;
		}
		// lua objects or what ever
		if (luaSprites.get(id) == null)
			return strumLineNotes.members[Std.parseInt(id)];
		return luaSprites.get(id);
	}

	public static var luaSprites:Map<String, FlxSprite> = [];

	function makeLuaSprite(spritePath:String, toBeCalled:String, drawBehind:Bool)
	{
		#if sys
		var data:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/data/" + PlayState.SONG.song.toLowerCase() + '/' + spritePath + ".png");

		var sprite:FlxSprite = new FlxSprite(0, 0);
		var imgWidth:Float = FlxG.width / data.width;
		var imgHeight:Float = FlxG.height / data.height;
		var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;

		// Cap the scale at x1
		if (scale > 1)
		{
			scale = 1;
		}

		sprite.makeGraphic(Std.int(data.width * scale), Std.int(data.width * scale), FlxColor.TRANSPARENT);

		var data2:BitmapData = sprite.pixels.clone();
		var matrix:Matrix = new Matrix();
		matrix.identity();
		matrix.scale(scale, scale);
		data2.fillRect(data2.rect, FlxColor.TRANSPARENT);
		data2.draw(data, matrix, null, null, null, true);
		sprite.pixels = data2;

		luaSprites.set(toBeCalled, sprite);
		// and I quote:
		// shitty layering but it works!
		if (drawBehind)
		{
			remove(gf);
			remove(boyfriend);
			remove(dad);
		}
		add(sprite);
		if (drawBehind)
		{
			add(gf);
			add(boyfriend);
			add(dad);
		}
		#end
		return toBeCalled;
	}
	#end

	// LUA SHIT
	var hazardModChartDefaultStrumX:Array<Float> = [0, 0, 0, 0, 0, 0, 0, 0];
	var hazardModChartDefaultStrumY:Array<Float> = [0, 0, 0, 0, 0, 0, 0, 0];

	var hazardOverlayShit:BGSprite;
	var luisOverlayShit:BGSprite;
	var luisOverlayalt:BGSprite;

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (SONG.song.toLowerCase() == 'terminate')
			cameramove = false;

		instance = this;

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		repPresses = 0;
		repReleases = 0;

		#if sys
		executeModchart = FileSystem.exists(Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets //Hey, wtf is 'cpp targets'? -Haz
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));

		#if windows
		// Making difficulty text for Discord Rich Presence.
		if (SONG.song.toLowerCase() == "termination")
			storyDifficultyText = "Very Hard";
		else if (SONG.song.toLowerCase() == "cessation")
			storyDifficultyText = "Future";
		else
		{
			switch (storyDifficulty)
			{
				case 0:
					storyDifficultyText = "Easy";
				case 1:
					storyDifficultyText = "Normal";
				case 2:
					storyDifficultyText = "Hard";
			}
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'robot' | 'robot_classic' | 'robot_404' | 'robot_404-TERMINATION' | 'robot_classic_404':
				iconRPC = 'kb';
			case 'qt' | 'qt_annoyed':
				iconRPC = 'qt';
			case 'qt-kb':
				iconRPC = 'qt-kb';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ generateRanking(),
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camcustom = new FlxCamera();
		camcustom.bgColor.alpha = 0;
		campause = new FlxCamera();
		campause.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camcustom);
		FlxG.cameras.add(campause);

		if (FlxG.save.data.downscroll)
			camcustom.flashSprite.scaleY *= -1;
		else
			camcustom.flashSprite.scaleY *= 1;

		// FlxG.cameras.setDefaultDrawTarget(camGame, true); //i rlly hate haxe sometimes

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		HazStart();

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale);

		switch (SONG.song.toLowerCase())
		{
			case 'carefree':
				dialogue = CoolUtil.coolTextFile(Paths.txt('carefree/carefreeDialogue'));
			case 'careless':
				dialogue = CoolUtil.coolTextFile(Paths.txt('careless/carelessDialogue'));
			case 'cessation':
				dialogue = CoolUtil.coolTextFile(Paths.txt('cessation/finalDialogue'));
			case 'censory-overload':
				dialogue = CoolUtil.coolTextFile(Paths.txt('censory-overload/censory-overloadDialogue'));
			case 'terminate':
				dialogue = CoolUtil.coolTextFile(Paths.txt('terminate/terminateDialogue'));
		}

		switch (SONG.song.toLowerCase())
		{
			case 'carefree':
				{
					defaultCamZoom = 0.92125;
					// defaultCamZoom = 0.8125;
					curStage = 'streetCute';
					// Postitive = Right, Down
					// Negative = Left, Up
					var bg:FlxSprite = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBackCute'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFrontCute'));
					streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
					streetFront.updateHitbox();
					streetFront.antialiasing = true;
					streetFront.scrollFactor.set(0.9, 0.9);
					streetFront.active = false;
					add(streetFront);

					qt_tv01 = new FlxSprite(-62, 540).loadGraphic(Paths.image('stage/TV_V2_off'));
					qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
					qt_tv01.updateHitbox();
					qt_tv01.antialiasing = true;
					qt_tv01.scrollFactor.set(0.89, 0.89);
					qt_tv01.active = false;
					add(qt_tv01);
				}
			case 'cessation':
				{
					defaultCamZoom = 0.8125;
					curStage = 'streetCute';
					var bg:FlxSprite = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBackCute'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFrontCute'));
					streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
					streetFront.updateHitbox();
					streetFront.antialiasing = true;
					streetFront.scrollFactor.set(0.9, 0.9);
					streetFront.active = false;
					add(streetFront);

					qt_tv01 = new FlxSprite();
					qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V4');
					qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
					qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 28, false);
					qt_tv01.animation.addByPrefix('sus', 'TV_sus', 24, true);
					qt_tv01.animation.addByPrefix('heart', 'TV_End', 24, false);
					qt_tv01.setPosition(-62, 540);
					qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
					qt_tv01.updateHitbox();
					qt_tv01.antialiasing = true;
					qt_tv01.scrollFactor.set(0.89, 0.89);
					add(qt_tv01);
					qt_tv01.animation.play('heart');

					cessationTroll = new FlxSprite(-62, 540).loadGraphic(Paths.image('bonus/justkidding'));
					cessationTroll.setGraphicSize(Std.int(cessationTroll.width * 0.9));
					cessationTroll.cameras = [camHUD];
					cessationTroll.x = FlxG.width - 950;
					cessationTroll.y = 205;
				}
			case 'careless':
				{
					defaultCamZoom = 0.925;
					curStage = 'street';
					var bg:FlxSprite = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBack'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFront'));
					streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
					streetFront.updateHitbox();
					streetFront.antialiasing = true;
					streetFront.scrollFactor.set(0.9, 0.9);
					streetFront.active = false;
					add(streetFront);

					qt_tv01 = new FlxSprite();
					qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V5');
					qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
					qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 26, false);
					// qt_tv01.animation.addByPrefix('eye', 'TV_eyes', 24, true);
					qt_tv01.animation.addByPrefix('eye', 'TV_brutality', 24, true); // Replaced the hex eye with the brutality symbols for more accurate lore.
					qt_tv01.animation.addByPrefix('eyeLeft', 'TV_eyeLeft', 24, false);
					qt_tv01.animation.addByPrefix('eyeRight', 'TV_eyeRight', 24, false);

					qt_tv01.setPosition(-62, 540);
					qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
					qt_tv01.updateHitbox();
					qt_tv01.antialiasing = true;
					qt_tv01.scrollFactor.set(0.89, 0.89);
					add(qt_tv01);
					qt_tv01.animation.play('idle');
				}
			case 'censory-overload':
				{
					defaultCamZoom = 0.8125;

					curStage = 'streetFinal';

					if (!Main.qtOptimisation)
					{
						// Far Back Layer - Error (blue screen)
						var errorBG:FlxSprite = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetError'));
						errorBG.antialiasing = true;
						errorBG.scrollFactor.set(0.9, 0.9);
						errorBG.active = false;
						add(errorBG);

						// Back Layer - Error (glitched version of normal Back)
						streetBGerror = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBackError'));
						streetBGerror.antialiasing = true;
						streetBGerror.scrollFactor.set(0.9, 0.9);
						add(streetBGerror);
					}

					// Back Layer - Normal
					streetBG = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBack'));
					streetBG.antialiasing = true;
					streetBG.scrollFactor.set(0.9, 0.9);
					add(streetBG);

					// Front Layer - Normal
					var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFront'));
					streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
					streetFront.updateHitbox();
					streetFront.antialiasing = true;
					streetFront.scrollFactor.set(0.9, 0.9);
					streetFront.active = false;
					add(streetFront);

					if (!Main.qtOptimisation)
					{
						// Front Layer - Error (changes to have a glow)
						streetFrontError = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFrontError'));
						streetFrontError.setGraphicSize(Std.int(streetFrontError.width * 1.15));
						streetFrontError.updateHitbox();
						streetFrontError.antialiasing = true;
						streetFrontError.scrollFactor.set(0.9, 0.9);
						streetFrontError.active = false;
						add(streetFrontError);
						streetFrontError.visible = false;
					}

					qt_tv01 = new FlxSprite();
					qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V5');
					qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
					qt_tv01.animation.addByPrefix('eye', 'TV_brutality', 24, true); // Replaced the hex eye with the brutality symbols for more accurate lore.
					qt_tv01.animation.addByPrefix('error', 'TV_Error', 24, true);
					qt_tv01.animation.addByPrefix('404', 'TV_Bluescreen', 24, true);
					qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 32, false);
					qt_tv01.animation.addByPrefix('watch', 'TV_Watchout', 24, true);
					qt_tv01.animation.addByPrefix('drop', 'TV_Drop', 24, true);
					qt_tv01.animation.addByPrefix('sus', 'TV_sus', 24, true);
					qt_tv01.setPosition(-62, 540);
					qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
					qt_tv01.updateHitbox();
					qt_tv01.antialiasing = true;
					qt_tv01.scrollFactor.set(0.89, 0.89);
					add(qt_tv01);
					qt_tv01.animation.play('idle');

					// https://youtu.be/Nz0qjc8WRyY?t=1749
					// Wow, I guess it's that easy huh? -Haz
					if (!Main.qtOptimisation)
					{
						boyfriend404 = new Boyfriend(770, 450, 'bf_404');
						dad404 = new Character(100, 100, 'robot_404');
						gf404 = new Character(400, 130, 'gf_404');
						gf404.scrollFactor.set(0.95, 0.95);

						// These are set to 0 on first step. Not 0 here because otherwise they aren't cached in properly or something?
						// I dunno
						boyfriend404.alpha = 0.001;
						dad404.alpha = 0.001;
						gf404.alpha = 0.001;
					}
				}
			case 'terminate':
				{
					defaultCamZoom = 0.8125;
					curStage = 'street';
					var bg:FlxSprite = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBack'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFront'));
					streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
					streetFront.updateHitbox();
					streetFront.antialiasing = true;
					streetFront.scrollFactor.set(0.9, 0.9);
					streetFront.active = false;
					add(streetFront);

					qt_tv01 = new FlxSprite();
					qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V5');
					qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
					qt_tv01.animation.addByPrefix('error', 'TV_Error', 24, true);

					qt_tv01.setPosition(-62, 540);
					qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
					qt_tv01.updateHitbox();
					qt_tv01.antialiasing = true;
					qt_tv01.scrollFactor.set(0.89, 0.89);
					add(qt_tv01);
					qt_tv01.animation.play('idle');
				}
			case 'termination': // Seperated the two so terminate can load quicker (doesn't need to load in the attack animations and stuff)
				{
					defaultCamZoom = 0.8125;

					curStage = 'streetFinal';

					if (!Main.qtOptimisation)
					{
						// Far Back Layer - Error (blue screen)
						var errorBG:FlxSprite = new FlxSprite(-600, -150).loadGraphic(Paths.image('stage/streetError'));
						errorBG.antialiasing = true;
						errorBG.scrollFactor.set(0.9, 0.9);
						errorBG.active = false;
						add(errorBG);

						// Back Layer - Error (glitched version of normal Back)
						streetBGerror = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBackError'));
						streetBGerror.antialiasing = true;
						streetBGerror.scrollFactor.set(0.9, 0.9);
						add(streetBGerror);
					}

					// Back Layer - Normal
					streetBG = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBack'));
					streetBG.antialiasing = true;
					streetBG.scrollFactor.set(0.9, 0.9);
					add(streetBG);

					// Front Layer - Normal
					var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFront'));
					streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
					streetFront.updateHitbox();
					streetFront.antialiasing = true;
					streetFront.scrollFactor.set(0.9, 0.9);
					streetFront.active = false;
					add(streetFront);

					if (!Main.qtOptimisation)
					{
						// Front Layer - Error (changes to have a glow)
						streetFrontError = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFrontError'));
						streetFrontError.setGraphicSize(Std.int(streetFrontError.width * 1.15));
						streetFrontError.updateHitbox();
						streetFrontError.antialiasing = true;
						streetFrontError.scrollFactor.set(0.9, 0.9);
						streetFrontError.active = false;
						add(streetFrontError);
						streetFrontError.visible = false;
					}

					qt_tv01 = new FlxSprite();
					qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V5');
					qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
					qt_tv01.animation.addByPrefix('eye', 'TV_brutality', 24, true); // Replaced the hex eye with the brutality symbols for more accurate lore.
					qt_tv01.animation.addByPrefix('eyeRight', 'TV_eyeRight', 24, true);
					qt_tv01.animation.addByPrefix('eyeLeft', 'TV_eyeLeft', 24, true);
					qt_tv01.animation.addByPrefix('error', 'TV_Error', 24, true);
					qt_tv01.animation.addByPrefix('404', 'TV_Bluescreen', 24, true);
					qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 36, false);
					qt_tv01.animation.addByPrefix('watch', 'TV_Watchout', 24, true);
					qt_tv01.animation.addByPrefix('drop', 'TV_Drop', 24, true);
					qt_tv01.animation.addByPrefix('sus', 'TV_sus', 24, true);
					qt_tv01.animation.addByPrefix('instructions', 'TV_Instructions-Normal', 24, true);
					qt_tv01.animation.addByPrefix('gl', 'TV_GoodLuck', 24, true);
					qt_tv01.setPosition(-62, 540);
					qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
					qt_tv01.updateHitbox();
					qt_tv01.antialiasing = true;
					qt_tv01.scrollFactor.set(0.89, 0.89);
					add(qt_tv01);
					qt_tv01.animation.play('idle');

					// https://youtu.be/Nz0qjc8WRyY?t=1749
					// Wow, I guess it's that easy huh? -Haz
					if (!Main.qtOptimisation)
					{
						boyfriend404 = new Boyfriend(770, 450, 'bf_404');
						dad404 = new Character(100, 100, 'robot_404-TERMINATION');
						gf404 = new Character(400, 130, 'gf_404');
						gf404.scrollFactor.set(0.95, 0.95);

						// These are set to 0 on first step. Not 0 here because otherwise they aren't cached in properly or something?
						// I dunno
						boyfriend404.alpha = 0.001;
						dad404.alpha = 0.001;
						gf404.alpha = 0.001;
					}
				}
			case 'tutorial': // Tutorial now has the attack functions from Termination so you can call them using modcharts so hopefully people who want to make their own song don't have to go to the source code to manually code in the attack stuff.
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
			default:
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
				}
		}

		var gfVersion:String = 'gf';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'qt-meme':
				dad.y += 260;
			case 'qt_classic':
				dad.y += 255;
			case 'robot_classic' | 'robot_classic_404':
				dad.x += 110;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'streetFinal' | 'streetCute' | 'street':
				boyfriend.x += 40;
				boyfriend.y += 65;
				if (SONG.song.toLowerCase() == 'censory-overload' || SONG.song.toLowerCase() == 'termination')
				{
					dad.x -= 70;
					dad.y += 66;
					if (!Main.qtOptimisation)
					{
						boyfriend404.x += 40;
						boyfriend404.y += 65;
						dad404.x -= 70;
						dad404.y += 66;
					}
				}
				else if (SONG.song.toLowerCase() == 'terminate' || SONG.song.toLowerCase() == 'cessation')
				{
					dad.x -= 70;
					dad.y += 65;
				}
		}

		add(gf);
		add(dad);
		add(boyfriend);

		if (curStage == "nightmare")
		{
			dad.alpha = 0;
			gf.alpha = 0;
			add(boyfriend404);
		}

		if (SONG.song.toLowerCase() == 'censory-overload' || SONG.song.toLowerCase() == 'termination')
		{
			add(gf404);
			add(boyfriend404);
			add(dad404);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);
		trace(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (FlxG.save.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			// songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			songPosBar.createFilledBar(FlxColor.fromString('#' + dad.songPosbarempty), FlxColor.fromString('#' + dad.songPosbar));
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];

			if (curSong.toLowerCase() == 'terminate')
			{
				songPosBG.visible = false;
				songPosBar.visible = false;
				songName.visible = false;
			}
		}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (!FlxG.save.data.downscroll)
			healthBarBG.y += 10;
		else
			healthBarBG.y = 60;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.createFilledBar(FlxColor.fromString('#' + dad.iconColor), FlxColor.fromString('#' + boyfriend.iconColor));
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 26);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		if (!FlxG.save.data.downscroll)
			scoreTxt.y -= 135;
		else
			scoreTxt.y += 10;
		if (offsetTesting)
			scoreTxt.x += 300;
		else
		{
			scoreTxt.screenCenter(X);
			scoreTxt.x += 150;
		}
		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		if (loadRep)
			replayTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case 'carefree' | 'careless' | 'terminate':
					schoolIntro(doof);
				case 'censory-overload':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		if (!loadRep)
			rep = new Replay("na");

		hazardOverlayShit = new BGSprite('alert-vignette');
		hazardOverlayShit.setGraphicSize(FlxG.width, FlxG.height);
		hazardOverlayShit.screenCenter();
		hazardOverlayShit.x += (FlxG.width / 2) - 60;
		hazardOverlayShit.y += (FlxG.height / 2) - 20;
		hazardOverlayShit.updateHitbox();
		hazardOverlayShit.alpha = 0;
		hazardOverlayShit.cameras = [camcustom];
		add(hazardOverlayShit);

		luisOverlayShit = new BGSprite('vignette');
		luisOverlayShit.setGraphicSize(FlxG.width, FlxG.height);
		luisOverlayShit.screenCenter();
		luisOverlayShit.x += (FlxG.width / 2) - 60;
		luisOverlayShit.y += (FlxG.height / 2) - 20;
		luisOverlayShit.updateHitbox();
		luisOverlayShit.alpha = 0;
		luisOverlayShit.cameras = [camcustom];
		add(luisOverlayShit);

		luisOverlayalt = new BGSprite('vignettealt');
		luisOverlayalt.setGraphicSize(FlxG.width, FlxG.height);
		luisOverlayalt.screenCenter();
		luisOverlayalt.updateHitbox();
		luisOverlayalt.alpha = 0;
		luisOverlayalt.cameras = [camcustom];
		add(luisOverlayalt);

		if (curSong.toLowerCase() == 'careless')
			luisOverlayalt.alpha = 0.4;

		// Alert!
		kb_attack_alert = new FlxSprite();
		kb_attack_alert.frames = Paths.getSparrowAtlas('bonus/attack_alert_NEW', 'qt');
		kb_attack_alert.animation.addByPrefix('alert', 'kb_attack_animation_alert-single', 24, false);
		kb_attack_alert.animation.addByPrefix('alertDOUBLE', 'kb_attack_animation_alert-double', 24, false);
		kb_attack_alert.antialiasing = true;
		kb_attack_alert.setGraphicSize(Std.int(kb_attack_alert.width * 1.5));
		kb_attack_alert.cameras = [camHUD];
		kb_attack_alert.x = FlxG.width - 700;
		kb_attack_alert.y = 205;
		// kb_attack_alert.animation.play("alert"); //Placeholder, change this to start already hidden or whatever.

		// Saw that one coming!
		kb_attack_saw = new FlxSprite();
		kb_attack_saw.frames = Paths.getSparrowAtlas('bonus/attackv6', 'qt');
		kb_attack_saw.animation.addByPrefix('fire', 'kb_attack_animation_fire', 24, false);
		kb_attack_saw.animation.addByPrefix('prepare', 'kb_attack_animation_prepare', 24, false);
		kb_attack_saw.setGraphicSize(Std.int(kb_attack_saw.width * 1.15));
		kb_attack_saw.antialiasing = true;
		kb_attack_saw.setPosition(-860, 615);

		// Pincer shit for moving notes around for a little bit of trollin'
		pincer1 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close', 'qt'));
		pincer1.antialiasing = true;
		pincer1.scrollFactor.set();

		pincer2 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close', 'qt'));
		pincer2.antialiasing = true;
		pincer2.scrollFactor.set();

		pincer3 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close', 'qt'));
		pincer3.antialiasing = true;
		pincer3.scrollFactor.set();

		pincer4 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close', 'qt'));
		pincer4.antialiasing = true;
		pincer4.scrollFactor.set();

		if (FlxG.save.data.downscroll)
		{
			pincer4.angle = 270;
			pincer3.angle = 270;
			pincer2.angle = 270;
			pincer1.angle = 270;
			pincer1.offset.set(192, -75);
			pincer2.offset.set(192, -75);
			pincer3.offset.set(192, -75);
			pincer4.offset.set(192, -75);
		}
		else
		{
			pincer4.angle = 90;
			pincer3.angle = 90;
			pincer2.angle = 90;
			pincer1.angle = 90;
			pincer1.offset.set(218, 240);
			pincer2.offset.set(218, 240);
			pincer3.offset.set(218, 240);
			pincer4.offset.set(218, 240);
		}

		// Left gas
		qt_gas01 = new FlxSprite();
		qt_gas01.frames = Paths.getSparrowAtlas('stage/Gas_Release');
		qt_gas01.animation.addByPrefix('burst', 'Gas_Release', 38, false);
		qt_gas01.animation.addByPrefix('burstALT', 'Gas_Release', 49, false);
		qt_gas01.animation.addByPrefix('burstFAST', 'Gas_Release', 76, false);
		qt_gas01.animation.addByIndices('burstLoop', 'Gas_Release', [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], "", 38, true);
		qt_gas01.setGraphicSize(Std.int(qt_gas01.width * 2.5));
		qt_gas01.antialiasing = true;
		qt_gas01.scrollFactor.set();
		qt_gas01.alpha = 0.72;
		qt_gas01.setPosition(-520, -70);
		qt_gas01.angle = -31;

		// Right gas
		qt_gas02 = new FlxSprite();
		qt_gas02.frames = Paths.getSparrowAtlas('stage/Gas_Release');
		qt_gas02.animation.addByPrefix('burst', 'Gas_Release', 38, false);
		qt_gas02.animation.addByPrefix('burstALT', 'Gas_Release', 49, false);
		qt_gas02.animation.addByPrefix('burstFAST', 'Gas_Release', 76, false);
		qt_gas02.animation.addByIndices('burstLoop', 'Gas_Release', [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], "", 38, true);
		qt_gas02.setGraphicSize(Std.int(qt_gas02.width * 2.5));
		qt_gas02.antialiasing = true;
		qt_gas02.scrollFactor.set();
		qt_gas02.alpha = 0.72;
		qt_gas02.setPosition(520, -70);
		qt_gas02.angle = 31;

		if (!Main.qtOptimisation)
		{
			add(qt_gas01);
			qt_gas01.cameras = [camcustom];
			add(qt_gas02);
			qt_gas02.cameras = [camcustom];
		}

		deathBySawBlade = false; // Some reason, it keeps it's value after death, so this forces itself to reset to false.

		qtcantalknow1 = new FlxText(dad.x, dad.y - 100, 0, "", 20); // test
		qtcantalknow1.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.PINK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		qtcantalknow1.updateHitbox();
		qtcantalknow1.alpha = 0;
		qtcantalknow1.visible = false;
		// add(qtcantalknow1);
		qtcantalknow2 = new FlxText(qtcantalknow1.x, qtcantalknow1.y, 0, "", 20);
		qtcantalknow2.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		qtcantalknow2.alpha = 0;
		qtcantalknow2.visible = qtcantalknow1.visible;
		// add(qtcantalknow2);
		qtcantalknow3 = new FlxText(qtcantalknow2.x, qtcantalknow2.y, 0, "", 20);
		qtcantalknow3.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.CYAN, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		qtcantalknow3.alpha = 0;
		qtcantalknow3.visible = qtcantalknow1.visible;
		// add(qtcantalknow3);

		dacamera = defaultCamZoom; // ass

		super.create();
	}

	public function reloadHealthBarColors()
	{
		healthBar.createFilledBar(FlxColor.fromString('#' + dad.iconColor), FlxColor.fromString('#' + boyfriend.iconColor));

		healthBar.updateBar();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-300, -100).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		black.scrollFactor.set();

		FlxG.log.notice(qtCarelessFin);
		if (!qtCarelessFin)
		{
			add(black);
		}
		else
		{
			FlxTween.tween(FlxG.camera, {x: 0, y: 0}, 1.5, {
				ease: FlxEase.quadInOut
			});
		}

		trace(cutsceneSkip);
		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		var horrorStage:FlxSprite = new FlxSprite();
		if (!cutsceneSkip)
		{
			if (SONG.song.toLowerCase() == 'censory-overload')
			{
				camHUD.visible = false;
				// BG
				horrorStage.frames = Paths.getSparrowAtlas('stage/horrorbg');
				horrorStage.animation.addByPrefix('idle', 'Symbol 10 instance ', 24, false);
				horrorStage.antialiasing = true;
				horrorStage.scrollFactor.set();
				horrorStage.screenCenter();

				// QT sprite
				senpaiEvil.frames = Paths.getSparrowAtlas('cutscenev3');
				senpaiEvil.animation.addByPrefix('idle', 'final_edited', 24, false);
				senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 0.875));
				senpaiEvil.scrollFactor.set();
				senpaiEvil.updateHitbox();
				senpaiEvil.screenCenter();
				senpaiEvil.x -= 140;
				senpaiEvil.y -= 55;
			}
			else
			{
				senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
				senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
				senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
				senpaiEvil.scrollFactor.set();
				senpaiEvil.updateHitbox();
				senpaiEvil.screenCenter();
			}
		}
		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}
		else if (SONG.song.toLowerCase() == 'censory-overload' && !cutsceneSkip)
		{
			add(horrorStage);
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'censory-overload' && !cutsceneSkip)
					{
						// Background old
						// var horrorStage:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stage/horrorbg'));
						// horrorStage.antialiasing = true;
						// horrorStage.scrollFactor.set();
						// horrorStage.y-=125;
						// add(horrorStage);
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								horrorStage.animation.play('idle');
								FlxG.sound.play(Paths.sound('music-box-horror'), 0.9, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									remove(horrorStage);
									camHUD.visible = true;
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(13, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 3, false);
								});
							}
						});
					}
					else if (SONG.song.toLowerCase() == 'thorns' && !cutsceneSkip)
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else if (!qtCarelessFin)
				{
					startCountdown();
				}
				else
				{
					loadSongHazard();
				}

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];

	function startCountdown():Void
	{
		inCutscene = false;

		reloadStatics(false, true);

		#if cpp
		if (executeModchart) // dude I hate lua (jkjkjkjk)
		{
			trace('opening a lua state (because we are cool :))');
			lua = LuaL.newstate();
			LuaL.openlibs(lua);
			trace("Lua version: " + Lua.version());
			trace("LuaJIT version: " + Lua.versionJIT());
			Lua.init_callbacks(lua);

			var modchartFileName:String = "/modchart";
			if (SONG.song.toLowerCase() == 'termination' && storyDifficulty == 1)
				modchartFileName == "/modchartUNFAIR";

			var result = LuaL.dofile(lua, Paths.lua(PlayState.SONG.song.toLowerCase() + modchartFileName)); // execute le file

			if (result != 0)
				throw('COMPILE ERROR\n' + getLuaErrorMessage(lua));

			// get some fukin globals up in here bois

			setVar("difficulty", storyDifficulty);
			setVar("bpm", Conductor.bpm);
			setVar("fpsCap", FlxG.save.data.fpsCap);
			setVar("downscroll", FlxG.save.data.downscroll);

			setVar("curStep", 0);
			setVar("curBeat", 0);
			setVar("crochet", Conductor.stepCrochet);
			setVar("safeZoneOffset", Conductor.safeZoneOffset);

			setVar("hudZoom", camHUD.zoom);
			setVar("cameraZoom", FlxG.camera.zoom);

			setVar("cameraAngle", FlxG.camera.angle);
			setVar("camHudAngle", camHUD.angle);

			setVar("followXOffset", 0);
			setVar("followYOffset", 0);

			setVar("showOnlyStrums", false);
			setVar("strumLine1Visible", true);
			setVar("strumLine2Visible", true);

			setVar("screenWidth", FlxG.width);
			setVar("screenHeight", FlxG.height);
			setVar("hudWidth", camHUD.width);
			setVar("hudHeight", camHUD.height);

			// callbacks

			// sprites

			trace(Lua_helper.add_callback(lua, "makeSprite", makeLuaSprite));

			Lua_helper.add_callback(lua, "destroySprite", function(id:String)
			{
				var sprite = luaSprites.get(id);
				if (sprite == null)
					return false;
				remove(sprite);
				return true;
			});

			// Termination shit -Haz
			trace(Lua_helper.add_callback(lua, "kbAlertTOGGLE", function(toAdd:Bool)
			{
				KBALERT_TOGGLE(toAdd);
			}));
			trace(Lua_helper.add_callback(lua, "kbAttackTOGGLE", function(toAdd:Bool)
			{
				KBATTACK_TOGGLE(toAdd);
			}));
			trace(Lua_helper.add_callback(lua, "kbPincerPrepare", function(laneID:Int, goAway:Bool)
			{
				KBPINCER_PREPARE(laneID, goAway);
			}));
			trace(Lua_helper.add_callback(lua, "kbPincerGrab", function(laneID:Int)
			{
				KBPINCER_GRAB(laneID);
			}));
			trace(Lua_helper.add_callback(lua, "kbAttackAlert", function(pointless:Bool = false)
			{
				KBATTACK_ALERT(pointless);
			}));
			trace(Lua_helper.add_callback(lua, "kbAttackAlertDouble", function(pointless:Bool = false)
			{
				KBATTACK_ALERTDOUBLE(pointless);
			}));
			trace(Lua_helper.add_callback(lua, "kbAttack", function(prepare:Bool = false, sound:String = 'attack')
			{
				KBATTACK(prepare, sound);
			}));
			trace(Lua_helper.add_callback(lua, "dodgeTimingOverride", function(newValue:Float = 0.22625)
			{
				dodgeTimingOverride(newValue);
			}));
			trace(Lua_helper.add_callback(lua, "dodgeCooldownOverride", function(newValue:Float = 0.1135)
			{
				dodgeCooldownOverride(newValue);
			}));

			// hud/camera

			trace(Lua_helper.add_callback(lua, "setHudPosition", function(x:Int, y:Int)
			{
				camHUD.x = x;
				camHUD.y = y;
			}));

			trace(Lua_helper.add_callback(lua, "getHudX", function()
			{
				return camHUD.x;
			}));

			trace(Lua_helper.add_callback(lua, "getHudY", function()
			{
				return camHUD.y;
			}));

			trace(Lua_helper.add_callback(lua, "setCamPosition", function(x:Int, y:Int)
			{
				FlxG.camera.x = x;
				FlxG.camera.y = y;
			}));

			trace(Lua_helper.add_callback(lua, "getCameraX", function()
			{
				return FlxG.camera.x;
			}));

			trace(Lua_helper.add_callback(lua, "getCameraY", function()
			{
				return FlxG.camera.y;
			}));

			trace(Lua_helper.add_callback(lua, "setCamZoom", function(zoomAmount:Int)
			{
				FlxG.camera.zoom = zoomAmount;
			}));

			trace(Lua_helper.add_callback(lua, "setHudZoom", function(zoomAmount:Int)
			{
				camHUD.zoom = zoomAmount;
			}));

			// actors

			trace(Lua_helper.add_callback(lua, "getRenderedNotes", function()
			{
				return notes.length;
			}));

			trace(Lua_helper.add_callback(lua, "getRenderedNoteX", function(id:Int)
			{
				return notes.members[id].x;
			}));

			trace(Lua_helper.add_callback(lua, "getRenderedNoteY", function(id:Int)
			{
				return notes.members[id].y;
			}));

			trace(Lua_helper.add_callback(lua, "getRenderedNoteScaleX", function(id:Int)
			{
				return notes.members[id].scale.x;
			}));

			trace(Lua_helper.add_callback(lua, "setRenderedNotePos", function(x:Int, y:Int, id:Int)
			{
				notes.members[id].modifiedByLua = true;
				notes.members[id].x = x;
				notes.members[id].y = y;
			}));

			trace(Lua_helper.add_callback(lua, "setRenderedNoteAlpha", function(alpha:Float, id:Int)
			{
				notes.members[id].modifiedByLua = true;
				notes.members[id].alpha = alpha;
			}));

			trace(Lua_helper.add_callback(lua, "setRenderedNoteScale", function(scale:Float, id:Int)
			{
				notes.members[id].modifiedByLua = true;
				notes.members[id].setGraphicSize(Std.int(notes.members[id].width * scale));
			}));

			trace(Lua_helper.add_callback(lua, "setActorX", function(x:Int, id:String)
			{
				getActorByName(id).x = x;
			}));

			trace(Lua_helper.add_callback(lua, "setActorAlpha", function(alpha:Int, id:String)
			{
				getActorByName(id).alpha = alpha;
			}));

			trace(Lua_helper.add_callback(lua, "setActorY", function(y:Int, id:String)
			{
				getActorByName(id).y = y;
			}));

			trace(Lua_helper.add_callback(lua, "setActorAngle", function(angle:Int, id:String)
			{
				getActorByName(id).angle = angle;
			}));

			trace(Lua_helper.add_callback(lua, "setActorScale", function(scale:Float, id:String)
			{
				getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scale));
			}));

			trace(Lua_helper.add_callback(lua, "getActorWidth", function(id:String)
			{
				return getActorByName(id).width;
			}));

			trace(Lua_helper.add_callback(lua, "getActorHeight", function(id:String)
			{
				return getActorByName(id).height;
			}));

			trace(Lua_helper.add_callback(lua, "getActorAlpha", function(id:String)
			{
				return getActorByName(id).alpha;
			}));

			trace(Lua_helper.add_callback(lua, "getActorAngle", function(id:String)
			{
				return getActorByName(id).angle;
			}));

			trace(Lua_helper.add_callback(lua, "getActorX", function(id:String)
			{
				return getActorByName(id).x;
			}));

			trace(Lua_helper.add_callback(lua, "getActorY", function(id:String)
			{
				return getActorByName(id).y;
			}));

			// tweens

			Lua_helper.add_callback(lua, "tweenCameraPos", function(toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {x: toX, y: toY}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenCameraAngle", function(toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {angle: toAngle}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenCameraZoom", function(toZoom:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(FlxG.camera, {zoom: toZoom}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudPos", function(toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(camHUD, {x: toX, y: toY}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudAngle", function(toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(camHUD, {angle: toAngle}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenHudZoom", function(toZoom:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(camHUD, {zoom: toZoom}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, ["camera"]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPos", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {
					ease: FlxEase.cubeIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenFadeIn", function(id:String, toAlpha:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {
					ease: FlxEase.circIn,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			Lua_helper.add_callback(lua, "tweenFadeOut", function(id:String, toAlpha:Int, time:Float, onComplete:String)
			{
				FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {
					ease: FlxEase.circOut,
					onComplete: function(flxTween:FlxTween)
					{
						if (onComplete != '' && onComplete != null)
						{
							callLua(onComplete, [id]);
						}
					}
				});
			});

			// shader

			/*Lua_helper.add_callback(lua,"setRenderedNoteWiggle", function(id:Int, effectType:String, waveSpeed:Int, waveFrequency:Int) {
					trace('call');
					var wiggleEffect = new WiggleEffect();
					switch(effectType.toLowerCase())
					{
						case 'dreamy':
							wiggleEffect.effectType = WiggleEffectType.DREAMY;
						case 'wavy':
							wiggleEffect.effectType = WiggleEffectType.WAVY;
						case 'heat_wave_horizontal':
							wiggleEffect.effectType = WiggleEffectType.HEAT_WAVE_HORIZONTAL;
						case 'heat_wave_vertical':
							wiggleEffect.effectType = WiggleEffectType.HEAT_WAVE_VERTICAL;
						case 'flag':
							wiggleEffect.effectType = WiggleEffectType.FLAG;
					}
					wiggleEffect.waveFrequency = waveFrequency;
					wiggleEffect.waveSpeed = waveSpeed;
					wiggleEffect.shader.uTime.value = [(strumLine.y - Note.swagWidth * 4) / FlxG.height]; // from 4mbr0s3 2
					notes.members[id].shader = wiggleEffect.shader;
					luaWiggles.push(wiggleEffect);
				});

				Lua_helper.add_callback(lua,"setActorWiggle", function(id:String, effectType:String, waveSpeed:Int, waveFrequency:Int) {
					trace('call');
					var wiggleEffect = new WiggleEffect();
					switch(effectType.toLowerCase())
					{
						case 'dreamy':
							wiggleEffect.effectType = WiggleEffectType.DREAMY;
						case 'wavy':
							wiggleEffect.effectType = WiggleEffectType.WAVY;
						case 'heat_wave_horizontal':
							wiggleEffect.effectType = WiggleEffectType.HEAT_WAVE_HORIZONTAL;
						case 'heat_wave_vertical':
							wiggleEffect.effectType = WiggleEffectType.HEAT_WAVE_VERTICAL;
						case 'flag':
							wiggleEffect.effectType = WiggleEffectType.FLAG;
					}
					wiggleEffect.waveFrequency = waveFrequency;
					wiggleEffect.waveSpeed = waveSpeed;
					wiggleEffect.shader.uTime.value = [(strumLine.y - Note.swagWidth * 4) / FlxG.height]; // from 4mbr0s3 2
					getActorByName(id).shader = wiggleEffect.shader;
					luaWiggles.push(wiggleEffect);
			});*/

			for (i in 0...strumLineNotes.length)
			{
				var member = strumLineNotes.members[i];
				trace(strumLineNotes.members[i].x + " " + strumLineNotes.members[i].y + " " + strumLineNotes.members[i].angle + " | strum" + i);
				// setVar("strum" + i + "X", Math.floor(member.x));
				setVar("defaultStrum" + i + "X", Math.floor(member.x));
				// setVar("strum" + i + "Y", Math.floor(member.y));
				setVar("defaultStrum" + i + "Y", Math.floor(member.y));
				// setVar("strum" + i + "Angle", Math.floor(member.angle));
				setVar("defaultStrum" + i + "Angle", Math.floor(member.angle));
				trace("Adding strum" + i);
			}

			trace('calling start function');

			trace('return: ' + Lua.tostring(lua, callLua('start', [PlayState.SONG.song])));
		}
		#end
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (!Main.qtOptimisation && (SONG.song.toLowerCase() == 'censory-overload' || SONG.song.toLowerCase() == 'termination'))
			{
				dad404.dance();
				gf404.dance();
				boyfriend404.playAnim('idle');
			}
			dad.dance();
			camX = 0;
			camY = 0;
			gf.dance();
			boyfriend.dance();
			// boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		for (i in 0...playerStrums.length)
		{
			hazardModChartDefaultStrumX[i] = cpuStrums.members[i].x;
			hazardModChartDefaultStrumY[i] = cpuStrums.members[i].y;

			hazardModChartDefaultStrumX[i + 4] = playerStrums.members[i].x;
			hazardModChartDefaultStrumY[i + 4] = playerStrums.members[i].y;

			// trace("Strum1 X = ", hazardModChartDefaultStrumX[i+4]);
		}

		bfCanDodge = true;
		hazardRandom = FlxG.random.int(1, 5);
		/*if(curSong.toLowerCase() == 'tutorial'){ //Change this so that they appear when the relevant function is first called!!!!
			add(kb_attack_alert);
			add(kb_attack_saw);
		}*/

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (FlxG.save.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			// songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			songPosBar.createFilledBar(FlxColor.fromString('#' + dad.songPosbarempty), FlxColor.fromString('#' + dad.songPosbar));
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];

			if (curSong.toLowerCase() == 'terminate')
			{
				songPosBG.visible = false;
				songPosBar.visible = false;
				songName.visible = false;
			}
		}

		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToHeadbang = true;
			default:
				allowedToHeadbang = false;
		}

		// starting GF speed for censory-overload.
		if (SONG.song.toLowerCase() == 'censory-overload')
		{
			gfSpeed = 2;
			cutsceneSkip = true;
			trace(cutsceneSkip);
		}

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ generateRanking(),
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if cpp
		var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';
		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote;
				if (gottaHitNote)
					swagNote = new Note(daStrumTime, daNoteData, oldNote, false, true);
				else
					swagNote = new Note(daStrumTime, daNoteData, oldNote, false, false);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote;
					if (gottaHitNote)
						sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, true);
					else
						sustainNote = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, false);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function removeStatics()
	{
		playerStrums.forEach(function(todel:FlxSprite)
		{
			playerStrums.remove(todel);
			todel.destroy();
		});
		cpuStrums.forEach(function(todel:FlxSprite)
		{
			cpuStrums.remove(todel);
			todel.destroy();
		});
		strumLineNotes.forEach(function(todel:FlxSprite)
		{
			strumLineNotes.remove(todel);
			todel.destroy();
		});
	}

	private function generateStaticArrows(player:Int, tween:Bool = true):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(-40, strumLine.y);

			if (player == 0)
			{
				switch (dad.curCharacter)
				{
					case 'qt' | 'qt-kb' | 'qt_annoyed':
						babyArrow.frames = Paths.getSparrowAtlas('Notes/NOTE_assets_Qt');
					case 'robot' | 'robot_classic':
						babyArrow.frames = Paths.getSparrowAtlas('Notes/NOTE_assets_Kb');
					case 'robot_404' | 'robot_404-TERMINATION' | 'robot_classic_404':
						babyArrow.frames = Paths.getSparrowAtlas('Notes/NOTE_assets_Kb_Blue');
					case 'bf_404':
						babyArrow.frames = Paths.getSparrowAtlas('Notes/NOTE_assets_Blue');
					default:
						babyArrow.frames = Paths.getSparrowAtlas('Notes/NOTE_assets');
				}
			}
			else
			{
				switch (boyfriend.curCharacter)
				{
					case 'qt' | 'qt-kb' | 'qt_annoyed':
						babyArrow.frames = Paths.getSparrowAtlas('Notes/NOTE_assets_Kb');
					case 'robot' | 'robot_classic':
						babyArrow.frames = Paths.getSparrowAtlas('Notes/NOTE_assets_Kb');
					case 'robot_404' | 'robot_404-TERMINATION' | 'robot_classic_404':
						babyArrow.frames = Paths.getSparrowAtlas('Notes/NOTE_assets_Kb_Blue');
					case 'bf_404':
						babyArrow.frames = Paths.getSparrowAtlas('Notes/NOTE_assets_Blue');
					default:
						babyArrow.frames = Paths.getSparrowAtlas('Notes/NOTE_assets');
				}
			}

			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			trace(babyArrow.scale.x + "," + babyArrow.scale.y);

			{
				switch (Math.abs(i))
				{
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.addByPrefix('static', 'arrowLEFT');
						babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.addByPrefix('static', 'arrowDOWN');
						babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.addByPrefix('static', 'arrowUP');
						babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
						babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
				}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (tween)
			{
				if (SONG.song.toLowerCase() != "censory-overload")
					babyArrow.y -= 10;

				babyArrow.alpha = 0;

				if (SONG.song.toLowerCase() == "censory-overload")
					FlxTween.tween(babyArrow, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				else if (!(SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase() == "terminate"))
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					if (FlxG.save.data.midscroll)
						babyArrow.x -= 300;
					else
						babyArrow.x += 20;
					cpuStrums.add(babyArrow);

				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 110;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (FlxG.save.data.midscroll)
				babyArrow.x -= 280;
			if (FlxG.save.data.midscroll && player != 1)
				babyArrow.visible = false;

			strumLineNotes.add(babyArrow);
		}
	}

	private function reloadStatics(needremove = true, tweem = false)
	{
		if (needremove)
			removeStatics();
		generateStaticArrows(0, tweem);
		generateStaticArrows(1, tweem);
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ generateRanking(),
				"Acc: "
				+ truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ generateRanking(),
					"\nAcc: "
					+ truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ generateRanking(),
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	function HazStart()
	{
		// Don't spoil the fun for others.
		if (!Main.qtOptimisation)
		{
			if (FlxG.random.bool(5))
			{
				var horrorR:Int = FlxG.random.int(1, 6);
				var horror:FlxSprite;
				switch (horrorR)
				{
					case 2:
						horror = new FlxSprite(-80).loadGraphic(Paths.image('topsecretfolder/DoNotLook/horrorSecret02', 'week2'));
					case 3:
						horror = new FlxSprite(-80).loadGraphic(Paths.image('topsecretfolder/DoNotLook/horrorSecret03', 'week2'));
					case 4:
						horror = new FlxSprite(-80).loadGraphic(Paths.image('topsecretfolder/DoNotLook/horrorSecret04', 'week2'));
					case 5:
						horror = new FlxSprite(-80).loadGraphic(Paths.image('topsecretfolder/DoNotLook/horrorSecret05', 'week2'));
					case 6:
						horror = new FlxSprite(-80).loadGraphic(Paths.image('topsecretfolder/DoNotLook/horrorSecret06', 'week2'));
					default:
						horror = new FlxSprite(-80).loadGraphic(Paths.image('topsecretfolder/DoNotLook/horrorSecret01', 'week2'));
				}
				horror.scrollFactor.x = 0;
				horror.scrollFactor.y = 0.15;
				horror.setGraphicSize(Std.int(horror.width * 1.1));
				horror.updateHitbox();
				horror.screenCenter();
				horror.antialiasing = true;
				horror.cameras = [camHUD];
				add(horror);

				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					remove(horror);
				});
			}
		}
	}

	function generateRanking():String
	{
		var ranking:String = "N/A";

		if (misses == 0 && bads == 0 && shits == 0 && goods == 0) // Marvelous (SICK) Full Combo
			ranking = "(MFC)";
		else if (misses == 0 && bads == 0 && shits == 0 && goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "(GFC)";
		else if (misses == 0) // Regular FC
			ranking = "(FC)";
		else if (misses < 10) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		if (accuracy == 0)
			ranking = "N/A";

		return ranking;
	}

	public static var songRate = 1.5;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (hazardOverlayShit.alpha > 0) // Seperate if check because I'm paranoid of a crash -Haz
			hazardOverlayShit.alpha -= 1.2 * elapsed;

		#if cpp
		if (executeModchart && lua != null && songStarted)
		{
			setVar('songPos', Conductor.songPosition);
			setVar('hudZoom', camHUD.zoom);
			setVar('cameraZoom', FlxG.camera.zoom);
			callLua('update', [elapsed]);

			for (i in luaWiggles)
			{
				trace('wiggle le gaming');
				i.update(elapsed);
			}

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = getVar("strum" + i + "X", "float");
				member.y = getVar("strum" + i + "Y", "float");
				member.angle = getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = getVar('cameraAngle', 'float');
			camHUD.angle = getVar('camHudAngle', 'float');

			if (getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = getVar("strumLine1Visible", 'bool');
			var p2 = getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

		if (currentFrames == FlxG.save.data.fpsCap)
		{
			for (i in 0...notesHitArray.length)
			{
				var cock:Date = notesHitArray[i];
				if (cock != null)
					if (cock.getTime() + 2000 < Date.now().getTime())
						notesHitArray.remove(cock);
			}
			nps = Math.floor(notesHitArray.length / 2);
			currentFrames = 0;
		}
		else
			currentFrames++;

		/*if (FlxG.keys.justPressed.NINE)
			{
				if (iconP1.animation.curAnim.name == 'bf-old')
					iconP1.animation.play(SONG.player1);
				else
					iconP1.animation.play('bf-old');
		}*/

		super.update(elapsed);

		// For Lua
		instance = this;

		if (!offsetTesting)
		{
			if (FlxG.save.data.accuracyDisplay)
			{
				scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " | " : "")
					+ "Score:"
					+ (Conductor.safeFrames != 10 ? songScore + " (" + songScoreDef + ")" : "" + songScore)
					+ " | Misses:"
					+ misses
					+ " | Accuracy:"
					+ truncateFloat(accuracy, 2)
					+ "% | "
					+ generateRanking();
				scoreTxt.screenCenter(X);
				scoreTxt.x += 150;
			}
			else
			{
				scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " | " : "") + "Score:" + songScore;
			}
		}
		else
		{
			scoreTxt.text = "Suggested Offset: " + offsetTest;
		}
		if (FlxG.keys.justPressed.ENTER) // Modified so that enter can skip the thanks for playing screen.
		{
			if (startedCountdown && canPause)
			{
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					FlxG.switchState(new GitarooPause());
				}
				else
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else if (canSkipEndScreen)
			{
				loadSongHazard();
			}
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			#if cpp
			if (lua != null)
			{
				Lua.close(lua);
				lua = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
			if (lua != null)
			{
				Lua.close(lua);
				lua = null;
			}
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			if (!qtCarelessFin)
			{
				// Conductor.songPosition = FlxG.sound.music.time;
				Conductor.songPosition += FlxG.elapsed * 1000;
				/*@:privateAccess
					{
						FlxG.sound.music._channel.
				}*/
				songPositionBar = Conductor.songPosition;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
						// Conductor.songPosition += FlxG.elapsed * 1000;
						// trace('MISSED FRAME');
					}
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'Blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}

			if ((camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				|| (forcecameratoplayer2))
			{
				var offsetX = 0;
				var offsetY = 0;
				#if cpp
				if (lua != null)
				{
					offsetX = getVar("followXOffset", "float");
					offsetY = getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if cpp
				if (lua != null)
					callLua('playerTwoTurn', []);
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'qt' | 'qt_annoyed':
						camFollow.y = dad.getMidpoint().y + 261;
					case 'qt_classic':
						camFollow.y = dad.getMidpoint().y + 95;
					case 'robot' | 'robot_404' | 'robot_404-TERMINATION' | 'robot_classic' | 'robot_classic_404':
						camFollow.y = dad.getMidpoint().y + 20;
						camFollow.x = dad.getMidpoint().x - 18;
					case 'qt-kb':
						camFollow.y = dad.getMidpoint().y + 25;
						camFollow.x = dad.getMidpoint().x - 18;
					case 'qt-meme':
						camFollow.y = dad.getMidpoint().y + 107;
				}

				if ((cameramove && dad.curCharacter.startsWith("robot")) || forcecameramove)
				{
					camFollow.y += camY;

					camFollow.x += camX;
				}

				camFollow.x += kbsawbladecamXdad;

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;
			}
			else if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if cpp
				if (lua != null)
				{
					offsetX = getVar("followXOffset", "float");
					offsetY = getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				#if cpp
				if (lua != null)
					callLua('playerOneTurn', []);
				#end
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		if (loadRep) // rep debug
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);
		}
		// Mid-Song events for Censory-Overload
		if (curSong.toLowerCase() == 'censory-overload')
		{
			switch (curBeat)
			{
				/*case 4:
					//Experimental stuff
					FlxG.log.notice('Anything different?');
					qtIsBlueScreened = true;
					CensoryOverload404(); */
				case 64:
					qt_tv01.animation.play("eye");
				case 80: // First drop
					gfSpeed = 1;
					qt_tv01.animation.play("idle");
				case 208: // First drop end
					gfSpeed = 2;
				case 240: // 2nd drop hype!!!
					qt_tv01.animation.play("drop");
				case 304: // 2nd drop
					gfSpeed = 1;
				case 432: // 2nd drop end
					qt_tv01.animation.play("idle");
					gfSpeed = 2;
				case 558: // rawr xd
					FlxG.camera.shake(0.00425, 0.6725);
					qt_tv01.animation.play("eye");
				case 560: // 3rd drop
					gfSpeed = 1;
					qt_tv01.animation.play("idle");
				case 688: // 3rd drop end
					gfSpeed = 2;
				case 702:
					// Change to glitch background
					if (!Main.qtOptimisation)
					{
						streetBGerror.visible = true;
						streetBG.visible = false;
					}
					qt_tv01.animation.play("error");
					FlxG.camera.shake(0.0075, 0.67);
				case 704: // 404 section
					gfSpeed = 1;
					// Change to bluescreen background
					qt_tv01.animation.play("404");
					if (!Main.qtOptimisation)
					{
						streetBG.visible = false;
						streetBGerror.visible = false;
						streetFrontError.visible = true;
						qtIsBlueScreened = true;
						CensoryOverload404();
					}
				case 832: // Final drop
					// Revert back to normal
					if (!Main.qtOptimisation)
					{
						streetBG.visible = true;
						streetFrontError.visible = false;
						qtIsBlueScreened = false;
						CensoryOverload404();
					}
					gfSpeed = 1;
				case 960: // After final drop.
					qt_tv01.animation.play("idle");
				// gfSpeed = 2; //Commented out because I like gfSpeed being 1 rather then 2. -Haz
				case 1020:
					FlxTween.tween(strumLineNotes.members[0], {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
					FlxTween.tween(strumLineNotes.members[4], {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
					FlxTween.tween(scoreTxt, {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
				case 1021:
					FlxTween.tween(strumLineNotes.members[1], {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
					FlxTween.tween(strumLineNotes.members[5], {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
					FlxTween.tween(iconP1, {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
					FlxTween.tween(iconP2, {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
				case 1022:
					FlxTween.tween(strumLineNotes.members[2], {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
					FlxTween.tween(strumLineNotes.members[6], {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
					FlxTween.tween(healthBarBG, {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
					FlxTween.tween(healthBar, {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
				case 1023:
					FlxTween.tween(strumLineNotes.members[3], {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
					FlxTween.tween(strumLineNotes.members[7], {alpha: 0}, 0.2, {ease: FlxEase.sineInOut});
			}
		}
		else if (curSong.toLowerCase() == 'terminate')
		{ // For finishing the song early or whatever.
			if (curStep == 128)
			{
				dad.playAnim('singDOWN', true);
				if (!qtCarelessFinCalled)
					terminateEndEarly();
			}
		}
		if (health <= 0 && !noGameOver)
		{
			boyfriend.stunned = true;
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;
			vocals.stop();
			FlxG.sound.music.stop();
			if (curStage == "nightmare")
				System.exit(0);
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ generateRanking(),
				"\nAcc: "
				+ truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];

				notes.add(dunceNote);
				var index:Int = unspawnNotes.indexOf(dunceNote);

				unspawnNotes.splice(index, 1);
			}
		}
		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}
				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;
					var altAnim:String = "";
					// Makes KB's strums move back a bit to show his power... or something idfk it looks cool okay? -Haz
					if ((dad.curCharacter.startsWith('robot') || (dad.curCharacter.startsWith('qt'))) && !daNote.isSustainNote)
					{
						var scalex:Float = 0.694267515923567;
						var scaley:Float = 0.694267515923567;

						cpuStrums.members[daNote.noteData].scale.x = scalex + 0.2;
						cpuStrums.members[daNote.noteData].scale.y = scaley + 0.2;
						if (SONG.song.toLowerCase() != "terminate")
							FlxTween.tween(cpuStrums.members[daNote.noteData].scale, {y: scaley, x: scalex}, 0.125, {ease: FlxEase.cubeOut});

						if (dad.curCharacter.startsWith('robot'))
						{
							cpuStrums.members[daNote.noteData].y = hazardModChartDefaultStrumY[daNote.noteData] + (FlxG.save.data.downscroll ? 22 : -22);
							if (SONG.song.toLowerCase() != "terminate")
								FlxTween.tween(cpuStrums.members[daNote.noteData], {y: hazardModChartDefaultStrumY[daNote.noteData]}, 0.125,
									{ease: FlxEase.cubeOut});
						}
					}

					// this exist's because the new notes sheets don't have the scale animation
					if ((dad.curCharacter.startsWith('robot') || (dad.curCharacter.startsWith('qt'))) && !daNote.isSustainNote)
					{
						var scalex:Float = 0.694267515923567;
						var scaley:Float = 0.694267515923567;

						cpuStrums.members[daNote.noteData].scale.x = scalex + 0.2;
						cpuStrums.members[daNote.noteData].scale.y = scaley + 0.2;
						if (SONG.song.toLowerCase() != "terminate")
							FlxTween.tween(cpuStrums.members[daNote.noteData].scale, {y: scaley, x: scalex}, 0.125, {ease: FlxEase.cubeOut});
					}

					if (dad.curCharacter == "qt_annoyed" && FlxG.random.int(1, 17) == 2)
					{
						// Code for QT's random "glitch" alt animation to play.
						altAnim = '-alt';
						// Probably a better way of doing this by using the random int and throwing that at the end of the string... but I'm stupid and lazy. -Haz
						switch (FlxG.random.int(1, 3))
						{
							case 2:
								FlxG.sound.play(Paths.sound('glitch-error02'));
							case 3:
								FlxG.sound.play(Paths.sound('glitch-error03'));
							default:
								FlxG.sound.play(Paths.sound('glitch-error01'));
						}
						// 18.5% chance of an eye appearing on TV when glitching
						if (curStage == "street" && FlxG.random.bool(18.5))
						{
							if (!(curBeat >= 190 && curStep <= 898))
							{ // Makes sure the alert animation stuff isn't happening when the TV is playing the alert animation.
								if (FlxG.random.bool(52)) // Randomises whether the eye appears on left or right screen.
									qt_tv01.animation.play('eyeLeft');
								else
									qt_tv01.animation.play('eyeRight');
								qt_tv01.animation.finishCallback = function(pog:String)
								{
									if (qt_tv01.animation.curAnim.name == 'eyeLeft' || qt_tv01.animation.curAnim.name == 'eyeRight')
									{ // Making sure this only executes for only the eye animation played by the random chance. Probably a better way of doing it, but eh. -Haz
										qt_tv01.animation.play('idle');
									}
								}
							}
						}
					}
					else if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
						if (dad.curCharacter == 'qt-kb')
							forcecameramove = false;
					}
					if (SONG.song.toLowerCase() == "cessation")
					{
						if (curStep >= 640 && curStep <= 790) // first drop
						{
							altAnim = '-kb';
							if (dad.curCharacter == 'qt-kb')
								forcecameramove = true;
						}
						else if (curStep >= 1040 && curStep <= 1199)
						{
							altAnim = '-kb';
							if (dad.curCharacter == 'qt-kb')
								forcecameramove = true;
						}
					}
					// Responsible for playing the animations for the Dad. -Haz
					// Nice tutorial Hazard 24. -Luis

					if (!qtIsBlueScreened)
					{
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
						}
					}
					else
					{
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								dad404.playAnim('singLEFT' + altAnim, true);
							case 1:
								dad404.playAnim('singDOWN' + altAnim, true);
							case 2:
								dad404.playAnim('singUP' + altAnim, true);
							case 3:
								dad404.playAnim('singRIGHT' + altAnim, true);
						}
					}
					if ((cameramove && dad.curCharacter.startsWith("robot")) || forcecameramove)
					{
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								camX = -80;
								camY = 30;
							case 1:
								camY = 45;
								camX = -10;
							case 2:
								camY = -60;
								camX = -50;
							case 3:
								camX = 50;
								camY = -20;
						} // custom camera move :D
					}
					cpuStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
						if (spr.animation.curAnim.name == 'confirm')
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
					});
					#if cpp
					if (lua != null)
						callLua('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
					#end
					dad.holdTimer = 0;
					if (SONG.needsVoices)
						vocals.volume = 1;
					daNote.active = false;
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				if (FlxG.save.data.downscroll)
					daNote.y = (strumLine.y
						- (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed,
							2)));
				else
					daNote.y = (strumLine.y
						- (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed,
							2)));
				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				}
				if (daNote.isSustainNote)
					daNote.x += daNote.width / 2 + 17;
				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
				if ((daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
					&& daNote.mustPress)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					else
					{
						health -= 0.075;
						vocals.volume = 0;
						if (theFunne)
							noteMiss(daNote.noteData, daNote);
					}
					daNote.active = false;
					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		if (SONG.song.toLowerCase() != "terminate")
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}
		if (!inCutscene)
			keyShit();
		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		if (FlxG.keys.justPressed.FIVE)
		{
			noGameOver = !noGameOver;
			if (noGameOver)
				FlxG.sound.play(Paths.sound('glitch-error02'), 0.65);
			else
				FlxG.sound.play(Paths.sound('glitch-error03'), 0.65);
		}
		#end
	}

	// Call this function to update the visuals for Censory overload!
	function CensoryOverload404():Void
	{
		if (qtIsBlueScreened)
		{
			// Hide original versions
			boyfriend.alpha = 0.001;
			gf.alpha = 0.001;
			dad.alpha = 0.001;

			// New versions un-hidden.
			boyfriend404.alpha = 1;
			gf404.alpha = 1;
			dad404.alpha = 1;
			// fixes shit
			if (curSong.toLowerCase() == 'censory-overload')
				Gas_Release('burstLoop');
			if (FlxG.save.data.songPosition)
				songPosBar.createFilledBar(FlxColor.fromString('#FF0000FF'), FlxColor.fromString('#' + dad.songPosbar));
		}
		else
		{ // Reset back to normal
			// Return to original sprites.
			boyfriend404.alpha = 0;
			gf404.alpha = 0;
			dad404.alpha = 0;
			// Hide 404 versions
			boyfriend.alpha = 1;
			gf.alpha = 1;
			dad.alpha = 1;
			if (curSong.toLowerCase() == 'censory-overload')
				Gas_Release('burst');
			if (FlxG.save.data.songPosition)
				songPosBar.createFilledBar(FlxColor.fromString('#' + dad.songPosbarempty), FlxColor.fromString('#' + dad.songPosbar));
		}
		reloadStatics();
	}

	function dodgeTimingOverride(newValue:Float = 0.22625):Void
	{
		bfDodgeTiming = newValue;
	}

	function dodgeCooldownOverride(newValue:Float = 0.1135):Void
	{
		bfDodgeCooldown = newValue;
	}

	function KBATTACK_TOGGLE(shouldAdd:Bool = true):Void
	{
		if (shouldAdd)
			add(kb_attack_saw);
		else
			remove(kb_attack_saw);
	}

	function KBALERT_TOGGLE(shouldAdd:Bool = true):Void
	{
		if (shouldAdd)
			add(kb_attack_alert);
		else
			remove(kb_attack_alert);
	}

	// False state = Prime!
	// True state = Attack!
	function KBATTACK(state:Bool = false, soundToPlay:String = 'attack'):Void
	{
		trace("HE ATACC!");
		if (state)
		{
			FlxG.sound.play(Paths.sound(soundToPlay, 'qt'), 0.75);
			// Play saw attack animation
			kb_attack_saw.animation.play('fire');
			kb_attack_saw.offset.set(1600, 0);
			// FlxG.camera.zoom = defaultCamZoom;
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.06);
			forcecameratoplayer2 = false;
			kbsawbladecamXdad = 0;
			FlxG.camera.shake(0.00165, 0.6);
			camHUD.shake(0.00165, 0.2);
			// Slight delay for animation. Yeah I know I should be doing this using curStep and curBeat and what not, but I'm lazy -Haz
			new FlxTimer().start(0.09, function(tmr:FlxTimer)
			{
				if (!bfDodging)
				{
					// MURDER THE BITCH!
					deathBySawBlade = true;
					health -= 404;
				}
			});
		}
		else
		{
			kb_attack_saw.animation.play('prepare');
			kb_attack_saw.offset.set(-333, 0);
			// FlxG.camera.zoom -= 0.02;
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.03}, 0.06);
			forcecameratoplayer2 = true;
			kbsawbladecamXdad = -100;
		}
	}

	function KBATTACK_ALERT(pointless:Bool = false):Void // For some reason, modchart doesn't like functions with no parameter? why? dunno.
	{
		trace("DANGER!");
		kb_attack_alert.animation.play('alert');
		FlxG.sound.play(Paths.sound('alert', 'qt'), 1);
		// FlxG.camera.zoom -= 0.02;
		FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.03}, 0.06);
		forcecameratoplayer2 = true;
		kbsawbladecamXdad = -100;
		hazardOverlayShit.alpha = 0.5;
	}

	// OLD ATTACK DOUBLE VARIATION
	function KBATTACK_ALERTDOUBLE(pointless:Bool = false):Void
	{
		trace("DANGER DOUBLE INCOMING!!");
		kb_attack_alert.animation.play('alertDOUBLE');
		FlxG.sound.play(Paths.sound('alertDouble'), 1);
		forcecameratoplayer2 = true;
		kbsawbladecamXdad = -100;
		hazardOverlayShit.alpha = 0.55;
	}

	// Pincer logic, used by the modchart but can be hardcoded like saws if you want.
	function KBPINCER_PREPARE(laneID:Int, goAway:Bool):Void
	{
		// 1 = BF far left, 4 = BF far right. This only works for BF!
		// Update! 5 now refers to the far left lane. Mainly used for the shaking section or whatever.
		pincer1.cameras = [camHUD];
		pincer2.cameras = [camHUD];
		pincer3.cameras = [camHUD];
		pincer4.cameras = [camHUD];

		// This is probably the most disgusting code I've ever written in my life.
		// All because I can't be bothered to learn arrays and shit.
		// Would've converted this to a switch case but I'm too scared to change it so deal with it.
		if (laneID == 1)
		{
			pincer1.loadGraphic(Paths.image('bonus/pincer-open', 'qt'), false);
			if (FlxG.save.data.downscroll)
			{
				if (!goAway)
				{
					pincer1.setPosition(strumLineNotes.members[4].x, strumLineNotes.members[4].y + 500);
					add(pincer1);
					FlxTween.tween(pincer1, {y: strumLineNotes.members[4].y}, 0.3, {ease: FlxEase.elasticOut});
				}
				else
				{
					FlxTween.tween(pincer1, {y: strumLineNotes.members[4].y + 500}, 0.4, {
						ease: FlxEase.bounceIn,
						onComplete: function(twn:FlxTween)
						{
							remove(pincer1);
						}
					});
				}
			}
			else
			{
				if (!goAway)
				{
					pincer1.setPosition(strumLineNotes.members[4].x, strumLineNotes.members[4].y - 500);
					add(pincer1);
					FlxTween.tween(pincer1, {y: strumLineNotes.members[4].y}, 0.3, {ease: FlxEase.elasticOut});
				}
				else
				{
					FlxTween.tween(pincer1, {y: strumLineNotes.members[4].y - 500}, 0.4, {
						ease: FlxEase.bounceIn,
						onComplete: function(twn:FlxTween)
						{
							remove(pincer1);
						}
					});
				}
			}
		}
		else if (laneID == 5)
		{ // Targets far left note for Dad (KB). Used for the screenshake thing
			pincer1.loadGraphic(Paths.image('bonus/pincer-open', 'qt'), false);
			if (FlxG.save.data.downscroll)
			{
				if (!goAway)
				{
					pincer1.setPosition(strumLineNotes.members[0].x, strumLineNotes.members[0].y + 500);
					add(pincer1);
					FlxTween.tween(pincer1, {y: strumLineNotes.members[0].y}, 0.3, {ease: FlxEase.elasticOut});
				}
				else
				{
					FlxTween.tween(pincer1, {y: strumLineNotes.members[0].y + 500}, 0.4, {
						ease: FlxEase.bounceIn,
						onComplete: function(twn:FlxTween)
						{
							remove(pincer1);
						}
					});
				}
			}
			else
			{
				if (!goAway)
				{
					pincer1.setPosition(strumLineNotes.members[0].x, strumLineNotes.members[5].y - 500);
					add(pincer1);
					FlxTween.tween(pincer1, {y: strumLineNotes.members[0].y}, 0.3, {ease: FlxEase.elasticOut});
				}
				else
				{
					FlxTween.tween(pincer1, {y: strumLineNotes.members[0].y - 500}, 0.4, {
						ease: FlxEase.bounceIn,
						onComplete: function(twn:FlxTween)
						{
							remove(pincer1);
						}
					});
				}
			}
		}
		else if (laneID == 2)
		{
			pincer2.loadGraphic(Paths.image('bonus/pincer-open', 'qt'), false);
			if (FlxG.save.data.downscroll)
			{
				if (!goAway)
				{
					pincer2.setPosition(strumLineNotes.members[5].x, strumLineNotes.members[5].y + 500);
					add(pincer2);
					FlxTween.tween(pincer2, {y: strumLineNotes.members[5].y}, 0.3, {ease: FlxEase.elasticOut});
				}
				else
				{
					FlxTween.tween(pincer2, {y: strumLineNotes.members[5].y + 500}, 0.4, {
						ease: FlxEase.bounceIn,
						onComplete: function(twn:FlxTween)
						{
							remove(pincer2);
						}
					});
				}
			}
			else
			{
				if (!goAway)
				{
					pincer2.setPosition(strumLineNotes.members[5].x, strumLineNotes.members[5].y - 500);
					add(pincer2);
					FlxTween.tween(pincer2, {y: strumLineNotes.members[5].y}, 0.3, {ease: FlxEase.elasticOut});
				}
				else
				{
					FlxTween.tween(pincer2, {y: strumLineNotes.members[5].y - 500}, 0.4, {
						ease: FlxEase.bounceIn,
						onComplete: function(twn:FlxTween)
						{
							remove(pincer2);
						}
					});
				}
			}
		}
		else if (laneID == 3)
		{
			pincer3.loadGraphic(Paths.image('bonus/pincer-open', 'qt'), false);
			if (FlxG.save.data.downscroll)
			{
				if (!goAway)
				{
					pincer3.setPosition(strumLineNotes.members[6].x, strumLineNotes.members[6].y + 500);
					add(pincer3);
					FlxTween.tween(pincer3, {y: strumLineNotes.members[6].y}, 0.3, {ease: FlxEase.elasticOut});
				}
				else
				{
					FlxTween.tween(pincer3, {y: strumLineNotes.members[6].y + 500}, 0.4, {
						ease: FlxEase.bounceIn,
						onComplete: function(twn:FlxTween)
						{
							remove(pincer3);
						}
					});
				}
			}
			else
			{
				if (!goAway)
				{
					pincer3.setPosition(strumLineNotes.members[6].x, strumLineNotes.members[6].y - 500);
					add(pincer3);
					FlxTween.tween(pincer3, {y: strumLineNotes.members[6].y}, 0.3, {ease: FlxEase.elasticOut});
				}
				else
				{
					FlxTween.tween(pincer3, {y: strumLineNotes.members[6].y - 500}, 0.4, {
						ease: FlxEase.bounceIn,
						onComplete: function(twn:FlxTween)
						{
							remove(pincer3);
						}
					});
				}
			}
		}
		else if (laneID == 4)
		{
			pincer4.loadGraphic(Paths.image('bonus/pincer-open', 'qt'), false);
			if (FlxG.save.data.downscroll)
			{
				if (!goAway)
				{
					pincer4.setPosition(strumLineNotes.members[7].x, strumLineNotes.members[7].y + 500);
					add(pincer4);
					FlxTween.tween(pincer4, {y: strumLineNotes.members[7].y}, 0.3, {ease: FlxEase.elasticOut});
				}
				else
				{
					FlxTween.tween(pincer4, {y: strumLineNotes.members[7].y + 500}, 0.4, {
						ease: FlxEase.bounceIn,
						onComplete: function(twn:FlxTween)
						{
							remove(pincer4);
						}
					});
				}
			}
			else
			{
				if (!goAway)
				{
					pincer4.setPosition(strumLineNotes.members[7].x, strumLineNotes.members[7].y - 500);
					add(pincer4);
					FlxTween.tween(pincer4, {y: strumLineNotes.members[7].y}, 0.3, {ease: FlxEase.elasticOut});
				}
				else
				{
					FlxTween.tween(pincer4, {y: strumLineNotes.members[7].y - 500}, 0.4, {
						ease: FlxEase.bounceIn,
						onComplete: function(twn:FlxTween)
						{
							remove(pincer4);
						}
					});
				}
			}
		}
		else
			trace("Invalid LaneID for pincer");
	}

	function KBPINCER_GRAB(laneID:Int):Void
	{
		switch (laneID)
		{
			case 1 | 5:
				pincer1.loadGraphic(Paths.image('bonus/pincer-close', 'qt'), false);
			case 2:
				pincer2.loadGraphic(Paths.image('bonus/pincer-close', 'qt'), false);
			case 3:
				pincer3.loadGraphic(Paths.image('bonus/pincer-close', 'qt'), false);
			case 4:
				pincer4.loadGraphic(Paths.image('bonus/pincer-close', 'qt'), false);
			default:
				trace("Invalid LaneID for pincerGRAB");
		}
	}

	function terminateEndEarly():Void
	{
		if (!qtCarelessFinCalled)
		{
			qt_tv01.animation.play("error");
			canPause = false;
			inCutscene = true;
			paused = true;
			camZooming = false;
			qtCarelessFin = true;
			qtCarelessFinCalled = true; // Variable to prevent constantly repeating this code.
			cameramove = true;
			camX = -50; // camera move to left
			camY = 0;
			// Slight delay... -Haz
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				camHUD.visible = false;
				// FlxG.sound.music.pause();
				// vocals.pause();
				var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('terminate/terminateDialogueEND')));
				doof.scrollFactor.set();
				doof.finishThing = loadSongHazard;
				schoolIntro(doof);
			});
		}
	}

	function endScreenHazard():Void // For displaying the "thank you for playing" screen on Cessation
	{
		var black:FlxSprite = new FlxSprite(-300, -100).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		black.scrollFactor.set();

		var screen:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('bonus/FinalScreen'));
		screen.setGraphicSize(Std.int(screen.width * 0.625));
		screen.antialiasing = true;
		screen.scrollFactor.set();
		screen.screenCenter();

		var hasTriggeredAlready:Bool = false;

		screen.alpha = 0;
		black.alpha = 0;

		add(black);
		add(screen);

		// Fade in code stolen from schoolIntro() >:3
		new FlxTimer().start(0.15, function(swagTimer:FlxTimer)
		{
			black.alpha += 0.075;
			if (black.alpha < 1)
			{
				swagTimer.reset();
			}
			else
			{
				screen.alpha += 0.075;
				if (screen.alpha < 1)
				{
					swagTimer.reset();
				}

				canSkipEndScreen = true;
				// Wait 12 seconds, then do shit -Haz
				new FlxTimer().start(12, function(tmr:FlxTimer)
				{
					if (!hasTriggeredAlready)
					{
						hasTriggeredAlready = true;
						loadSongHazard();
					}
				});
			}
		});
	}

	function loadSongHazard():Void // Used for Careless, Termination, and Cessation when they end -Haz
	{
		canSkipEndScreen = false;

		// Very disgusting but it works... kinda
		if (SONG.song.toLowerCase() == 'cessation')
		{
			trace('Switching to MainMenu. Thanks for playing.');
			FlxG.sound.playMusic(Paths.music('thanks'));
			FlxG.switchState(new MainMenuState());
			Conductor.changeBPM(102); // lmao, this code doesn't even do anything useful! (aaaaaaaaaaaaaaaaaaaaaa)
		}
		else if (SONG.song.toLowerCase() == 'terminate')
		{
			FlxG.log.notice("Back to the menu you go!!!");

			FlxG.sound.playMusic(Paths.music('qtMenu'), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.725);

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			FlxG.switchState(new StoryMenuState());

			#if cpp
			if (lua != null)
			{
				Lua.close(lua);
				lua = null;
			}
			#end

			StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

			if (SONG.validScore)
			{
				NGio.unlockMedal(60961);
				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
			}

			if (storyDifficulty == 2) // You can only unlock Termination after beating story week on hard.
				FlxG.save.data.terminationUnlocked = true; // Congratulations, you unlocked hell! Have fun! ~♥
			// AH SHIT HERE GO AGAIN

			FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
			FlxG.save.flush();
		}
		else
		{
			var difficulty:String = "";
			if (storyDifficulty == 0)
				difficulty = '-easy';

			if (storyDifficulty == 2)
				difficulty = '-hard';

			trace('LOADING NEXT SONG');
			trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);
			FlxG.log.notice(PlayState.storyPlaylist[0].toLowerCase() + difficulty);
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			prevCamFollow = camFollow;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);

			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function endSong():Void
	{
		if (!loadRep)
			rep.SaveReplay();

		#if cpp
		if (executeModchart)
		{
			Lua.close(lua);
			lua = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
			#end
		}

		if (SONG.song.toLowerCase() == "termination")
		{
			FlxG.save.data.terminationBeaten = true; // Congratulations, you won!
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('qtMenu'), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.725);
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (SONG.song.toLowerCase() == 'cessation') // if placed at top cuz this should execute regardless of story mode. -Haz
			{
				camZooming = false;
				paused = true;
				qtCarelessFin = true;
				FlxG.sound.music.pause();
				vocals.pause();
				// Conductor.songPosition = 0;
				var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('cessation/finalDialogue')));
				doof.scrollFactor.set();
				doof.finishThing = endScreenHazard;
				camHUD.visible = false;
				schoolIntro(doof);
			}
			else if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (!(SONG.song.toLowerCase() == 'terminate'))
				{
					if (storyPlaylist.length <= 0)
					{
						FlxG.sound.playMusic(Paths.music('qtMenu'), 0);
						FlxG.sound.music.fadeIn(1, 0, 0.725);
						transIn = FlxTransitionableState.defaultTransIn;
						transOut = FlxTransitionableState.defaultTransOut;

						FlxG.switchState(new StoryMenuState());

						#if cpp
						if (lua != null)
						{
							Lua.close(lua);
							lua = null;
						}
						#end

						// if ()
						StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

						if (SONG.validScore)
						{
							NGio.unlockMedal(60961);
							Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
						FlxG.save.flush();
					}
					else
					{
						var difficulty:String = "";

						if (storyDifficulty == 0)
							difficulty = '-easy';

						if (storyDifficulty == 2)
							difficulty = '-hard';

						// For whatever reason, this stuff never gets called or something??? wtf Kade Engine?
						// UPDATE: Apparently this shit works, but the loading instantly stops anything from happening.
						if (SONG.song.toLowerCase() == 'eggnog')
						{
							var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
								-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
							blackShit.scrollFactor.set();
							add(blackShit);
							camHUD.visible = false;

							FlxG.sound.play(Paths.sound('Lights_Shut_off'));

							// Slight delay to allow sound to play. -Haz
							new FlxTimer().start(2, function(tmr:FlxTimer)
							{
								trace('LOADING NEXT SONG');
								trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);
								FlxTransitionableState.skipNextTransIn = true;
								FlxTransitionableState.skipNextTransOut = true;
								prevCamFollow = camFollow;

								PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
								FlxG.sound.music.stop();

								LoadingState.loadAndSwitchState(new PlayState());
							});
						}
						else if (SONG.song.toLowerCase() == 'careless')
						{
							camZooming = false;
							paused = true;
							qtCarelessFin = true;
							FlxG.sound.music.pause();
							vocals.pause();
							// Conductor.songPosition = 0;
							var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('careless/carelessDialogue2')));
							doof.scrollFactor.set();
							doof.finishThing = loadSongHazard;
							camHUD.visible = false;
							schoolIntro(doof);
						}
						else
						{
							trace('LOADING NEXT SONG');
							trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);
							FlxTransitionableState.skipNextTransIn = true;
							FlxTransitionableState.skipNextTransOut = true;
							prevCamFollow = camFollow;

							PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
							FlxG.sound.music.stop();

							LoadingState.loadAndSwitchState(new PlayState());
						}
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				FlxG.switchState(new FreeplayState());
			}
		}
	}

	var endingSong:Bool = false;
	var hits:Array<Float> = [];
	var offsetTest:Float = 0;
	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.1;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.25;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.06;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (health < 2)
					health += 0.03;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.09;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = truncateFloat(noteDiff, 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			add(rating);

			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				if (combo >= 10 || combo == 0)
					add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	private function keyShit():Void
	{
		// Dodge code only works on termination and Tutorial -Haz
		if (SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase() == 'tutorial')
		{
			// Dodge code, yes it's bad but oh well. -Haz
			// var dodgeButton = controls.ACCEPT; //I have no idea how to add custom controls so fuck it. -Haz

			if (FlxG.keys.justPressed.SPACE && !bfDodging && bfCanDodge)
				trace('butttonpressed');

			if (FlxG.keys.justPressed.SPACE && bfDodging)
				trace('butttonpressed but he is dodging');

			if (FlxG.keys.justPressed.SPACE && !bfCanDodge)
				trace('butttonpressed but he cant dodge');

			if (FlxG.keys.justPressed.SPACE && !bfDodging && bfCanDodge)
			{
				trace('DODGE START!');
				bfDodging = true;
				bfCanDodge = false;

				if (qtIsBlueScreened)
					boyfriend404.playAnim('dodge');
				else
					boyfriend.playAnim('dodge');

				FlxG.sound.play(Paths.sound('dodge01'));

				// Wait, then set bfDodging back to false. -Haz
				// V1.2 - Timer lasts a bit longer (by 0.00225)
				// new FlxTimer().start(0.22625, function(tmr:FlxTimer) 		//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				// new FlxTimer().start(0.15, function(tmr:FlxTimer)			//UNCOMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				new FlxTimer().start(bfDodgeTiming, function(tmr:FlxTimer) // COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				{
					bfDodging = false;
					boyfriend.dance(); // V1.3 = This forces the animation to end when you are no longer safe as the animation keeps misleading people.
					trace('DODGE END!');
					// Cooldown timer so you can't keep spamming it.
					// V1.3 = Incremented this by a little (0.005)
					// new FlxTimer().start(0.1135, function(tmr:FlxTimer) 	//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					// new FlxTimer().start(0.1, function(tmr:FlxTimer) 		//UNCOMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					new FlxTimer().start(bfDodgeCooldown, function(tmr:FlxTimer) // COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					{
						bfCanDodge = true;
						trace('DODGE RECHARGED!');
					});
				});
			}
		}

		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		// Press? -Haz
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		// Release? -Haz
		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		if (loadRep) // replay code
		{
			// disable input
			up = false;
			down = false;
			right = false;
			left = false;

			// new input

			// if (rep.replay.keys[repPresses].time == Conductor.songPosition)
			//	trace('DO IT!!!!!');

			// timeCurrently = Math.abs(rep.replay.keyPresses[repPresses].time - Conductor.songPosition);
			// timeCurrentlyR = Math.abs(rep.replay.keyReleases[repReleases].time - Conductor.songPosition);

			if (repPresses < rep.replay.keyPresses.length && repReleases < rep.replay.keyReleases.length)
			{
				upP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition
					&& rep.replay.keyPresses[repPresses].key == "up";
				rightP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition
					&& rep.replay.keyPresses[repPresses].key == "right";
				downP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition
					&& rep.replay.keyPresses[repPresses].key == "down";
				leftP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition
					&& rep.replay.keyPresses[repPresses].key == "left";

				upR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition
					&& rep.replay.keyReleases[repReleases].key == "up";
				rightR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition
					&& rep.replay.keyReleases[repReleases].key == "right";
				downR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition
					&& rep.replay.keyReleases[repReleases].key == "down";
				leftR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition
					&& rep.replay.keyReleases[repReleases].key == "left";

				upHold = upP ? true : upR ? false : true;
				rightHold = rightP ? true : rightR ? false : true;
				downHold = downP ? true : downR ? false : true;
				leftHold = leftP ? true : leftR ? false : true;
			}
		}
		else if (!loadRep) // record replay code
		{
			if (upP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "up"});
			if (rightP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "right"});
			if (downP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "down"});
			if (leftP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "left"});

			if (upR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "up"});
			if (rightR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "right"});
			if (downR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "down"});
			if (leftR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "left"});
		}
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			repPresses++;
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						if (loadRep)
						{
							var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

							daNote.rating = Ratings.CalculateRating(noteDiff);

							if (NearlyEquals(daNote.strumTime, rep.replay.keyPresses[repPresses].time, 30))
							{
								goodNoteHit(daNote);
								trace('force note hit');
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
							noteCheck(controlArray, daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							if (loadRep)
							{
								if (NearlyEquals(coolNote.strumTime, rep.replay.keyPresses[repPresses].time, 30))
								{
									var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);

									if (noteDiff > Conductor.safeZoneOffset * 0.70 || noteDiff < Conductor.safeZoneOffset * -0.70)
										coolNote.rating = "shit";
									else if (noteDiff > Conductor.safeZoneOffset * 0.50 || noteDiff < Conductor.safeZoneOffset * -0.50)
										coolNote.rating = "bad";
									else if (noteDiff > Conductor.safeZoneOffset * 0.45 || noteDiff < Conductor.safeZoneOffset * -0.45)
										coolNote.rating = "good";
									else if (noteDiff < Conductor.safeZoneOffset * 0.44 && noteDiff > Conductor.safeZoneOffset * -0.44)
										coolNote.rating = "sick";
									goodNoteHit(coolNote);
									trace('force note hit');
								}
								else
									noteCheck(controlArray, daNote);
							}
							else
								noteCheck(controlArray, coolNote);
						}
					}
				}
				else // regular notes?
				{
					if (loadRep)
					{
						if (NearlyEquals(daNote.strumTime, rep.replay.keyPresses[repPresses].time, 30))
						{
							var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

							daNote.rating = Ratings.CalculateRating(noteDiff);

							goodNoteHit(daNote);
							trace('force note hit');
						}
						else
							noteCheck(controlArray, daNote);
					}
					else
						noteCheck(controlArray, daNote);
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				// trace(daNote.noteData);
				/* 
					switch (daNote.noteData)
					{
						case 2: // NOTES YOU JUST PRESSED
							if (upP || rightP || downP || leftP)
								noteCheck(upP, daNote);
						case 3:
							if (upP || rightP || downP || leftP)
								noteCheck(rightP, daNote);
						case 1:
							if (upP || rightP || downP || leftP)
								noteCheck(downP, daNote);
						case 0:
							if (upP || rightP || downP || leftP)
								noteCheck(leftP, daNote);
					}
				 */
				if (daNote.wasGoodHit)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			}
		}

		if ((up || right || down || left)
			&& generatedMusic
			|| (upHold || downHold || leftHold || rightHold)
			&& loadRep
			&& generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 2:
							if (up || upHold)
								goodNoteHit(daNote);
						case 3:
							if (right || rightHold)
								goodNoteHit(daNote);
						case 1:
							if (down || downHold)
								goodNoteHit(daNote);
						case 0:
							if (left || leftHold)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && !bfDodging)
			{
				boyfriend.dance();
				// boyfriend.playAnim('idle');
			}
			if (qtIsBlueScreened)
			{
				if (boyfriend404.animation.curAnim.name.startsWith('sing')
					&& !boyfriend404.animation.curAnim.name.endsWith('miss')
					&& !bfDodging)
				{
					boyfriend404.playAnim('idle');
				}
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 2:
					if (loadRep)
					{
						/*if (upP)
							{
								spr.animation.play('pressed');
								new FlxTimer().start(Math.abs(rep.replay.keyPresses[repReleases].time - Conductor.songPosition) + 10, function(tmr:FlxTimer)
									{
										spr.animation.play('static');
										repReleases++;
									});
						}*/
					}
					else
					{
						if (upP && spr.animation.curAnim.name != 'confirm' && !loadRep)
						{
							spr.animation.play('pressed');
							// trace('play');
						}
						if (upR)
						{
							spr.animation.play('static');
							repReleases++;
						}
					}
				case 3:
					if (loadRep)
					{
						/*if (upP)
							{
								spr.animation.play('pressed');
								new FlxTimer().start(Math.abs(rep.replay.keyPresses[repReleases].time - Conductor.songPosition) + 10, function(tmr:FlxTimer)
									{
										spr.animation.play('static');
										repReleases++;
									});
						}*/
					}
					else
					{
						if (rightP && spr.animation.curAnim.name != 'confirm' && !loadRep)
							spr.animation.play('pressed');
						if (rightR)
						{
							spr.animation.play('static');
							repReleases++;
						}
					}
				case 1:
					if (loadRep)
					{
						/*if (upP)
							{
								spr.animation.play('pressed');
								new FlxTimer().start(Math.abs(rep.replay.keyPresses[repReleases].time - Conductor.songPosition) + 10, function(tmr:FlxTimer)
									{
										spr.animation.play('static');
										repReleases++;
									});
						}*/
					}
					else
					{
						if (downP && spr.animation.curAnim.name != 'confirm' && !loadRep)
							spr.animation.play('pressed');
						if (downR)
						{
							spr.animation.play('static');
							repReleases++;
						}
					}
				case 0:
					if (loadRep)
					{
						/*if (upP)
							{
								spr.animation.play('pressed');
								new FlxTimer().start(Math.abs(rep.replay.keyPresses[repReleases].time - Conductor.songPosition) + 10, function(tmr:FlxTimer)
									{
										spr.animation.play('static');
										repReleases++;
									});
						}*/
					}
					else
					{
						if (leftP && spr.animation.curAnim.name != 'confirm' && !loadRep)
							spr.animation.play('pressed');
						if (leftR)
						{
							spr.animation.play('static');
							repReleases++;
						}
					}
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			// You lose more health on QT's week. -Haz
			if (PlayState.SONG.song.toLowerCase() == 'carefree'
				|| PlayState.SONG.song.toLowerCase() == 'careless'
				|| PlayState.SONG.song.toLowerCase() == 'censory-overload')
			{
				health -= 0.0675;
			}
		}
		else if (PlayState.SONG.song.toLowerCase() == 'termination')
		{
			health -= 0.16725; // THAT'S ALOTA DAMAGE
		}
		else
		{
			health -= 0.05;
		}
		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			if (!qtIsBlueScreened)
				gf.playAnim('sad');
		}
		combo = 0;
		misses++;

		var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
		var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		songScore -= 10;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
		// FlxG.log.add('played imss note');

		if (!bfDodging)
		{
			if (!qtIsBlueScreened)
			{
				switch (direction)
				{
					case 0:
						boyfriend.playAnim('singLEFTmiss', true);
					case 1:
						boyfriend.playAnim('singDOWNmiss', true);
					case 2:
						boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
				}
			}
			else
			{
				switch (direction)
				{
					case 0:
						boyfriend404.playAnim('singLEFTmiss', true);
					case 1:
						boyfriend404.playAnim('singDOWNmiss', true);
					case 2:
						boyfriend404.playAnim('singUPmiss', true);
					case 3:
						boyfriend404.playAnim('singRIGHTmiss', true);
				}
			}
		}

		#if cpp
		if (lua != null)
			callLua('playerOneMiss', [direction, Conductor.songPosition]);
		#end

		updateAccuracy();
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	 */
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;
	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		if (noteDiff > Conductor.safeZoneOffset * 0.70 || noteDiff < Conductor.safeZoneOffset * -0.70)
			note.rating = "shit";
		else if (noteDiff > Conductor.safeZoneOffset * 0.50 || noteDiff < Conductor.safeZoneOffset * -0.50)
			note.rating = "bad";
		else if (noteDiff > Conductor.safeZoneOffset * 0.45 || noteDiff < Conductor.safeZoneOffset * -0.45)
			note.rating = "good";
		else if (noteDiff < Conductor.safeZoneOffset * 0.44 && noteDiff > Conductor.safeZoneOffset * -0.44)
			note.rating = "sick";

		if (loadRep)
		{
			if (controlArray[note.noteData])
				goodNoteHit(note);
			else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
			{
				if (NearlyEquals(note.strumTime, rep.replay.keyPresses[repPresses].time, 4))
				{
					goodNoteHit(note);
				}
			}
		}
		else if (controlArray[note.noteData])
		{
			for (b in controlArray)
			{
				if (b)
					mashing++;
			}

			// ANTI MASH CODE FOR THE BOYS

			if (mashing <= getKeyPresses(note) && mashViolations < 2)
			{
				mashViolations++;

				goodNoteHit(note, (mashing <= getKeyPresses(note)));
			}
			else
			{
				// this is bad but fuck you
				playerStrums.members[0].animation.play('static');
				playerStrums.members[1].animation.play('static');
				playerStrums.members[2].animation.play('static');
				playerStrums.members[3].animation.play('static');
				health -= 0.2;
				trace('mash ' + mashing);
			}

			if (mashing != 0)
				mashing = 0;
		}
	}

	var nps:Int = 0;

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);

		if (!note.isSustainNote)
			notesHitArray.push(Date.now());

		if (resetMashViolation)
			mashViolations--;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;

				if ((boyfriend.curCharacter.startsWith('robot') || (boyfriend.curCharacter.startsWith('qt'))))
				{
					var scalex:Float = 0.694267515923567;
					var scaley:Float = 0.694267515923567;

					playerStrums.members[note.noteData].scale.x = scalex + 0.2;
					playerStrums.members[note.noteData].scale.y = scaley + 0.2;
					if (SONG.song.toLowerCase() != "terminate")
						FlxTween.tween(playerStrums.members[note.noteData].scale, {y: scaley, x: scalex}, 0.125, {ease: FlxEase.cubeOut});

					if (boyfriend.curCharacter.startsWith('robot'))
					{
						// trace("KB shit");
						playerStrums.members[note.noteData].y = hazardModChartDefaultStrumY[note.noteData + 4] + (FlxG.save.data.downscroll ? 22 : -22);
						FlxTween.tween(playerStrums.members[note.noteData], {y: hazardModChartDefaultStrumY[note.noteData + 4]}, 0.126,
							{ease: FlxEase.cubeOut});
					}
				}
			}
			else
				totalNotesHit += 1;

			// Switch case for playing the animation for which note. -Haz
			if (!bfDodging)
			{
				if (!qtIsBlueScreened)
				{
					switch (note.noteData)
					{
						case 0:
							boyfriend.playAnim('singLEFT', true);
						case 1:
							boyfriend.playAnim('singDOWN', true);
						case 2:
							boyfriend.playAnim('singUP', true);
						case 3:
							boyfriend.playAnim('singRIGHT', true);
					}
				}
				else
				{
					switch (note.noteData)
					{
						case 0:
							boyfriend404.playAnim('singLEFT', true);
						case 1:
							boyfriend404.playAnim('singDOWN', true);
						case 2:
							boyfriend404.playAnim('singUP', true);
						case 3:
							boyfriend404.playAnim('singRIGH', true);
					}
				}
			}

			#if cpp
			if (lua != null)
				callLua('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep)
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.animation.play('confirm', true);
					}
				});

			note.wasGoodHit = true;
			vocals.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();

			updateAccuracy();
		}
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		instance = this;

		#if cpp
		if (executeModchart && lua != null)
		{
			setVar('curStep', curStep);
			callLua('stepHit', [curStep]);
		}
		#end

		/*
			if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
			{
				// dad.dance();
		}*/

		// For trolling :)
		if (curSong.toLowerCase() == 'cessation')
		{
			if (hazardRandom == 5)
			{
				if (curStep == 1504)
				{
					add(kb_attack_alert);
					KBATTACK_ALERT();
				}
				else if (curStep == 1508)
					KBATTACK_ALERT();
				else if (curStep == 1512)
				{
					FlxG.sound.play(Paths.sound('bruh'), 0.75);
					add(cessationTroll);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.06);
				}
				else if (curStep == 1520)
					remove(cessationTroll);
			}
		}
		// Animating every beat is too slow, so I'm doing this every step instead (previously was on every frame so it actually has time to animate through frames). -Haz
		if (curSong.toLowerCase() == 'censory-overload')
		{
			// Making GF scared for error section
			if (curBeat >= 704 && curBeat < 832 && curStep % 2 == 0)
			{
				gf.playAnim('scared', true);
				if (!Main.qtOptimisation)
					gf404.playAnim('scared', true);
			}
		}
		else if (curSong.toLowerCase() == 'terminate')
		{
			switch (curStep)
			{
				case 1:
					FlxTween.tween(strumLineNotes.members[0], {y: strumLineNotes.members[0].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[7], {y: strumLineNotes.members[7].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
				case 32:
					FlxTween.tween(strumLineNotes.members[1], {y: strumLineNotes.members[1].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[6], {y: strumLineNotes.members[6].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
				case 96:
					FlxTween.tween(strumLineNotes.members[3], {y: strumLineNotes.members[3].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[4], {y: strumLineNotes.members[4].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
				case 64:
					FlxTween.tween(strumLineNotes.members[2], {y: strumLineNotes.members[2].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[5], {y: strumLineNotes.members[5].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
			}
		}
		// Midsong events for Termination (such as the sawblade attack)
		else if (curSong.toLowerCase() == 'termination')
		{
			// For animating KB during the 404 section since he animates every half beat, not every beat.
			if (qtIsBlueScreened)
			{
				// Termination KB animates every 2 curstep instead of 4 (aka, every half beat, not every beat!)
				if (SONG.notes[Math.floor(curStep / 16)].mustHitSection
					&& !dad404.animation.curAnim.name.startsWith("sing")
					&& curStep % 2 == 0)
				{
					dad404.dance();
				}
			}

			// Making GF scared for error section
			if (curStep >= 2816 && curStep < 3328 && curStep % 2 == 0)
			{
				gf.playAnim('scared', true);
				if (!Main.qtOptimisation)
					gf404.playAnim('scared', true);
			}

			switch (curStep)
			{
				// Commented out stuff are for the double sawblade variations.
				// It is recommended to not uncomment them unless you know what you're doing. They are also not polished at all so don't complain about them if you do uncomment them.

				// CONVERTED THE CUSTOM INTRO FROM MODCHART INTO HARDCODE OR WHATEVER! NO MORE INVISIBLE NOTES DUE TO NO MODCHART SUPPORT!
				case 1:
					qt_tv01.animation.play("instructions");
					FlxTween.tween(strumLineNotes.members[0], {y: strumLineNotes.members[0].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[7], {y: strumLineNotes.members[7].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxG.camera.shake(0.002, 1);
					camHUD.shake(0.002, 1);
				case 32:
					FlxTween.tween(strumLineNotes.members[1], {y: strumLineNotes.members[1].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[6], {y: strumLineNotes.members[6].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxG.camera.shake(0.002, 1);
					camHUD.shake(0.002, 1);
				case 96:
					FlxTween.tween(strumLineNotes.members[3], {y: strumLineNotes.members[3].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[4], {y: strumLineNotes.members[4].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxG.camera.shake(0.002, 1);
					camHUD.shake(0.002, 1);
				case 64:
					qt_tv01.animation.play("gl");
					FlxTween.tween(strumLineNotes.members[2], {y: strumLineNotes.members[2].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[5], {y: strumLineNotes.members[5].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxG.camera.shake(0.002, 1);
					camHUD.shake(0.002, 1);
				case 112:
					add(kb_attack_saw);
					add(kb_attack_alert);
					KBATTACK_ALERT();
					KBATTACK();
				case 116:
					// KBATTACK_ALERTDOUBLE();
					KBATTACK_ALERT();
				case 120:
					// KBATTACK(true, "old/attack_alt01");
					KBATTACK(true);
					qt_tv01.animation.play("idle");
					for (boi in strumLineNotes.members)
					{ // FAIL SAFE TO ENSURE THAT ALL THE NOTES ARE VISIBLE WHEN PLAYING!!!!!
						boi.alpha = 1;
					}
				// case 123:
				// KBATTACK();
				// case 124:
				// FlxTween.tween(strumLineNotes.members[0], {alpha: 0}, 2, {ease: FlxEase.sineInOut}); //for testing outro code
				// KBATTACK(true, "old/attack_alt02");
				case 1280:
					qt_tv01.animation.play("idle");
				case 1760:
					qt_tv01.animation.play("watch");
				case 1792:
					qt_tv01.animation.play("idle");

				case 1776 | 1904 | 2032 | 2576 | 2596 | 2608 | 2624 | 2640 | 2660 | 2672 | 2704 | 2736 | 3072 | 3084 | 3104 | 3116 | 3136 | 3152 | 3168 |
					3184 | 3216 | 3248 | 3312:
					KBATTACK_ALERT();
					KBATTACK();
				case 1780 | 1908 | 2036 | 2580 | 2600 | 2612 | 2628 | 2644 | 2664 | 2676 | 2708 | 2740 | 3076 | 3088 | 3108 | 3120 | 3140 | 3156 | 3172 |
					3188 | 3220 | 3252 | 3316:
					KBATTACK_ALERT();
				case 1784 | 1912 | 2040 | 2584 | 2604 | 2616 | 2632 | 2648 | 2668 | 2680 | 2712 | 2744 | 3080 | 3092 | 3112 | 3124 | 3144 | 3160 | 3176 |
					3192 | 3224 | 3256 | 3320:
					KBATTACK(true);

				// Sawblades before bluescreen thing
				// These were seperated for double sawblade experimentation if you're wondering.
				// My god this organisation is so bad. Too bad!
				case 2304 | 2320 | 2340 | 2368 | 2384 | 2404:
					KBATTACK_ALERT();
					KBATTACK();
				case 2308 | 2324 | 2344 | 2372 | 2388 | 2408:
					KBATTACK_ALERT();
				case 2312 | 2328 | 2348 | 2376 | 2392 | 2412:
					KBATTACK(true);
				case 2352 | 2416:
					KBATTACK_ALERT();
					KBATTACK();
				case 2356 | 2420:
					// KBATTACK_ALERTDOUBLE();
					KBATTACK_ALERT();
				case 2360 | 2424:
					KBATTACK(true);
				case 2363 | 2427:
				// KBATTACK();
				case 2364 | 2428:
				// KBATTACK(true, "old/attack_alt02");

				case 2560:
					KBATTACK_ALERT();
					KBATTACK();
					qt_tv01.animation.play("eye");
				case 2564:
					KBATTACK_ALERT();
				case 2568:
					KBATTACK(true);

				case 2808:
					// Change to glitch background
					if (!Main.qtOptimisation)
					{
						streetBGerror.visible = true;
						streetBG.visible = false;
					}
					FlxG.camera.shake(0.0075, 0.675);
					qt_tv01.animation.play("error");

				case 2816: // 404 section
					qt_tv01.animation.play("404");
					gfSpeed = 1;
					// Change to bluescreen background
					if (!Main.qtOptimisation)
					{
						streetBG.visible = false;
						streetBGerror.visible = false;
						streetFrontError.visible = true;
						qtIsBlueScreened = true;
						CensoryOverload404();
					}
				case 3328: // Final drop
					qt_tv01.animation.play("alert");
					gfSpeed = 1;
					// Revert back to normal
					if (!Main.qtOptimisation)
					{
						streetBG.visible = true;
						streetFrontError.visible = false;
						qtIsBlueScreened = false;
						CensoryOverload404();
					}

				case 3376 | 3408 | 3424 | 3440 | 3576 | 3636 | 3648 | 3680 | 3696 | 3888 | 3936 | 3952 | 4096 | 4108 | 4128 | 4140 | 4160 | 4176 | 4192 | 4204:
					KBATTACK_ALERT();
					KBATTACK();
				case 3380 | 3412 | 3428 | 3444 | 3580 | 3640 | 3652 | 3684 | 3700 | 3892 | 3940 | 3956 | 4100 | 4112 | 4132 | 4144 | 4164 | 4180 | 4196 | 4208:
					KBATTACK_ALERT();
				case 3384 | 3416 | 3432 | 3448 | 3584 | 3644 | 3656 | 3688 | 3704 | 3896 | 3944 | 3960 | 4104 | 4116 | 4136 | 4148 | 4168 | 4184 | 4200 | 4212:
					KBATTACK(true);
				case 4352: // Custom outro hardcoded instead of being part of the modchart!
					qt_tv01.animation.play("idle");
					FlxTween.tween(strumLineNotes.members[2], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4384:
					FlxTween.tween(strumLineNotes.members[3], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4416:
					FlxTween.tween(strumLineNotes.members[0], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4448:
					FlxTween.tween(strumLineNotes.members[1], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});

				case 4480:
					FlxTween.tween(strumLineNotes.members[6], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4512:
					FlxTween.tween(strumLineNotes.members[7], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4544:
					FlxTween.tween(strumLineNotes.members[4], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4576:
					FlxTween.tween(strumLineNotes.members[5], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
			}
		}
		// ????

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ generateRanking(),
			"Acc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true, songLength
			- Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		instance = this;

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		#if cpp
		if (executeModchart && lua != null)
		{
			setVar('curBeat', curBeat);
			callLua('beatHit', [curBeat]);
		}
		#end

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && !qtCarelessFin)
			{
				if (SONG.song.toLowerCase() == "cessation")
				{
					if ((curStep >= 640 && curStep <= 794) || (curStep >= 1040 && curStep <= 1199))
					{
						dad.dance(true);
						camX = 0;
						camY = 0;
					}
					else
					{
						dad.dance();
						camX = 0;
						camY = 0;
					}
				}
				else
					dad.dance();
				camX = 0;
				camY = 0;
			}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (curSong.toLowerCase() == 'careless')
		{
			switch (curBeat)
			{
				case 1:
					/*qtcantalknow1.visible = true;
						qtcantalknow1.text = "QT:" + "\n 'Oh dear.'";
						FlxTween.tween(qtcantalknow1, {alpha: 1}, 1); */
			}
		}

		if (curSong.toLowerCase() == 'censory-overload')
		{
			if (curBeat == 64)
			{
				/*FlxTween.tween(vignette1, {alpha: 1}, 1.5, {
					ease: FlxEase.quadInOut
				});*/
			}

			if (curBeat == 241 || curBeat == 249 || curBeat == 257 || curBeat == 265 || curBeat == 273 || curBeat == 281 || curBeat == 289
				|| curBeat == 293 || curBeat == 297 || curBeat == 301 || curBeat == 497 || curBeat == 505 || curBeat == 513 || curBeat == 521
				|| curBeat == 529 || curBeat == 537 || curBeat == 545 || curBeat == 549 || curBeat == 553 || curBeat == 557)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (curBeat >= 80 && curBeat <= 208) // first drop
			{
				FlxG.camera.zoom += 0.0075;
				camHUD.zoom += 0.015;
				// Gas Release effect
				if (curBeat % 16 == 0 && !Main.qtOptimisation)
				{
					Gas_Release('burst');
				}
			}
			else if (curBeat >= 304 && curBeat <= 432) // second drop
			{
				if (camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				if (!(curBeat == 432)) // To prevent alert flashing when I don't want it too.
					qt_tv01.animation.play("alert");

				// Gas Release effect
				if (curBeat % 8 == 0 && !Main.qtOptimisation)
				{
					Gas_Release('burstALT');
				}
			}
			else if (curBeat >= 560 && curBeat <= 688)
			{ // third drop
				if (camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				// Gas Release effect
				if (curBeat % 4 == 0 && !Main.qtOptimisation)
				{
					Gas_Release('burstFAST');
				}
			}
			else if (curBeat >= 832 && curBeat <= 960)
			{ // final drop
				if (camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				if (!(curBeat == 960)) // To prevent alert flashing when I don't want it too.
					qt_tv01.animation.play("alert");
				// Gas Release effect
				if (curBeat % 4 == 2 && !Main.qtOptimisation)
				{
					Gas_Release('burstFAST');
				}
			}
			else if ((curBeat == 976 || curBeat == 992) && camZooming && FlxG.camera.zoom < 1.35)
			{ // Extra zooms for distorted kicks at end
				FlxG.camera.zoom += 0.031;
				camHUD.zoom += 0.062;
			}
			else if (curBeat == 702 && !Main.qtOptimisation)
			{
				Gas_Release('burst');
			}
		}
		else if (SONG.song.toLowerCase() == "termination")
		{
			if (curBeat >= 192 && curBeat <= 320) // 1st drop
			{
				if (camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				if (!(curBeat == 320)) // To prevent alert flashing when I don't want it too.
					qt_tv01.animation.play("alert");
			}
			else if (curBeat >= 512 && curBeat <= 640) // 1st drop
			{
				if (camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				if (!(curBeat == 640)) // To prevent alert flashing when I don't want it too.
					qt_tv01.animation.play("alert");
			}
			else if (curBeat >= 832 && curBeat <= 1088) // last drop
			{
				if (camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				if (!(curBeat == 1088)) // To prevent alert flashing when I don't want it too.
					qt_tv01.animation.play("alert");
			}
		}
		else if (SONG.song.toLowerCase() == "careless") // Mid-song events for Careless. Mainly for the TV though.
		{
			if (curBeat == 190 || curBeat == 191 || curBeat == 224)
			{
				qt_tv01.animation.play("eye");
			}
			else if (curBeat >= 192 && curStep <= 895)
			{
				qt_tv01.animation.play("alert");
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
			else if (curBeat == 225)
			{
				qt_tv01.animation.play("idle");
			}
			if (curBeat == 33
				|| curBeat == 37
				|| curBeat == 49
				|| curBeat == 53
				|| (curBeat >= 96 && curBeat <= 128 && curBeat % 2 == 0))
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}
		else if (SONG.song.toLowerCase() == "cessation") // Mid-song events for cessation. Mainly for the TV though.
		{
			qt_tv01.animation.play("heart");
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			if (qtIsBlueScreened)
			{
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.03;
				});
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
			// if(SONG.song.toLowerCase()=='censory-overload') //Basically unused now lmao
			// gf404.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !bfDodging)
		{
			boyfriend.dance();
			// boyfriend.playAnim('idle');
		}
		// Copy and pasted code for BF to see if it would work for Dad to animate Dad during their section (previously, they just froze) -Haz
		// Seems to have fixed a lot of problems with idle animations with Dad. Success! -A happy Haz
		if (SONG.notes[Math.floor(curStep / 16)] != null) // Added extra check here so song doesn't crash on careless.
		{
			if (!(SONG.notes[Math.floor(curStep / 16)].mustHitSection) && !dad.animation.curAnim.name.startsWith("sing"))
			{
				if (!qtIsBlueScreened && !qtCarelessFin)
					if (SONG.song.toLowerCase() == "cessation")
					{
						if ((curStep >= 640 && curStep <= 794) || (curStep >= 1040 && curStep <= 1199))
						{
							dad.dance(true);
							camX = 0;
							camY = 0;
						}
						else
						{
							dad.dance();
							camX = 0;
							camY = 0;
						}
					}
					else
					{
						dad.dance();
						camX = 0;
						camY = 0;
					}
			}
		}

		// Same as above, but for 404 variants.
		if (qtIsBlueScreened)
		{
			if (!boyfriend404.animation.curAnim.name.startsWith("sing") && !bfDodging)
			{
				boyfriend404.playAnim('idle');
			}

			// Termination KB animates every 2 curstep instead of 4 (aka, every half beat, not every beat!)
			// No idea why this line causes a crash on REDACTED so erm... fuck you.
			if (!(SONG.song.toLowerCase() == "termination"))
			{
				if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && !dad404.animation.curAnim.name.startsWith("sing"))
				{
					dad404.dance();
				}
			}
		}
	}

	public function Gas_Release(Anim:String)
	{
		qt_gas01.animation.play(Anim);
		qt_gas02.animation.play(Anim);
	}

	function changeDadCharacter(thecharacter:String, changeicon:Bool = true, changenotes:Bool = true)
	{
		var olddadx = dad.x;
		var olddady = dad.y;
		remove(dad);
		dad = new Character(olddadx, olddady, thecharacter);
		add(dad);
		if (changenotes)
			reloadStatics();
		if (changeicon)
		{
			iconP2.animation.play(thecharacter);
			reloadHealthBarColors();
		}
	}

	function changeBFCharacter(thecharacter:String, changeicon:Bool = true, changenotes:Bool = true)
	{
		var oldboyfriendx = boyfriend.x;
		var oldboyfriendy = boyfriend.y;
		remove(boyfriend);
		boyfriend = new Boyfriend(oldboyfriendx, oldboyfriendy, thecharacter);
		add(boyfriend);
		if (changenotes)
			reloadStatics();
		if (changeicon)
		{
			iconP1.animation.play(thecharacter);
			reloadHealthBarColors();
		}
	}

	function changeGfCharacter(thecharacter:String)
	{
		var oldgfx = gf.x;
		var oldgfy = gf.y;
		remove(gf);
		gf = new Character(oldgfx, oldgfy, thecharacter);
		add(gf);
	}

	var curLight:Int = 0;
}
