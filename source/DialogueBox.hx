package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitLeftALT:FlxSprite;
	var portraitRightALT:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		if (PlayState.isStoryMode)
		{ // Added an extra check here to avoid music playing when in freeplay.
			switch (PlayState.SONG.song.toLowerCase())
			{
				case 'carefree':
					FlxG.sound.playMusic(Paths.music('carefree-dialogue-loop', 'qt'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.1);
				case 'censory-overload' | 'terminate':
					FlxG.sound.playMusic(Paths.music('spooky_ambience', 'qt'), 0);
					FlxG.sound.music.fadeIn(1, 0, 0.47);
			}
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 2.5), Std.int(FlxG.height * 2.5), 0xFFB3DFd8);
		bgFade.scrollFactor.set(1);
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);

		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			// QT / Robot Week
			case 'carefree' | 'careless' | 'cessation':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, false);

				// fix scale and offset (probably a better way to do this, but I don't know what the fuck is going on in here) -Haz
				box.setGraphicSize(Std.int(box.width * 0.2));
				box.updateHitbox();
				box.y += 340;

				box.scrollFactor.set(1);

			case 'censory-overload' | 'terminate': // Why are they seperated? ...Erm...  ¯\_(ツ)_/¯
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, false);

				// fix scale and offset (probably a better way to do this, but I don't know what the fuck is going on in here) -Haz
				box.setGraphicSize(Std.int(box.width * 0.2));
				box.updateHitbox();
				box.y += 340;
				box.scrollFactor.set(1);
		}

		this.dialogueList = dialogueList;

		if (!hasDialog)
			return;

		// Loading portraits for Custom Week -Haz
		if (PlayState.SONG.song.toLowerCase() == 'carefree'
			|| PlayState.SONG.song.toLowerCase() == 'careless'
			|| PlayState.SONG.song.toLowerCase() == 'censory-overload'
			|| PlayState.SONG.song.toLowerCase() == 'terminate'
			|| PlayState.SONG.song.toLowerCase() == 'cessation')
		{
			// This is awful. There is most definitely a better way of doing this but I can't be bothered to find, learn, and use it. Don't be like me, do it the proper way (whatever that is)-Haz
			if (PlayState.SONG.song.toLowerCase() == 'censory-overload')
			{ // Defining portraits for Censory-Overload
				portraitLeft = new FlxSprite(-20, 50);
				portraitLeft.frames = Paths.getSparrowAtlas('ui/roboPortait', 'qt');
				portraitLeft.animation.addByPrefix('enter', 'robo_potrait', 24, false);
				// portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set(1);
				add(portraitLeft);
				portraitLeft.visible = false;
				portraitRight = new FlxSprite(0, 50);
				portraitRight.frames = Paths.getSparrowAtlas('ui/bfPortrait', 'qt');
				portraitRight.animation.addByPrefix('enter', 'bf_portrait', 24, false);
				// portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9)); //Lmao, this breaks shit so I disabled it -Haz
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set(1);
				add(portraitRight);
				portraitRight.visible = false;

				portraitLeftALT = new FlxSprite(0, 50);
				portraitLeftALT.frames = Paths.getSparrowAtlas('ui/emptyPortrait', 'qt');
				portraitLeftALT.animation.addByPrefix('enter', 'nothingEnter', 24, false);
				add(portraitLeftALT);
				portraitLeftALT.visible = false;
				portraitRightALT = new FlxSprite(0, 50);
				portraitRightALT.frames = Paths.getSparrowAtlas('ui/emptyPortrait', 'qt');
				portraitRightALT.animation.addByPrefix('enter', 'nothingEnter', 24, false);
				add(portraitRightALT);
				portraitRightALT.visible = false;
			}
			else if (PlayState.SONG.song.toLowerCase() == 'careless')
			{ // Defining portraits for Careless
				portraitLeft = new FlxSprite(-20, 50);
				portraitLeft.frames = Paths.getSparrowAtlas('ui/qtPortaitALT', 'qt');
				portraitLeft.animation.addByPrefix('enter', 'finished_qt_sprite_potrait', 24, false);
				// portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set(1);
				add(portraitLeft);
				portraitLeft.visible = false;
				portraitRight = new FlxSprite(0, 50);
				portraitRight.frames = Paths.getSparrowAtlas('ui/bfPortrait', 'qt');
				portraitRight.animation.addByPrefix('enter', 'bf_portrait', 24, false);
				// portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9)); //Lmao, this breaks shit so I disabled it -Haz
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set(1);
				add(portraitRight);
				portraitRight.visible = false;

				portraitLeftALT = new FlxSprite(0, 50);
				portraitLeftALT.frames = Paths.getSparrowAtlas('ui/emptyPortrait', 'qt');
				portraitLeftALT.animation.addByPrefix('enter', 'nothingEnter', 24, false);
				add(portraitLeftALT);
				portraitLeftALT.visible = false;
				portraitRightALT = new FlxSprite(0, 50);
				portraitRightALT.frames = Paths.getSparrowAtlas('ui/emptyPortrait', 'qt');
				portraitRightALT.animation.addByPrefix('enter', 'nothingEnter', 24, false);
				add(portraitRightALT);
				portraitRightALT.visible = false;
			}
			else if (PlayState.SONG.song.toLowerCase() == 'terminate')
			{ // Defining portraits for Terminate
				portraitLeft = new FlxSprite(-20, 50);
				portraitLeft.frames = Paths.getSparrowAtlas('ui/roboPortait', 'qt');
				portraitLeft.animation.addByPrefix('enter', 'robo_potrait', 24, false);
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set(1);
				add(portraitLeft);
				portraitLeft.visible = false;

				portraitRight = new FlxSprite(0, 50);
				portraitRight.frames = Paths.getSparrowAtlas('ui/bfPortrait', 'qt');
				portraitRight.animation.addByPrefix('enter', 'bf_portrait', 24, false);
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set(1);
				add(portraitRight);
				portraitRight.visible = false;

				portraitLeftALT = new FlxSprite(0, 82);
				portraitLeftALT.frames = Paths.getSparrowAtlas('ui/gfPortrait', 'qt');
				portraitLeftALT.animation.addByPrefix('enter', 'gf_portrait', 24, false);
				portraitLeftALT.updateHitbox();
				portraitLeftALT.scrollFactor.set(1);
				add(portraitLeftALT);
				portraitLeftALT.flipX = true;
				portraitLeftALT.visible = false;

				portraitRightALT = new FlxSprite(0, 50);
				portraitRightALT.frames = Paths.getSparrowAtlas('ui/qtPortait', 'qt');
				portraitRightALT.animation.addByPrefix('enter', 'finished_qt_sprite_potrait', 24, false);
				portraitRightALT.updateHitbox();
				portraitRightALT.scrollFactor.set(1);
				add(portraitRightALT);
				portraitRightALT.flipX = true;
				portraitRightALT.visible = false;
			}
			else if (PlayState.SONG.song.toLowerCase() == 'cessation')
			{ // Defining portraits for Cessation (ending)
				portraitLeft = new FlxSprite(-20, 50);
				portraitLeft.frames = Paths.getSparrowAtlas('ui/roboFUTUREPortait', 'qt');
				portraitLeft.animation.addByPrefix('enter', 'robo_potraitALT', 24, false);
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set(1);
				add(portraitLeft);
				portraitLeft.visible = false;

				portraitRight = new FlxSprite(0, 50);
				portraitRight.frames = Paths.getSparrowAtlas('ui/bfPortrait', 'qt');
				portraitRight.animation.addByPrefix('enter', 'bf_portrait', 24, false);
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set(1);
				add(portraitRight);
				portraitRight.visible = false;

				portraitLeftALT = new FlxSprite(-20, 50);
				portraitLeftALT.frames = Paths.getSparrowAtlas('ui/qtPortait', 'qt');
				portraitLeftALT.animation.addByPrefix('enter', 'finished_qt_sprite_potrait', 24, false);
				portraitLeftALT.updateHitbox();
				portraitLeftALT.scrollFactor.set(1);
				add(portraitLeftALT);
				portraitLeftALT.visible = false;

				portraitRightALT = new FlxSprite(0, 60);
				portraitRightALT.frames = Paths.getSparrowAtlas('ui/gfPortrait', 'qt');
				portraitRightALT.animation.addByPrefix('enter', 'gf_portrait', 24, false);
				portraitRightALT.updateHitbox();
				portraitRightALT.scrollFactor.set(1);
				add(portraitRightALT);
				portraitRightALT.visible = false;
			}
			else
			{ // Pretty sure this is for Carefree
				portraitLeft = new FlxSprite(-20, 50);
				portraitLeft.frames = Paths.getSparrowAtlas('ui/qtPortait', 'qt');
				portraitLeft.animation.addByPrefix('enter', 'finished_qt_sprite_potrait', 24, false);
				// portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set(1);
				add(portraitLeft);
				portraitLeft.visible = false;

				portraitRight = new FlxSprite(0, 50);
				portraitRight.frames = Paths.getSparrowAtlas('ui/bfPortrait', 'qt');
				portraitRight.animation.addByPrefix('enter', 'bf_portrait', 24, false);
				// portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9)); //Lmao, this breaks shit so I disabled it -Haz
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set(1);
				add(portraitRight);
				portraitRight.visible = false;

				portraitLeftALT = new FlxSprite(0, 50);
				portraitLeftALT.frames = Paths.getSparrowAtlas('ui/emptyPortrait', 'qt');
				portraitLeftALT.animation.addByPrefix('enter', 'nothingEnter', 24, false);
				add(portraitLeftALT);
				portraitLeftALT.visible = false;
				portraitRightALT = new FlxSprite(0, 50);
				portraitRightALT.frames = Paths.getSparrowAtlas('ui/emptyPortrait', 'qt');
				portraitRightALT.animation.addByPrefix('enter', 'nothingEnter', 24, false);
				add(portraitRightALT);
				portraitRightALT.visible = false;
			}
		}
		else // Week 6 portraits used instead -Haz
		{
			portraitLeft = new FlxSprite(-20, 40);
			portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait', 'qt');
			portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;

			portraitRight = new FlxSprite(0, 40);
			portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait', 'qt');
			portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;
		}

		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);
		portraitLeftALT.screenCenter(X);
		if (PlayState.SONG.song.toLowerCase() == 'carefree'
			|| PlayState.SONG.song.toLowerCase() == 'careless'
			|| PlayState.SONG.song.toLowerCase() == 'censory-overload')
		{
			box.x += 50; // Scuffed, but oh well -Haz
			portraitLeft.y += 110;
			portraitLeft.x -= 400;
			portraitRight.y += 160;
			portraitRight.x += 800;
		}
		if (PlayState.SONG.song.toLowerCase() == 'terminate' || PlayState.SONG.song.toLowerCase() == 'cessation')
		{
			box.x += 50;
			portraitLeft.y += 110;
			portraitLeft.x -= 400;
			portraitLeftALT.y += 110;
			portraitLeftALT.x -= 400;
			portraitRight.y += 160;
			portraitRight.x += 800;
			portraitRightALT.y += 160;
			portraitRightALT.x += 800;
		}

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
		add(handSelect);

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted == true)
		{
			remove(dialogue);

			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'censory-overload'
						|| PlayState.SONG.song.toLowerCase() == 'terminate'
						|| PlayState.SONG.song.toLowerCase() == 'carefree')
						FlxG.sound.music.fadeOut(2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						if (PlayState.SONG.song.toLowerCase() == 'terminate' || PlayState.SONG.song.toLowerCase() == 'cessation')
						{
							portraitLeftALT.visible = false;
							portraitRightALT.visible = false;
						}
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		if (PlayState.SONG.song.toLowerCase() == 'terminate' || PlayState.SONG.song.toLowerCase() == 'cessation')
		{
			switch (curCharacter)
			{
				case 'kb': // Left
					box.flipX = true;
					portraitRight.visible = false;
					portraitLeftALT.visible = false;
					portraitRightALT.visible = false;
					if (!portraitLeft.visible) // No need to re-enter if already visible.
					{
						portraitLeft.visible = true;
						portraitLeft.animation.play('enter');
					}
				case 'gf': // RightALT
					box.flipX = false;
					portraitRight.visible = false;
					portraitLeftALT.visible = false;
					portraitLeft.visible = false;
					if (!portraitRightALT.visible) // No need to re-enter if already visible.
					{
						portraitRightALT.visible = true;
						portraitRightALT.animation.play('enter');
					}
				case 'bf': // Right
					box.flipX = false;
					portraitLeft.visible = false;
					portraitLeftALT.visible = false;
					portraitRightALT.visible = false;
					if (!portraitRight.visible) // No need to re-enter if already visible.
					{
						portraitRight.visible = true;
						portraitRight.animation.play('enter');
					}
				case 'qt': // LeftALT
					box.flipX = true;
					portraitLeft.visible = false;
					portraitRightALT.visible = false;
					portraitRight.visible = false;
					if (!portraitLeftALT.visible) // No need to re-enter if already visible.
					{
						portraitLeftALT.visible = true;
						portraitLeftALT.animation.play('enter');
					}
			}
		}
		else
		{
			switch (curCharacter)
			{
				case 'dad':
					// For flipping custom speech bubble.
					if (PlayState.SONG.song.toLowerCase() == 'carefree'
						|| PlayState.SONG.song.toLowerCase() == 'careless'
						|| PlayState.SONG.song.toLowerCase() == 'censory-overload')
						box.flipX = true;
					portraitRight.visible = false;
					if (!portraitLeft.visible) // No need to re-enter if already visible.
					{
						portraitLeft.visible = true;
						portraitLeft.animation.play('enter');
					}
				case 'bf':
					if (PlayState.SONG.song.toLowerCase() == 'carefree'
						|| PlayState.SONG.song.toLowerCase() == 'careless'
						|| PlayState.SONG.song.toLowerCase() == 'censory-overload')
						box.flipX = false;
					portraitLeft.visible = false;
					if (!portraitRight.visible) // No need to re-enter if already visible.
					{
						portraitRight.visible = true;
						portraitRight.animation.play('enter');
					}
			}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
