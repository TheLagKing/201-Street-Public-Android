package funkin.states.substates;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import funkin.states.*;
import funkin.backend.MusicBeatSubstate;

using StringTools;

class ExitToMenuSubstate extends MusicBeatSubstate
{
	final FILE_PREFIX:String = "overworld/ui/phoneui/";

	// SPRITES
	var bg:FlxSprite;
	var question:FlxSprite;
	var yes:FlxSprite;
	var yesLerp:Float = 0.0;
	var no:FlxSprite;
	var noLerp:Float = 0.0;

	// LOGIC
	var selected:String = "";
	var mouseObject:FlxObject;

	public function new()
	{
		super();

		camera = CameraUtil.lastCamera;
	}

	override function create()
	{
		super.create();

		mouseObject = new FlxObject(0, 0, 5, 5);
		add(mouseObject);

		bg = new FlxSprite(0, 0).makeGraphic(FlxG.width + 1, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		add(bg);

		question = new FlxSprite(0, 30).loadGraphic(Paths.image(FILE_PREFIX + "readytoleave"));
		question.antialiasing = ClientPrefs.globalAntialiasing;
		question.screenCenter(X);
		add(question);

		yes = new FlxSprite(100, 370).loadGraphic(Paths.image(FILE_PREFIX + "outtahere"));
		yes.antialiasing = ClientPrefs.globalAntialiasing;
		yes.alpha = 0.5;
		yes.scale.set(0.8, 0.8);
		add(yes);

		no = new FlxSprite(FlxG.width - 100, 370).loadGraphic(Paths.image(FILE_PREFIX + "stayin"));
		no.antialiasing = ClientPrefs.globalAntialiasing;
		no.x -= no.width;
		no.alpha = 0.5;
		no.scale.set(0.8, 0.8);
		add(no);

		FlxTween.tween(bg, {alpha: 0.7}, 0.3);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		mouseObject.setPosition(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);

		var isOverlapped:Bool = false;

		if (FlxG.overlap(mouseObject, yes))
		{
			isOverlapped = true;

			yes.alpha = 1;
			yes.scale.set(1, 1);

			if (FlxG.mouse.justPressed)
			{
				FlxG.switchState(TitleState201.new);
			}
		}
		else
		{
			yes.alpha = 0.5;
			yes.scale.set(0.8, 0.8);
		}

		if (FlxG.overlap(mouseObject, no))
		{
			isOverlapped = true;

			no.alpha = 1;
			no.scale.set(1, 1);

			if (FlxG.mouse.justPressed)
			{
				close();
			}
		}
		else
		{
			no.alpha = 0.5;
			no.scale.set(0.8, 0.8);
		}

		if (isOverlapped)
		{
			FlxG.mouse.load(Paths.image("overworld/ui/cursor/click").bitmap, 0.325);
		}
		else
		{
			FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursor").bitmap, 0.325);
		}
		if (controls.BACK) close();
	}
}
