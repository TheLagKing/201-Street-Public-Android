package funkin.states.options;

import flixel.util.FlxStringUtil;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.math.FlxPoint;
import funkin.states.*;
import funkin.objects.*;
import funkin.objects.Character;

using StringTools;

class NoteOffsetState extends MusicBeatState
{
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	public static var onPhone:Bool = false;

	var coolText:FlxText;

	var barPercent:Float = 0;
	var delayMin:Int = 0;
	var delayMax:Int = 500;
	var timeBarBG:FlxSprite;
	var timeBar:FlxBar;
	var timeTxt:FlxText;
	var beatText:Alphabet;
	var beatTween:FlxTween;

	var canBackOut = true;

	override public function create()
	{
		// Cameras
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		FlxG.camera.scroll.set(120, 130);

		persistentUpdate = true;
		FlxG.sound.pause();
		// Stage
		var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		add(bg);

		var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		add(stageFront);

		// Note delay stuff

		beatText = new Alphabet(0, 0, 'Beat Hit!', true, false, 0.05, 0.6);
		beatText.x += 260;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		add(beatText);

		timeTxt = new FlxText(0, 600, FlxG.width, "", 32);
		timeTxt.setFormat(Paths.font("ATTFShinGoProBold.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 2;
		timeTxt.cameras = [camHUD];

		barPercent = ClientPrefs.noteOffset;
		updateNoteDelay();

		timeBarBG = new FlxSprite(0, timeTxt.y + 8).loadGraphic(Paths.image('timeBar'));
		timeBarBG.setGraphicSize(Std.int(timeBarBG.width * 1.2));
		timeBarBG.updateHitbox();
		timeBarBG.cameras = [camHUD];
		timeBarBG.screenCenter(X);

		timeBar = new FlxBar(0, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'barPercent', delayMin,
			delayMax);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.cameras = [camHUD];

		add(timeBarBG);
		add(timeBar);
		add(timeTxt);

		Conductor.bpm = 128.0;
		FunkinSound.playMusic(Paths.music('offsetSong'), 1, true);

		super.create();
	}

	var holdTime:Float = 0;

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		var addNum:Int = !FlxG.keys.pressed.SHIFT ? 1 : 10;

		if (controls.UI_LEFT_P)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.noteOffset - 1, delayMax));
			updateNoteDelay();
		}
		else if (controls.UI_RIGHT_P)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.noteOffset + 1, delayMax));
			updateNoteDelay();
		}

		var mult:Int = 1;
		if (controls.UI_LEFT || controls.UI_RIGHT)
		{
			holdTime += elapsed;
			if (controls.UI_LEFT) mult = -1;
		}

		if (controls.UI_LEFT_R || controls.UI_RIGHT_R) holdTime = 0;

		if (holdTime > 0.5)
		{
			barPercent += 100 * elapsed * mult;
			barPercent = Math.max(delayMin, Math.min(barPercent, delayMax));
			updateNoteDelay();
		}

		if (controls.RESET)
		{
			holdTime = 0;
			barPercent = 0;
			updateNoteDelay();
		}

		if (controls.BACK && canBackOut)
		{
			canBackOut = false;
			zoomTween?.cancel();
			beatTween?.cancel();

			// trace('WHY ARE YOU DOING THIS TO ME');
			try
			{
				timeBar.destroy();
				if (onPhone) FlxG.switchState(OverworldState.new);
				else FlxG.switchState(TitleState201.new);
			}
			catch (e)
			{
				trace(e);
			}
		}

		super.update(elapsed);
	}

	var zoomTween:FlxTween;
	var lastBeatHit:Int = -1;

	override public function beatHit()
	{
		super.beatHit();

		if (lastBeatHit == curBeat)
		{
			return;
		}

		if (curBeat % 4 == 2)
		{
			FlxG.camera.zoom = 1.15;

			if (zoomTween != null) zoomTween.cancel();
			zoomTween = FlxTween.tween(FlxG.camera, {zoom: 1}, 1,
				{
					ease: FlxEase.circOut,
					onComplete: (_) -> zoomTween = null
				});

			beatText.alpha = 1;
			beatText.y = 320;
			beatText.velocity.y = -150;
			beatTween?.cancel();
			beatTween = FlxTween.tween(beatText, {alpha: 0}, 1,
				{
					ease: FlxEase.sineIn,
					onComplete: (_) -> beatTween = null
				});
		}

		lastBeatHit = curBeat;
	}

	function updateNoteDelay()
	{
		ClientPrefs.noteOffset = Math.round(barPercent);
		timeTxt.text = 'Current offset: ${Math.floor(barPercent)}  ms';
	}
}
