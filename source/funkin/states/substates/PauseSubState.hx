package funkin.states.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteContainer;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import funkin.backend.Difficulty;
import funkin.utils.CameraUtil;
import funkin.states.options.OptionsState;
import funkin.backend.MusicBeatSubstate;
import funkin.data.*;
import funkin.states.*;
import funkin.objects.*;
import funkin.scripts.*;

class PauseSubState extends MusicBeatSubstate
{
	final FONT:String = Paths.font("ATTFShinGoProBold.ttf");
	final PADDING:Float = 15;
	var fontSize:Int = 40;
	var cornerScale:Float = 0.8;
	var albumX:Float = 0;
	var albumScale:Float = 0.5;

	var grpMenuShit:FlxTypedSpriteGroup<FlxText>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to Overworld'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var albumGroup:FlxSpriteGroup;
	var album:FlxSprite;
	var vinyl:FlxSprite;

	var pause:FlxSprite;

	var nameText:FlxText;
	var diffText:FlxText;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var curTime:Float = Math.max(0, Conductor.songPosition);

	var cam:FlxCamera = CameraUtil.lastCamera;

	// var botplayText:FlxText;
	public static var songName:String = '';

	override function create()
	{
		songName = '201-street/hold_the_phone';

		initStateScript('PauseSubState');

		if (isHardcodedState())
		{
			if (PlayState.chartingMode #if debug || true #end)
			{
				var shit:Int = 2;
				if (PlayState.chartingMode)
				{
					menuItemsOG.insert(shit, 'Leave Charting Mode');
					shit++;
				}

				var num:Int = 0;
				if (!PlayState.instance.startingSong)
				{
					num = 1;
					menuItemsOG.insert(shit, 'Skip Time');
				}
				menuItemsOG.insert(shit + num, 'End Song');
				menuItemsOG.insert(shit + num, 'Toggle Practice Mode');
				menuItemsOG.insert(shit + num, 'Toggle Botplay');
				// menuItemsOG.insert(shit + num, 'Hawk Tuah Respect Button -->');
			}
			menuItems = menuItemsOG;

			for (i in 0...Difficulty.difficulties.length)
			{
				var diff:String = '' + Difficulty.difficulties[i];
				difficultyChoices.push(diff);
			}
			difficultyChoices.push('BACK');

			pauseMusic = new FlxSound();
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
			pauseMusic.volume = 0;
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			FlxG.sound.list.add(pauseMusic);

			var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
			bg.setGraphicSize(cam.width + 1, cam.height);
			bg.updateHitbox();
			bg.scrollFactor.set();
			add(bg);
			bg.alpha = 0;

			// coding the camera border. call that the four corners challenge
			pause = new FlxSprite(PADDING, PADDING).loadGraphic(Paths.image("pause/pause"));
			pause.antialiasing = ClientPrefs.globalAntialiasing;
			pause.alpha = 0;
			pause.scale.set(cornerScale, cornerScale);
			add(pause);

			FlxTween.tween(pause, {alpha: 1}, 1.2, {type: PINGPONG, ease: FlxEase.sineOut});

			var rightCorner:FlxSprite = new FlxSprite(0, PADDING).loadGraphic(Paths.image("pause/t-right"));
			rightCorner.updateHitbox();
			rightCorner.scale.set(cornerScale, cornerScale);
			rightCorner.x = cam.width - rightCorner.width - PADDING;
			rightCorner.antialiasing = ClientPrefs.globalAntialiasing;
			add(rightCorner);

			var leftCorner:FlxSprite = new FlxSprite(PADDING, 0).loadGraphic(Paths.image("pause/b-left"));
			leftCorner.updateHitbox();
			leftCorner.scale.set(cornerScale, cornerScale);
			leftCorner.y = cam.height - rightCorner.height - PADDING;
			leftCorner.antialiasing = ClientPrefs.globalAntialiasing;
			add(leftCorner);

			var fear:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("pause/fear"));
			fear.updateHitbox();
			fear.scale.set(cornerScale, cornerScale);
			fear.x = cam.width - fear.width - PADDING - 2;
			fear.y = cam.height - fear.height - PADDING - 2;
			fear.antialiasing = ClientPrefs.globalAntialiasing;
			add(fear);

			if (cam.width < 1280)
			{
				var ratio:Float = cam.width / 1280;

				fontSize = Math.round(FlxMath.lerp(10, 40, ratio));
				albumX = FlxMath.lerp(-400, 0, ratio);
				albumScale = FlxMath.lerp(0.1, 0.5, ratio);
			}

			albumGroup = new FlxSpriteGroup();
			albumGroup.updateHitbox();
			add(albumGroup);

			vinyl = new FlxSprite(0, 0).loadGraphic(Paths.image("pause/vinyl"));
			albumGroup.add(vinyl);
			vinyl.visible = false;
			vinyl.antialiasing = ClientPrefs.globalAntialiasing;
			vinyl.updateHitbox();

			album = new FlxSprite(0, 0).loadGraphic(Paths.image("albums/" + Paths.formatToSongPath(PlayState.SONG.song)));
			albumGroup.add(album);
			album.antialiasing = ClientPrefs.globalAntialiasing;
			album.updateHitbox();

			albumGroup.scale.set(albumScale, albumScale);
			albumGroup.screenCenter(Y);
			albumGroup.x = albumX;

			// temp just wanted to see this
			var meta:Metadata = PlayState.meta;
			if (meta != null)
			{
				// if (meta.composers != null) createCornerText("Composers: " + meta.composers, true);
				// if (meta.charters != null) createCornerText("Charters: " + meta.charters, true);
				// if (meta.artists != null) createCornerText("Artists: " + meta.artists, true);
				// if (meta.coders != null) createCornerText("Coders: " + meta.coders, true);
			}

			FlxTween.tween(bg, {alpha: 0.8}, 0.1);

			var yt:Float = 15;

			grpMenuShit = new FlxTypedSpriteGroup<FlxText>();
			add(grpMenuShit);

			nameText = new FlxText(0, 0).setFormat(FONT, fontSize, FlxColor.WHITE, CENTER);
			nameText.text = PlayState.SONG.song + " - " + Difficulty.getCurDifficulty().toUpperCase();
			nameText.screenCenter(X);
			nameText.y = PADDING * 3;
			add(nameText);

			skipTimeText = new FlxText(0, 0).setFormat(FONT, 26, FlxColor.WHITE, CENTER);
			skipTimeText.antialiasing = ClientPrefs.globalAntialiasing;
			skipTimeText.alpha = 0;
			add(skipTimeText);

			cameras = [cam];

			regenMenu();

			introTweens(25.0);
		}

		super.create();

		scriptGroup.call('onCreatePost', []);
	}

