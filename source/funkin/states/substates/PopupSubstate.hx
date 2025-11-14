package funkin.states.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.data.*;
import funkin.states.*;
import funkin.objects.*;
import funkin.backend.MusicBeatSubstate;

using StringTools;

class PopupSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var canInput:Bool = false;

	public function new(popupText:String = 'this is my ligma song', buttontext:String = 'OK')
	{
		// Not gonna lie... THIS IS A BIG FAT PLACEHOLDER THAT I TOOK FROM VS IMPOSTOR!
		super();
		var cam:FlxCamera = CameraUtil.lastCamera;
		trace(popupText);
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		add(bg);

		var looey:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/repo/chickenboy'), true, 161, 203);
		looey.animation.add('yy', [
			0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
			39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49
		], 24, true);
		looey.animation.play('yy');
		add(looey);

		FlxTween.tween(bg, {alpha: 0.5}, 0.5);

		FlxTimer.wait(0.5, onComp);
		camera = cam;
	}

	function onComp()
	{
		canInput = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (canInput) if (controls.ACCEPT) close();
	}
}
