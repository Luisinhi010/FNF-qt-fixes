package;

import flixel.math.FlxMath;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.ui.Mouse;
import flixel.FlxG;
import flixel.input.IFlxInputManager;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.system.FlxAssets;
import flixel.system.replay.MouseRecord;
import flixel.util.FlxDestroyUtil;
#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	var newInput:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.4.2" + nightly;
	public static var gameVer:String = "0.2.7.1";
	public static var thatqtversion:String = "1.2";

	var bg:FlxSprite;

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject; // sorry shadow mario
	var vignette1:BGSprite;

	public var iconBG:FlxSprite;
	public var icon:HealthIcon;

	var date = Date.now();
	var noname:Bool = false;
	var shit:FlxText;
	#if !mac
	var name:String = Sys.environment()["USERNAME"];
	#else
	var name:String = Sys.environment()["USER"];
	#end

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(102);
		}

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.15;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(FlxG.width + 0, (i * 140) + offset);
			menuItem.frames = tex;
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 3)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = true;
			// menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			FlxTween.tween(menuItem, {y: 60 + (i * 160)}, 1 + (i * 0.25), {
				ease: FlxEase.expoInOut,
				onComplete: function(flxTween:FlxTween)
				{
					changeItem();
				}
			});
			menuItem.updateHitbox();
			menuItem.scrollFactor.set(0, scr);
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		iconBG = new FlxSprite().loadGraphic(Paths.image('iconbackground'));
		iconBG.scrollFactor.set();
		iconBG.updateHitbox();
		iconBG.antialiasing = true;
		add(iconBG);

		icon = new HealthIcon('bf');
		icon.antialiasing = true;
		icon.x = 70;
		icon.angle = -1;
		icon.y = FlxG.height - 180;
		icon.scrollFactor.set();
		icon.updateHitbox();
		add(icon);
		trace(iconBG.color);
		trace(icon);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer + (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.screenCenter(X);
		add(versionShit);

		var qtVersion:FlxText = new FlxText(FlxG.width - 275, FlxG.height - 18, 0, "QT Mod Version - " + thatqtversion, 12);
		qtVersion.scrollFactor.set();
		qtVersion.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(qtVersion);

		vignette1 = new BGSprite('vignettealt');
		vignette1.setGraphicSize(FlxG.width, FlxG.height);
		vignette1.alpha = 0;
		vignette1.scrollFactor.set(0, 0);
		vignette1.updateHitbox();
		vignette1.screenCenter();
		vignette1.antialiasing = true;
		add(vignette1);

		switch (FlxG.random.int(1, 4))
		{
			case 1:
				icon.animation.play('bf');
				icon.setGraphicSize(Std.int(icon.width * 2));
				iconBG.color = FlxColor.CYAN;
			case 2:
				icon.animation.play('gf');
				icon.setGraphicSize(Std.int(icon.width * 2));
				iconBG.color = FlxColor.RED;
			case 3:
				icon.animation.play('robot');
				icon.setGraphicSize(Std.int(icon.width * 1.9));
				iconBG.color = FlxColor.GRAY;
				switch (FlxG.random.int(1, 2))
				{
					case 1:
						vignette1.alpha = 0.5;
						icon.animation.curAnim.curFrame = 0;
					case 2:
						vignette1.alpha = 0.8;
						icon.animation.curAnim.curFrame = 1;
				}
			case 4:
				icon.animation.play('qt');
				icon.setGraphicSize(Std.int(icon.width * 1.9));
				iconBG.color = FlxColor.PINK;
				switch (FlxG.random.int(1, 2))
				{
					case 1:
						vignette1.alpha = 0.1;
						icon.animation.curAnim.curFrame = 0;
					case 2:
						vignette1.alpha = 0.7;
						icon.animation.curAnim.curFrame = 1;
				}
		} // YES, I WILL PUT THE HAXE COLORS INSTEAD THE NORMAL ONES

		trace(iconBG.color);
		trace(icon);

		// NG.core.calls.event.logEvent('swag').send();

		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					// Main Menu Select Animations
					FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
					FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
					FlxTween.tween(magenta, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						hideit(0.6);
					});

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0.1, x: 1500}, 1, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
							FlxTween.tween(spr, {x: 1500}, 1, {
								ease: FlxEase.quadOut
							});
						}
						else
						{
							spr.updateHitbox();
							// spr.x += -300;
							FlxTween.tween(spr, {x: spr.x - 240, y: 260}, 0.5, {ease: FlxEase.quadOut});
							FlxTween.tween(spr.scale, {x: 1.2, y: 1.2}, 0.8, {ease: FlxEase.quadOut});

							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								goToState();
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");

			case 'options':
				FlxG.switchState(new OptionsMenu());
		}
	}

	function hideit(time:Float)
	{
		menuItems.forEach(function(spr:FlxSprite)
		{
			FlxTween.tween(spr, {alpha: 0.0}, time, {ease: FlxEase.quadOut});
		});
		FlxTween.tween(bg, {alpha: 0}, time, {ease: FlxEase.expoIn});
		FlxTween.tween(magenta, {alpha: 0}, time, {ease: FlxEase.expoIn});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
