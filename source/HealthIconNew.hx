package;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class HealthIconNew extends FlxSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;

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
		loadGraphic(Paths.image('icons/icon-' + char, 'preload'), true, 150, 150);
		animation.add(char, [0, 1], 0, false, isPlayer);
		animation.play(char);
		antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
