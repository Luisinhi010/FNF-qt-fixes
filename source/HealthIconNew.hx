package;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class HealthIconNew extends FlxSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(?char:String = "bf", ?isPlayer:Bool = false)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;

		changeIcon(char);
		scrollFactor.set();
	}

	public function changeIcon(char:String)
	{
		if (Paths.fileExists('icons/icon-' + char + '.png', IMAGE, 'preload'))
		{
			loadGraphic(Paths.image('icons/icon-' + char, 'preload'), true, 150, 150);
			animation.add(char, [0, 1], 0, false, isPlayer);
			animation.play(char);
		}
		else
		{
			loadGraphic(Paths.image('iconGrid'), true, 150, 150);
			animation.add('bf', [0, 1], 0, false, isPlayer);
			animation.add('bf_404', [0, 1], 0, false, isPlayer); // Just in case;
			animation.add('bf-old', [14, 15], 0, false, isPlayer);
			animation.add('gf', [16], 0, false, isPlayer);
			animation.add('robot', [24, 25], 0, false, isPlayer);
			animation.add('robot-angry', [25], 0, false, isPlayer); // Freeplay shit
			animation.add('robot_404', [24, 25], 0, false, isPlayer); // Just in case;
			animation.add('robot_404-TERMINATION', [24, 25], 0, false, isPlayer); // Just in case;
			animation.add('qt', [26, 27], 0, false, isPlayer);
			animation.add('qt_annoyed', [32, 27], 0, false, isPlayer);
			animation.add('qt-meme', [26, 27], 0, false, isPlayer);
			animation.add('qt-kb', [28, 29], 0, false, isPlayer);
			animation.add('qt_classic', [26, 27], 0, false, isPlayer);
			animation.add('robot_classic', [24, 25], 0, false, isPlayer);
			animation.add('robot_classic_404', [24, 25], 0, false, isPlayer);
			animation.play(char);
		}
		antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
