package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;
	public var iconColor:String = "FFFF0000";
	public var songPosbar:String = "FF00FF00";
	public var songPosbarempty:String = "FF808080";

	public function CharactersSwitchCase() // Contains every character for the game.
	{
		var tex:FlxAtlasFrames;
		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				iconColor = "FFA5004D";
				tex = Paths.getSparrowAtlas('GF_assets');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);

				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'bf':
				iconColor = "FF31B0D1";
				var tex = Paths.getSparrowAtlas('BOYFRIEND', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				animation.addByPrefix('dodge', 'boyfriend dodge', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;

			// QT mod characters:
			case 'qt':
				iconColor = "FFFB96B7";
				songPosbar = "FFFB96B7";
				// QT = Cutie
				tex = Paths.getSparrowAtlas('qt');
				frames = tex;
				animation.addByPrefix('idle', 'Final_Idle', 18, false); // How long until I get called out for using a weird framerate for the animation?
				animation.addByPrefix('singUP', 'Final_Up', 14, false);
				animation.addByPrefix('singRIGHT', 'Final_Right', 14, false);
				animation.addByPrefix('singDOWN', 'Final_Down', 14, false);
				animation.addByPrefix('singLEFT', 'Final_Left', 14, false);

				// Positive = goes to left / Up. -Haz
				// Negative = goes to right / Down. -Haz

				addOffset('idle', 3, -350);
				addOffset("singUP", 11, -305);
				addOffset("singRIGHT", -14, -312);
				addOffset("singDOWN", 24, -275);
				addOffset("singLEFT", -62, -328);

				playAnim('idle');
			case 'qt_annoyed':
				iconColor = "FFFB96B7";
				songPosbar = "FFFF6464";
				songPosbarempty = "FF646464";
				// For second song
				tex = Paths.getSparrowAtlas('qt_annoyed');
				frames = tex;
				animation.addByPrefix('idle', 'Final_Idle', 18, false);
				animation.addByPrefix('singUP', 'Final_Up', 14, false);
				animation.addByPrefix('singRIGHT', 'Final_Right', 14, false);
				animation.addByPrefix('singDOWN', 'Final_Down', 14, false);
				animation.addByPrefix('singLEFT', 'Final_Left', 14, false);

				// glitch animations
				animation.addByPrefix('singUP-alt', 'glitch_up', 18, false);
				animation.addByPrefix('singDOWN-alt', 'glitch_down', 14, false);
				animation.addByPrefix('singLEFT-alt', 'glitch_left', 14, false);
				animation.addByPrefix('singRIGHT-alt', 'glitch_right', 14, false);

				// Positive = goes to left / Up. -Haz
				// Negative = goes to right / Down. -Haz

				addOffset('idle', 3, -350);
				addOffset("singUP", 22, -315);
				addOffset("singRIGHT", -13, -324);
				addOffset("singDOWN", 29, -284);
				addOffset("singLEFT", -62, -333);
				// alt animations
				addOffset("singUP-alt", 18, -308);
				addOffset("singRIGHT-alt", -13, -324);
				addOffset("singDOWN-alt", 29, -284);
				addOffset("singLEFT-alt", 7, -321);

				playAnim('idle');
			case 'robot':
				iconColor = "FF808080";
				songPosbar = "FF808080";
				songPosbarempty = "FF000000";
				// robot = kb = killerbyte
				tex = Paths.getSparrowAtlas('robot');
				frames = tex;

				animation.addByPrefix('danceRight', "KB_DanceRight", 26, false);
				animation.addByPrefix('danceLeft', "KB_DanceLeft", 26, false);
				animation.addByPrefix('singUP', "KB_Up", 24, false);
				animation.addByPrefix('singDOWN', "KB_Down", 24, false);
				animation.addByPrefix('singLEFT', 'KB_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'KB_Right', 24, false);

				// Positive = goes to left / Up. -Haz
				// Negative = goes to right / Down. -Haz

				addOffset('danceRight', 119, -96);
				addOffset('danceLeft', 160, -105);
				addOffset("singLEFT", 268, 37);
				addOffset("singRIGHT", -110, -161);
				addOffset("singDOWN", 184, -182);
				addOffset("singUP", 173, 52);
			// Bluescreen section characters:
			case 'gf_404':
				// GIRLFRIEND CODE
				iconColor = "FFA5004D";
				tex = Paths.getSparrowAtlas('GF_assets_404');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');
			case 'bf_404':
				iconColor = "FF31B0D1";
				var tex = Paths.getSparrowAtlas('BOYFRIEND_404');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				animation.addByPrefix('dodge', 'boyfriend dodge', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;

			case 'robot_404':
				iconColor = "FF808080";
				songPosbar = "FF808080";
				songPosbarempty = "FF000000";
				tex = Paths.getSparrowAtlas('robot_404');
				frames = tex;

				animation.addByPrefix('danceRight', "KB404_DanceRight", 25, false);
				animation.addByPrefix('danceLeft', "KB404_DanceLeft", 25, false);
				animation.addByPrefix('singUP', "KB404_Up", 24, false);
				animation.addByPrefix('singDOWN', "KB404_Down", 24, false);
				animation.addByPrefix('singLEFT', 'KB404_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'KB404_Right', 24, false);

				addOffset('danceRight', 119, -96);
				addOffset('danceLeft', 160, -105);
				addOffset("singLEFT", 268, 37);
				addOffset("singRIGHT", -110, -161);
				addOffset("singDOWN", 184, -182);
				addOffset("singUP", 173, 52);

			case 'robot_404-TERMINATION':
				iconColor = "FF808080";
				songPosbar = "FF808080";
				songPosbarempty = "FF000000";
				tex = Paths.getSparrowAtlas('robot_404-angry');
				frames = tex;

				animation.addByPrefix('idle', "KB404ALT_idleBabyRage", 27, false);
				animation.addByPrefix('singUP', "KB404ALT_Up", 24, false);
				animation.addByPrefix('singDOWN', "KB404ALT_Down", 24, false);
				animation.addByPrefix('singLEFT', 'KB404ALT_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'KB404ALT_Right', 24, false);

				addOffset('idle', 168, -129);
				addOffset("singLEFT", 268, 37);
				addOffset("singRIGHT", -110, -161);
				addOffset("singDOWN", 184, -182);
				addOffset("singUP", 173, 52);

			case 'qt-kb':
				iconColor = "FF00A0FF";
				songPosbar = "FF00A0FF";
				songPosbarempty = "FFFB96B7";

				tex = Paths.getSparrowAtlas('bonus/qt-kbV2');
				frames = tex;

				animation.addByPrefix('danceRight', "danceRightNormal", 26, false);
				animation.addByPrefix('danceLeft', "danceLeftNormal", 26, false);

				// kb
				animation.addByPrefix('danceRight-kb', "danceRightKB", 26, false);
				animation.addByPrefix('danceLeft-kb', "danceLeftKB", 26, false);
				animation.addByPrefix('singUP-kb', 'singUpKB', 24, false);
				animation.addByPrefix('singDOWN-kb', 'singDownKB', 24, false);
				animation.addByPrefix('singLEFT-kb', 'singLeftKB', 24, false);
				animation.addByPrefix('singRIGHT-kb', 'singRightKB', 24, false);
				// qt + kb PLACEHOLDER
				animation.addByPrefix('singUP', "singUpTogether", 24, false);
				animation.addByPrefix('singDOWN', "singDownTogether", 24, false);
				animation.addByPrefix('singLEFT', 'singLeftTogether', 24, false);
				animation.addByPrefix('singRIGHT', 'singRightTogether', 24, false);
				// qt
				animation.addByPrefix('singUP-alt', 'singUpQT', 24, false);
				animation.addByPrefix('singDOWN-alt', 'singDownQT', 24, false);
				animation.addByPrefix('singLEFT-alt', 'singLeftQT', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'singRightQT', 24, false);

				// Positive = goes to left / Up. -Haz
				// Negative = goes to right / Down. -Haz

				addOffset('danceRight-kb', 67, -115);
				addOffset('danceLeft-kb', 108, -123);
				addOffset("singUP-kb", 115, 38);
				addOffset("singDOWN-kb", 138, -194);
				addOffset("singLEFT-kb", 214, 23);
				addOffset("singRIGHT-kb", -158, -178);

				addOffset('danceRight', 120, -101);
				addOffset('danceLeft', 160, -110);

				addOffset("singUP", 151, 52);
				addOffset("singDOWN", 140, -196);
				addOffset("singLEFT", 213, 21);
				addOffset("singRIGHT", -163, -172);

				addOffset("singUP-alt", 164, -68);
				addOffset("singDOWN-alt", 99, -168);
				addOffset("singLEFT-alt", 133, -75);
				addOffset("singRIGHT-alt", 16, -135);

			case 'qt-meme':
				iconColor = "FFFB96B7";
				// QT = Cutie
				tex = Paths.getSparrowAtlas('qt_meme');
				frames = tex;
				animation.addByPrefix('idle', 'godIdle', 24, false);
				animation.addByPrefix('singUP', 'godUp', 24, false);
				animation.addByPrefix('singRIGHT', 'godRight', 24, false);
				animation.addByPrefix('singDOWN', 'godDown', 24, false);
				animation.addByPrefix('singLEFT', 'godLeft', 24, false);

				// Positive = goes to left / Up. -Haz
				// Negative = goes to right / Down. -Haz

				addOffset('idle', 0, -177);
				addOffset("singUP", -1, -162);
				addOffset("singRIGHT", 52, -172);
				addOffset("singDOWN", 0, -177);
				addOffset("singLEFT", 64, -171);

				playAnim('idle');

			case 'robot_classic':
				iconColor = "FF808080";

				tex = Paths.getSparrowAtlas('classic/robot_classic');
				frames = tex;

				animation.addByPrefix('danceRight', "KB_DanceRight", 26, false);
				animation.addByPrefix('danceLeft', "KB_DanceLeft", 26, false);
				animation.addByPrefix('singUP', "KB_Up", 24, false);
				animation.addByPrefix('singDOWN', "KB_Down", 24, false);
				animation.addByPrefix('singLEFT', 'KB_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'KB_Right', 24, false);

				addOffset('danceRight', 176, -126);
				addOffset('danceLeft', 160, -122);
				addOffset("singLEFT", 208, -193);
				addOffset("singRIGHT", 70, -140);
				addOffset("singDOWN", 184, -202);
				addOffset("singUP", 173, -18);

			case 'robot_classic_404':
				iconColor = "FF808080";

				tex = Paths.getSparrowAtlas('classic/robot_classic_404');
				frames = tex;

				animation.addByPrefix('danceRight', "KB404_DanceRight", 25, false);
				animation.addByPrefix('danceLeft', "KB404_DanceLeft", 25, false);
				animation.addByPrefix('singUP', "KB404_Up", 24, false);
				animation.addByPrefix('singDOWN', "KB404_Down", 24, false);
				animation.addByPrefix('singLEFT', 'KB404_Left', 24, false);
				animation.addByPrefix('singRIGHT', 'KB404_Right', 24, false);

				addOffset('danceRight', 119, -96);
				addOffset('danceLeft', 160, -105);
				addOffset("singLEFT", 268, 37);
				addOffset("singRIGHT", -110, -161);
				addOffset("singDOWN", 184, -182);
				addOffset("singUP", 173, 52);

			case 'qt_classic':
				iconColor = "FFFB96B7";
				tex = Paths.getSparrowAtlas('classic/qt_classic');
				frames = tex;
				animation.addByPrefix('idle', 'QT_sprite_test-idle', 48, false);
				animation.addByPrefix('singUP', 'QT_sprite_test-up', 48, false);
				animation.addByPrefix('singRIGHT', 'QT_sprite_test-right', 48, false);
				animation.addByPrefix('singDOWN', 'QT_sprite_test-down', 48, false);
				animation.addByPrefix('singLEFT', 'QT_sprite_test-left', 48, false);

				addOffset('idle', 3, -117);
				addOffset("singUP", 33, -76);
				addOffset("singRIGHT", 0, -141);
				addOffset("singDOWN", 54, -144);
				addOffset("singLEFT", -48, -104);

				playAnim('idle');
		}
	}

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = true;
		CharactersSwitchCase();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * Used for idle animations which switch between 2 states (like GF bopping her head from right to left, then left to right). Simply use 'dance(true)' if you wish to use an alt dance animation (if the character supports it!)
	 */
	public function dance(useAltAnimation:Bool = false)
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-christmas':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-car':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf_404':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');

				case 'robot' | 'robot_404' | 'robot_classic' | 'robot_classic_404':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');

				case 'qt-kb':
					danced = !danced;

					if (useAltAnimation)
					{
						if (danced)
							playAnim('danceRight-kb');
						else
							playAnim('danceLeft-kb');
					}
					else
					{
						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf') // wtf is this? -Haz
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	// Currently crashes the game, do not use!
	// UPDATE - THIS IS NO LONGER USED AT ALL AND IS NOW OBSOLETE, DO NOT USE! -Haz
	public function swapCharacter(newCharacter:String) // For changing mid-song -Haz
	{
		curCharacter = newCharacter;
		CharactersSwitchCase();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}
}
