package funkin.objects;

import flixel.util.FlxAxes;
import openfl.media.Sound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

/**
	* WE LOVE YOU DATA5
	WE LOVE YOU DATA 5
 */
class ControlText extends FlxText // quick and easy
{
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Int = 0;
	public var yMult:Float = 80;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var isMenuItem:Bool = false;

	public function new(x:Float, y:Float, text:String)
	{
		super(x, y, 0, text, 25);

		this.setFormat(Paths.font("ATTFShinGoProBold.ttf"), 40, 0xFFFFFF, LEFT, OUTLINE, FlxColor.BLACK);
		this.borderSize = 2;
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			final lerpRate = FlxMath.getElapsedLerp(0.16, elapsed);

			y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpRate);
			if (forceX != Math.NEGATIVE_INFINITY)
			{
				x = forceX;
			}
			else
			{
				x = FlxMath.lerp(x, (targetY * 20) + 90 + xAdd, lerpRate);
			}
		}

		super.update(elapsed);
	}

	public function changeText(newText:String)
	{
		this.text = newText;
	}

	public function snap()
	{
		final scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

		y = (scaledY * yMult) + (FlxG.height * 0.48) + yAdd;
	}
}
