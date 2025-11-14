package funkin.objects;

import flixel.util.FlxAxes;
import openfl.media.Sound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import funkin.objects.ControlText;

/**
	* WE LOVE YOU DATA5
	WE LOVE YOU DATA 5
 */
class AttachedControlText extends ControlText
{
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var sprTracker:FlxSprite;
	public var copyVisible:Bool = true;
	public var copyAlpha:Bool = false;

	public function new(text:String = "", ?offsetX:Float = 0, ?offsetY:Float = 0)
	{
		super(0, 0, text);
		isMenuItem = false;
		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}

	override function update(elapsed:Float)
	{
		if (sprTracker != null)
		{
			setPosition(sprTracker.x + offsetX, sprTracker.y + offsetY);
			if (copyVisible)
			{
				visible = sprTracker.visible;
			}
			if (copyAlpha)
			{
				alpha = sprTracker.alpha;
			}
		}

		super.update(elapsed);
	}
}
