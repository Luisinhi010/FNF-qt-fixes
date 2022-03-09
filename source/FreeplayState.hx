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

		FlxTween.tween(text,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(textBG,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});

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

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
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
		if(space)
		{
			if(instPlaying != curSelected)
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

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
				}
			}
		}
			vocals = null;
			
			//I'm sorry I just had to fix it, it looked so ugly before
			scoreText.text = "PERSONAL BEST:" + lerpScore;
			scoreText.x = FlxG.width - scoreText.width - 5;
			scoreBG.width = scoreText.width;
			scoreBG.x = scoreText.x;
			diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
	}

	public static function destroyFreeplayVocals()
	{
		if(vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
	}

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
