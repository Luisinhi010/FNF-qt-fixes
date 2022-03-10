package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import lime.utils.Assets;
#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var scoreBG:FlxSprite;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public var qt_gas:FlxSprite;

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			if (!(data[0] == 'Termination') && !(data[0] == 'Cessation'))
			{ // Add everything to the song list which isn't Termination and Cessation.
				songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
			}
			else if (FlxG.save.data.terminationUnlocked && data[0] == 'Termination') // If the list picks up Termination, check if its unlocked before adding.
				songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
			else if (FlxG.save.data.terminationBeaten && data[0] == 'Cessation') // If the list picks up Cessation, check if its unlocked before adding.
				songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		}

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);

		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		diffText.x = scoreBG.getGraphicMidpoint().x;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		#if PRELOAD_ALL
		if (!Main.qtOptimisation)
		{
			qt_gas = new FlxSprite();
			qt_gas.frames = Paths.getSparrowAtlas('stage/Gas_Release', 'qt');
			qt_gas.animation.addByPrefix('burst', 'Gas_Release', 38, false);
			qt_gas.animation.addByPrefix('burstALT', 'Gas_Release', 49, false);
			qt_gas.animation.addByPrefix('burstFAST', 'Gas_Release', 76, false);
			qt_gas.animation.addByIndices('burstLoop', 'Gas_Release', [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], "", 38, true);
			qt_gas.setGraphicSize(Std.int(qt_gas.width * 1.8));
			qt_gas.antialiasing = true;
			qt_gas.scrollFactor.set();
			qt_gas.alpha = 0.63;
			qt_gas.setPosition(450, 0);
			add(qt_gas);
		}
		#end

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song";
		var size:Int = 16;
		#else
		var leText:String = "";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(text);

		FlxTween.tween(text, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(textBG, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var instPlaying:Int = -1;

	private static var vocals:FlxSound = null;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		Conductor.songPosition = FlxG.sound.music.time;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = FlxG.keys.justPressed.ENTER;
		var space = FlxG.keys.justPressed.SPACE;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (!(songs[curSelected].songName.toLowerCase() == "termination"))
		{ // Only allow the difficulty to be changed if the song isn't termination.
			if (controls.LEFT_P)
				changeDiff(-1);
			if (controls.RIGHT_P)
				changeDiff(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			if ((songs[curSelected].songName.toLowerCase() == 'termination') && !(FlxG.save.data.terminationUnlocked))
			{
				trace("lmao, access denied idiot!");
			}
			else if ((songs[curSelected].songName.toLowerCase() == 'cessation') && !(FlxG.save.data.terminationBeaten))
			{
				trace("lmao, access denied idiot! Prove yourself first mortal.");
			}
			else
			{
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				trace(poop);

				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				LoadingState.loadAndSwitchState(new PlayState());

				destroyFreeplayVocals();
			}
		}
		if (space)
		{
			if (instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();
				Conductor.songPosition = FlxG.sound.music.time;
				Conductor.mapBPMChanges(PlayState.SONG);
				Conductor.changeBPM(PlayState.SONG.bpm);

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				trace('playing ' + poop);
				}
				else
					trace('you cant play that song');
				#end
			}

			// I'm sorry I just had to fix it, it looked so ugly before
			scoreText.text = "PERSONAL BEST:" + lerpScore;
			scoreText.x = FlxG.width - scoreText.width - 5;
			scoreBG.width = scoreText.width;
			scoreBG.x = scoreText.x;
			diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
		}

		#if PRELOAD_ALL
		public static function destroyFreeplayVocals()
		{
			if (vocals != null)
			{
				vocals.stop();
				vocals.destroy();
			}
			vocals = null;
		}
		#end

		function changeDiff(change:Int = 0)
		{
			if (songs[curSelected].songName.toLowerCase() == "termination")
			{
				curDifficulty = 2; // Force it to hard difficulty.
				FlxTween.color(diffText, 0.3, diffText.color, FlxColor.RED, {ease: FlxEase.quadInOut});
				if (FlxG.save.data.terminationUnlocked)
					diffText.text = "VERY HARD";
				else
					diffText.text = "LOCKED";
				#if !switch
				intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
				#end
			}
			else if (songs[curSelected].songName.toLowerCase() == "cessation")
			{
				curDifficulty = 1; // Force it to normal difficulty.
				FlxTween.color(diffText, 0.3, diffText.color, FlxColor.CYAN, {ease: FlxEase.quadInOut});
				if (FlxG.save.data.terminationBeaten)
					diffText.text = "FUTURE";
				else
					diffText.text = "LOCKED";
				#if !switch
				intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
				#end
			}
			else
			{
				curDifficulty += change;

				if (curDifficulty < 0)
					curDifficulty = 2;
				if (curDifficulty > 2)
					curDifficulty = 0;

				switch (curDifficulty)
				{
					case 0:
						diffText.text = "< EASY >";
						FlxTween.color(diffText, 0.3, diffText.color, FlxColor.LIME, {ease: FlxEase.quadInOut});
					case 1:
						FlxTween.color(diffText, 0.3, diffText.color, FlxColor.YELLOW, {ease: FlxEase.quadInOut});
						diffText.text = '< NORMAL >';
					case 2:
						diffText.text = "< HARD >";
						FlxTween.color(diffText, 0.3, diffText.color, FlxColor.RED, {ease: FlxEase.quadInOut});
				}
			}

			#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			#end
		}

		function changeSelection(change:Int = 0)
		{
			#if !switch
			// NGio.logEvent('Fresh');
			#end

			// NGio.logEvent('Fresh');
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

			curSelected += change;

			if (curSelected < 0)
				curSelected = songs.length - 1;
			if (curSelected >= songs.length)
				curSelected = 0;

			/*
				if(songs[curSelected].songName.toLowerCase()=="termination"){ //For forcing the difficulty text to update, and forcing it to hard when selecting Termination -Haz
					changeDiff(0);
				}else{                                                      //Used for reseting the difficulty text back.
					changeDiff(0) ;
			}*/

			// In hindsight, the above code was fucking retarded since it just leads to the same outcome. -Haz
			changeDiff(0);

			// selector.y = (70 * curSelected) + 30;

			#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			// lerpScore = 0;
			#end

			var bullShit:Int = 0;

			for (i in 0...iconArray.length)
			{
				iconArray[i].alpha = 0.6;
			}

			iconArray[curSelected].alpha = 1;

			for (item in grpSongs.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;
				// item.setGraphicSize(Std.int(item.width * 0.8));

				if (item.targetY == 0)
				{
					item.alpha = 1;
					// item.setGraphicSize(Std.int(item.width));
				}
			}
		}

		#if PRELOAD_ALL
		override function stepHit()
		{
			super.stepHit();
			if (songs[curSelected].songName.toLowerCase() == "termination" && instPlaying == curSelected)
			{
				switch (curStep)
				{
					case 1:
						FlxG.camera.shake(0.002, 1);
					case 32:
						FlxG.camera.shake(0.002, 1);
					case 64:
						FlxG.camera.shake(0.002, 1);
					case 96:
						FlxG.camera.shake(0.002, 1.8);
					case 112:
						KBATTACK_ALERT();
						KBATTACK();
					case 116:
						KBATTACK_ALERT();
					case 120:
						KBATTACK(true);
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
						KBATTACK_ALERT();
					case 2360 | 2424:
						KBATTACK(true);
					case 2560:
						KBATTACK_ALERT();
						KBATTACK();
					case 2564:
						KBATTACK_ALERT();
					case 2568:
						KBATTACK(true);
					case 2808:
						FlxG.camera.shake(0.0075, 0.675);
					case 3376 | 3408 | 3424 | 3440 | 3576 | 3636 | 3648 | 3680 | 3696 | 3888 | 3936 | 3952 | 4096 | 4108 | 4128 | 4140 | 4160 | 4176 | 4192 |
						4204:
						KBATTACK_ALERT();
						KBATTACK();
					case 3380 | 3412 | 3428 | 3444 | 3580 | 3640 | 3652 | 3684 | 3700 | 3892 | 3940 | 3956 | 4100 | 4112 | 4132 | 4144 | 4164 | 4180 | 4196 |
						4208:
						KBATTACK_ALERT();
					case 3384 | 3416 | 3432 | 3448 | 3584 | 3644 | 3656 | 3688 | 3704 | 3896 | 3944 | 3960 | 4104 | 4116 | 4136 | 4148 | 4168 | 4184 | 4200 |
						4212:
						KBATTACK(true);
				}
			}
		}

		override function beatHit()
		{
			super.beatHit();

			if (FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
				FlxG.camera.zoom += 0.015;

			if (songs[curSelected].songName.toLowerCase() == "censory-overload" && instPlaying == curSelected)
			{
				if (curBeat >= 80 && curBeat <= 208 && curBeat % 16 == 0)
					Gas_Release('burst');
				else if (curBeat >= 304 && curBeat <= 432 && curBeat % 8 == 0)
					Gas_Release('burstALT');
				else if (curBeat == 558)
					FlxG.camera.shake(0.00425, 0.6725);
				else if (curBeat >= 560 && curBeat <= 688 && curBeat % 4 == 0)
					Gas_Release('burstFAST');
				else if (curBeat == 702)
				{
					Gas_Release('burst');
					FlxG.camera.shake(0.0075, 0.67);
				}
				else if (curBeat == 704)
					Gas_Release('burstLoop');
				else if (curBeat >= 832 && curBeat <= 960 && curBeat % 4 == 2)
					Gas_Release('burstFAST');
			}
		}
		#end

		public function Gas_Release(anim:String = 'burst')
		{
			if (!Main.qtOptimisation)
				if (qt_gas != null)
					qt_gas.animation.play(anim);
		}
		function KBATTACK(state:Bool = false, soundToPlay:String = 'attack'):Void // stolen from playstate
		{
			if (state)
			{
				FlxG.sound.play(Paths.sound(soundToPlay, 'qt'), 0.75);
				FlxG.camera.shake(0.00165, 0.2);
			}
		}
		function KBATTACK_ALERT():Void // stolen from playstate pt2
		{
			FlxG.sound.play(Paths.sound('alert', 'qt'), 1);
		}
	}

	class SongMetadata
	{
		public var songName:String = "";
		public var week:Int = 0;
		public var songCharacter:String = "";

		public function new(song:String, week:Int, songCharacter:String)
		{
			this.songName = song;
			this.week = week;
			this.songCharacter = songCharacter;
		}
	}
