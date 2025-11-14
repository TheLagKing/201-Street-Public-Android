package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.data.WeekData;
import flash.display.BlendMode;
#if VIDEOS_ALLOWED
import funkin.video.FunkinVideoSprite;
#end

class CreditsState extends MusicBeatState
{
	var curImage:Int = 0;
	var inVideo:Bool = false;
	var creditsImage:FlxSprite;
	var uiImage:FlxSprite;
	var video:FunkinVideoSprite;

	override public function create():Void
	{
		FunkinAssets.cache.clearStoredMemory();
		FunkinAssets.cache.clearUnusedMemory();

		creditsImage = new FlxSprite(0, 0).loadGraphic(Paths.image('credits/0'));
		creditsImage.antialiasing = ClientPrefs.globalAntialiasing;
		creditsImage.setGraphicSize(0, FlxG.height);
		creditsImage.updateHitbox();
		add(creditsImage);

		uiImage = new FlxSprite(0, 0).loadGraphic(Paths.image('credits/ui'));
		uiImage.antialiasing = ClientPrefs.globalAntialiasing;
		uiImage.setGraphicSize(0, FlxG.height);
		uiImage.updateHitbox();
		add(uiImage);

		video = new FunkinVideoSprite();
		video.onFormat(() -> {
			video.setGraphicSize(1280);
			video.updateHitbox();
			video.screenCenter();
		});
		video.onEnd(() -> {
			video.visible = false;
			uiImage.visible = true;
			creditsImage.visible = true;
			inVideo = false;
			FlxG.sound.music.resume();
		});
		video.load(Paths.video('credits'));
		add(video);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (!inVideo)
		{
			if (controls.UI_LEFT_P)
			{
				changeImage(-1);
			}
			if (controls.UI_RIGHT_P)
			{
				changeImage(1);
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(TitleState201.new);
			}
			if (FlxG.keys.justPressed.SPACE)
			{
				inVideo = true;
				uiImage.visible = false;
				creditsImage.visible = false;
				FlxG.sound.music.pause();
				video.play();
			}
		}

		super.update(elapsed);
	}

	function changeImage(change:Int = 0)
	{
		curImage = FlxMath.wrap(curImage + change, 0, 15);
		creditsImage.loadGraphic(Paths.image('credits/' + curImage));
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		super.destroy();
	}
}