	function introTweens(amount:Float)
	{
		if (albumGroup == null || grpMenuShit == null) return;

		var dur:Float = 0.3;

		albumGroup.x -= amount;
		grpMenuShit.x += amount;

		FlxTween.tween(grpMenuShit, {x: grpMenuShit.x - amount, alpha: 1}, dur, {ease: FlxEase.sineOut});
		FlxTween.tween(albumGroup, {x: albumGroup.x + amount, alpha: 1}, dur,
			{
				ease: FlxEase.sineOut,
				onComplete: function(twn:FlxTween) {
					vinyl.visible = true;
					FlxTween.tween(vinyl, {x: vinyl.x + (200 * albumScale)}, 1, {ease: FlxEase.sineOut});
				}
			});
	}

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (isHardcodedState()) if (pauseMusic.volume < 0.5) pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (isHardcodedState())
		{
			if (controls.UI_UP_P)
			{
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P)
			{
				changeSelection(1);
			}

			if (vinyl != null)
			{
				vinyl.angle += elapsed * 10;
			}

			var daSelected:String = menuItems[curSelected];
			switch (daSelected)
			{
				case 'Skip Time':
					if (controls.UI_LEFT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						curTime -= 1000;
						holdTime = 0;
					}
					if (controls.UI_RIGHT_P)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
						curTime += 1000;
						holdTime = 0;
					}

					if (controls.UI_LEFT || controls.UI_RIGHT)
					{
						holdTime += elapsed;
						if (holdTime > 0.5)
						{
							curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
						}

						if (curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
						else if (curTime < 0) curTime += FlxG.sound.music.length;
						updateSkipTimeText();
					}
			}

			if (controls.BACK)
			{
				close();
			}

			if (controls.ACCEPT)
			{
				if (menuItems == difficultyChoices)
				{
					if (menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected))
					{
						PlayState.SONG = Chart.fromSong(PlayState.SONG.song, curSelected);
						PlayState.storyMeta.difficulty = curSelected;
						FlxG.resetState();
						FlxG.sound.music.volume = 0;
						PlayState.changedDifficulty = true;
						PlayState.chartingMode = false;

						if (skipTimeText != null)
						{
							skipTimeText.kill();
							remove(skipTimeText);
							skipTimeText.destroy();
						}
						skipTimeText = null;
						return;
					}

					menuItems = menuItemsOG;
					regenMenu();
				}

				switch (daSelected)
				{
					case 'Options':
						PlayState.instance.paused = true;
						PlayState.instance.vocals.volume = 0;
						FlxG.switchState(() -> new OptionsState());
						@:privateAccess
						{
							if (pauseMusic._sound != null)
							{
								FunkinSound.playMusic(pauseMusic._sound, 0);
								FlxTween.tween(FlxG.sound.music, {volume: 0.5}, 0.7);
							}
						}

						OptionsState.onPlayState = true;
						OptionsState.onPhone = false;
					case "Resume":
						close();
					case 'Change Difficulty':
						menuItems = difficultyChoices;
						regenMenu();
					case 'Toggle Practice Mode':
						PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
						PlayState.changedDifficulty = true;
						practiceText.visible = PlayState.instance.practiceMode;
					case "Restart Song":
						restartSong();
					case "Leave Charting Mode":
						restartSong();
						PlayState.chartingMode = false;
					case 'Skip Time':
						if (curTime < Conductor.songPosition)
						{
							PlayState.startOnTime = curTime;
							restartSong(true);
						}
						else
						{
							if (curTime != Conductor.songPosition)
							{
								PlayState.instance.clearNotesBefore(curTime);
								PlayState.instance.setSongTime(curTime);
							}
							close();
						}
					case "End Song":
						close();
						PlayState.instance.finishSong(true);
					case 'Toggle Botplay':
						PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
						PlayState.changedDifficulty = true;
						PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
						PlayState.instance.botplayTxt.alpha = 1;
					case 'Hawk Tuah Respect Button -->':
						FlxG.sound.play(Paths.sound('untitled1'));
					case "Exit to Overworld":
						PlayState.deathCounter = 0;
						PlayState.seenCutscene = false;
						FlxG.switchState(() -> new OverworldState());
						CoolUtil.cancelMusicFadeTween();
						// FunkinSound.playMusic(Paths.music('freakyMenu'));
						PlayState.changedDifficulty = false;
						PlayState.chartingMode = false;
				}
			}
		}
	}

	public function restartSong(noTrans:Bool = false)
	{
		if (scriptGroup.call('onRestart', []) != ScriptConstants.Function_Stop)
		{
			PlayState.instance.paused = true;
			FlxG.sound.music.volume = 0;
			PlayState.instance.vocals.volume = 0;

			if (noTrans)
			{
				FlxTransitionableState.skipNextTransOut = true;
			}

			FlxG.resetState();
		}
	}

	override function destroy()
	{
		if (isHardcodedState()) pauseMusic.destroy();
		scriptGroup.call('onDestroy', []);

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		var ret = scriptGroup.call('onChangeSelection', [curSelected]);

		if (ret != ScriptConstants.Function_Stop)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

			for (k => item in grpMenuShit.members)
			{
				item.alpha = 0.4;

				if (k == curSelected)
				{
					item.alpha = 1;

					if (item.text == "Skip Time")
					{
						skipTimeText.y = item.y;
						skipTimeText.alpha = 1;
						updateSkipTimeText();
					}
					else
					{
						skipTimeText.alpha = 0;
					}
				}
			}
		}
	}

	function regenMenu():Void
	{
		for (i in 0...grpMenuShit.members.length)
		{
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length)
		{
			var item:FlxText = new FlxText(0, Math.round(fontSize * 1.2) * i, 600).setFormat(FONT, fontSize, FlxColor.WHITE, LEFT);
			item.text = menuItems[i];
			item.antialiasing = ClientPrefs.globalAntialiasing;
			grpMenuShit.add(item);
		}

		grpMenuShit.updateHitbox();
		grpMenuShit.screenCenter();
		grpMenuShit.x += 50;
		grpMenuShit.y -= (grpMenuShit.height / 2);

		curSelected = 0;
		changeSelection();
		scriptGroup.call('onRegenMenu', []);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false)
			+ ' / '
			+ FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}

	function deleteSkipTimeText()
	{
		if (skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
	}
}
