package funkin.states.substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.backend.MusicBeatSubstate;
import funkin.states.PlayState;
import openfl.display.BlendMode;

/**
 * Probably the laziest edit of gameoversubstate but its lowk fine
 */
class GameOverSubstate extends MusicBeatSubstate
{
	public static var instance:Null<GameOverSubstate> = null;

	var soundPrefix:String = '201-street/';
	var camFollow:FlxObject;
	var startedDeath:Bool = false;
	var walkietalkie:FlxSprite;
	var ilovekasaneteto:FlxSprite;
	var bill:Bool = false;
	var billlaugh:FlxSprite;
	var totalElapsed:Float = 0;
	var yellow:FlxSprite;
	var offset:Float;

	override function create()
	{
		instance = this;

		PlayState.instance?.scripts.set('inGameOver', true);
		PlayState.instance?.scripts.call('onGameOverStart', []);

		Conductor.songPosition = 0;

		camFollow = new FlxObject(0, 0);

		if (PlayState.SONG.song.toLowerCase() == 'the crest of entropy') bill = true;

		FlxG.sound.play(Paths.sound(soundPrefix + 'gameover_start'));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = 0.5;

		ilovekasaneteto = new FlxSprite(0, 0);
		if (bill) ilovekasaneteto.loadGraphic(Paths.image("ui/gameover/billtext"));
		else ilovekasaneteto.loadGraphic(Paths.image("ui/gameover/normalgotext"));
		ilovekasaneteto.screenCenter();
		ilovekasaneteto.y -= 400;
		ilovekasaneteto.alpha = 0;
		add(ilovekasaneteto);

		walkietalkie = new FlxSprite(0, 0);
		walkietalkie.frames = Paths.getSparrowAtlas("ui/gameover/walkie");
		walkietalkie.animation.addByPrefix('idle', 'idle0', 12, true);
		walkietalkie.animation.addByPrefix('confirm', 'confirm0', 24, true);
		walkietalkie.animation.play('idle');
		walkietalkie.screenCenter();
		walkietalkie.y += 400;
		walkietalkie.alpha = 0;
		add(walkietalkie);

		yellow = new FlxSprite(0, 0).loadGraphic(Paths.image("ui/gameover/yellow"));
		yellow.blend = BlendMode.MULTIPLY;
		yellow.scale.set(1.4, 1.4);
		yellow.screenCenter();
		yellow.y -= 80;
		if (bill) add(yellow);

		billlaugh = new FlxSprite(0, 0);
		billlaugh.frames = Paths.getSparrowAtlas("ui/gameover/billover");
		billlaugh.animation.addByPrefix('laugh', 'laugh0', 24, true);
		billlaugh.screenCenter();
		billlaugh.x -= 800;
		billlaugh.alpha = 0;
		billlaugh.scale.set(2, 0.2);
		if (bill) add(billlaugh);

		var gayTimer:FlxTimer = null;
		var billTimer:FlxTimer = null;
		gayTimer = FlxTimer.wait(2, () -> {
			FunkinSound.playMusic(Paths.music(soundPrefix + 'gameover'));
			if (bill)
			{
				FlxG.sound.play(Paths.sound(soundPrefix + 'billgameover/gameover' + Std.string(FlxG.random.int(1, 9))));
				billlaugh.alpha = 1;
				offset = 50;

				FlxTween.tween(billlaugh.scale, {x: 0.2}, 0.1,
					{
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween) {
							FlxTween.tween(billlaugh.scale, {y: 2}, 0.1,
								{
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween) {
										FlxTween.tween(billlaugh.scale, {x: 1}, 0.1, {ease: FlxEase.quadOut});
										FlxTween.tween(billlaugh.scale, {y: 1}, 0.1, {ease: FlxEase.quadOut});
									}
								});
						}
					});

				billlaugh.animation.play('laugh');
			}
			FlxTween.tween(walkietalkie, {alpha: 1}, 1);
			FlxTween.tween(ilovekasaneteto, {alpha: 1}, 1, {startDelay: 2});
			startedDeath = true;
		});

		super.create();

		PlayState.instance?.scripts.call('onGameOverPost', []);

		trace(PlayState.SONG.song.toLowerCase());
	}

	public function new()
	{
		super();
	}

	override function update(elapsed:Float)
	{
		PlayState.instance?.scripts.call('onUpdate', [elapsed]);
		super.update(elapsed);

		totalElapsed += elapsed;
		if (bill)
		{
			billlaugh.y = 2 + Math.sin(totalElapsed * 5) * 40;
			billlaugh.x = 250 + Math.sin(totalElapsed * 2) * 600;
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			FlxG.switchState(() -> new OverworldState());
			PlayState.instance?.scripts.call('onGameOverConfirm', [false]);
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		PlayState.instance?.scripts.call('onUpdatePost', [elapsed]);
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(soundPrefix + 'gameover_retry'));
			walkietalkie.animation.play('confirm');
			walkietalkie.offset.set(0, 331);
			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
					FlxG.resetState();
				});
			});

			FlxTween.tween(billlaugh.scale, {x: 0.2}, 0.1,
				{
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween) {
						FlxTween.tween(billlaugh.scale, {y: 2}, 0.1,
							{
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween) {
									FlxTween.tween(billlaugh.scale, {x: 0}, 0.1, {ease: FlxEase.quadOut});
									FlxTween.tween(billlaugh.scale, {y: 0}, 0.1, {ease: FlxEase.quadOut});
								}
							});
					}
				});

			PlayState.instance?.scripts.call('onGameOverConfirm', [true]);
		}
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
