package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.data.WeekData;
import funkin.objects.overworld.DialogueBox;
import funkin.data.Highscore;
import funkin.states.*;
import funkin.states.options.*;
import flash.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

class TitleState201 extends MusicBeatState
{
	public static var instance:Null<TitleState201> = null;

	static var initialized:Bool = false;
	static var closedState:Bool = false;
	static var isTitle = true; // Used for determining if this state is on the title screen or the main menu
	static var curDiff = 'hard';

	var versionText:FlxText;
	var versionString:String = 'v1.0';

	var isNewGame = false; // Used for when starting a new game

	var sky:FlxSprite;
	var clouds:FlxBackdrop;
	var cloudShaderObj:FlxSprite;
	var mountains:FlxSprite;
	var house:FlxSprite;
	var fog:FlxBackdrop;
	var fg:FlxSprite;

	var black_screen:FlxSprite;
	var hopscotch_logo:FlxSprite;

	// Title Stuff
	var logo:FlxSprite;
	var pressStart:FlxSprite;
	var startTween:FlxTween;

	// Menu Stuff
	var canClick:Bool = false;
	var transitioning:Bool = false;
	var transitionTimer:FlxTimer = null;

	var optionGrp:Null<FlxTypedGroup<FlxSprite>> = null;
	var options:Array<String> = ['newgame', 'continue', 'credits', 'options'];
	var optionsBG:FlxSprite;

	var diffGrp:Null<FlxTypedGroup<FlxSprite>> = null;
	var diffs:Array<String> = ['hard', 'frightful'];
	var diffsBG:FlxSprite;

	var cloudShader:funkin.backend.FunkinShader.FunkinRuntimeShader;

	var poster:FlxSprite;
	var dialogue_box:DialogueBox;
	var camFollow:Null<FlxObject> = null;
	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	public static var firstLoad:Bool = true;

	var overworldData:Bool = false;
	var beatenGame:Bool = false;

	var curSelected:Int = 0;
	var curSelectedDiff:Int = 0;

	override public function create():Void
	{
		instance = this;

		FunkinAssets.cache.clearStoredMemory();
		FunkinAssets.cache.clearUnusedMemory();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();

		camGame = new FlxCameraEx();
		camHUD = new FlxCameraEx();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		persistentUpdate = persistentDraw = true;

		camFollow = new FlxObject(640, FlxG.height / 2, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, null, 0.075);

		sky = new FlxSprite(1, -758).loadGraphic(Paths.image('title/bg/BG1'));
		sky.antialiasing = ClientPrefs.globalAntialiasing;
		add(sky);

		clouds = new FlxBackdrop(Paths.image('title/bg/BG2'), FlxAxes.X, 0, 0);
		clouds.x = -1;
		clouds.y = -610;
		clouds.antialiasing = ClientPrefs.globalAntialiasing;
		add(clouds);

		cloudShader = newShader('cloud');
		cloudShader.setFloat('red_amt', 0.4);
		cloudShader.setFloat('green_amt', 0.5);
		cloudShader.setFloat('blue_amt', 0.3);

		cloudShaderObj = new FlxSprite(1, 0 - FlxG.height).makeGraphic(1280, 720 * 3, FlxColor.WHITE);
		cloudShaderObj.antialiasing = ClientPrefs.globalAntialiasing;
		cloudShaderObj.blend = BlendMode.ADD;
		cloudShaderObj.shader = cloudShader;
		add(cloudShaderObj);

		mountains = new FlxSprite(1, 134).loadGraphic(Paths.image('title/bg/BG3'));
		mountains.antialiasing = ClientPrefs.globalAntialiasing;
		add(mountains);

		house = new FlxSprite(441, 11).loadGraphic(Paths.image('title/bg/BG4'));
		house.antialiasing = ClientPrefs.globalAntialiasing;
		add(house);

		fog = new FlxBackdrop(Paths.image('title/bg/BG5'), FlxAxes.X, 0, 0);
		fog.x = 1;
		fog.y = 415;
		fog.antialiasing = ClientPrefs.globalAntialiasing;
		add(fog);

		fg = new FlxSprite(1, 191).loadGraphic(Paths.image('title/bg/BG6'));
		fg.antialiasing = ClientPrefs.globalAntialiasing;
		add(fg);

		logo = new FlxSprite(17.2, 24.25).loadGraphic(Paths.image('title/logo'));
		logo.scale.set(0.275, 0.275);
		logo.updateHitbox();
		logo.alpha = 0;
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		add(logo);

		pressStart = new FlxSprite(75, 535).loadGraphic(Paths.image('title/press enter'));
		pressStart.antialiasing = ClientPrefs.globalAntialiasing;
		pressStart.alpha = 0;
		add(pressStart);

		versionText = new FlxText(0, 0, -1, versionString);
		versionText.setFormat(Paths.font("ATTFShinGoProBold.ttf"), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionText.x = -versionText.width;
		versionText.y = FlxG.height - versionText.height;
		add(versionText);

		optionsBG = new FlxSprite(214, 720).loadGraphic(Paths.image('title/sign'));
		optionsBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(optionsBG);

		diffsBG = new FlxSprite(435, 720).loadGraphic(Paths.image('title/tv'));
		diffsBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(diffsBG);

		diffGrp = new FlxTypedGroup<FlxSprite>();
		for (i in 0...diffs.length)
		{
			var button = new FlxSprite(0, 0).loadGraphic(Paths.image('title/diff_' + diffs[i]));

			switch (i)
			{
				case 0:
					button.x = 479;
				case 1:
					button.x = 612;
			}

			button.antialiasing = ClientPrefs.globalAntialiasing;
			button.ID = i;
			button.updateHitbox();
			button.alpha = 0;
			diffGrp.add(button);
		}
		add(diffGrp);

		optionGrp = new FlxTypedGroup<FlxSprite>();
		for (i in 0...options.length)
		{
			var button = new FlxSprite(0, 0).loadGraphic(Paths.image('title/' + options[i]));

			switch (i)
			{
				case 0:
					button.x = 247;
					button.y = 159;
				case 1:
					button.x = 294;
					button.y = 300;
				case 2:
					button.x = 232;
					button.y = 402;
				case 3:
					button.x = 260;
					button.y = 509;
			}

			button.antialiasing = ClientPrefs.globalAntialiasing;
			button.ID = i;
			button.updateHitbox();
			button.alpha = 0;
			optionGrp.add(button);
		}
		add(optionGrp);

		poster = new FlxSprite(370, -30).loadGraphic(Paths.image('title/poster'));
		poster.antialiasing = ClientPrefs.globalAntialiasing;
		poster.camera = camHUD;
		poster.alpha = 0;
		poster.setGraphicSize(Std.int(poster.width * 1.6));
		poster.updateHitbox();
		add(poster);

		dialogue_box = new DialogueBox();
		dialogue_box.camera = camHUD;
		add(dialogue_box);

		super.create();

		FunkinSound.playMusic(Paths.music('201-street/menu_music'), 1);
		Conductor.bpm = 102;

		if (FlxG.save.data.overworldData != null && FlxG.save.data.overworldData.contains('GotEarbuds') == true)
		{
			overworldData = (FlxG.save.data.overworldData != []);
		}
		if (FlxG.save.data.songsBeaten != null)
		{
			beatenGame = (FlxG.save.data.songsBeaten.contains('bill-cipher'));
		}

		if (firstLoad)
		{
			black_screen = new FlxSprite().makeGraphic(1300, 800, FlxColor.BLACK);
			black_screen.camera = camHUD;
			add(black_screen);

			hopscotch_logo = new FlxSprite().loadGraphic(Paths.image('title/hopscotch_logo'));
			hopscotch_logo.antialiasing = ClientPrefs.globalAntialiasing;
			hopscotch_logo.screenCenter();
			hopscotch_logo.camera = camHUD;
			hopscotch_logo.alpha = 0;
			add(hopscotch_logo);
			hopscotch_logo.scale.set(0.4, 0.4);

			transitioning = true;

			new FlxTimer().start(2, function(tmr:FlxTimer) {
				FlxTween.tween(hopscotch_logo, {alpha: 1}, 0.4, {ease: FlxEase.quadInOut});
				FlxTween.tween(hopscotch_logo.scale, {x: 0.6, y: 0.6}, 4, {ease: FlxEase.quadInOut});
				new FlxTimer().start(3, function(tmr:FlxTimer) {
					FlxTween.tween(hopscotch_logo, {alpha: 0}, 0.7, {ease: FlxEase.quadInOut});
					new FlxTimer().start(2, function(tmr:FlxTimer) {
						FlxTween.tween(black_screen, {alpha: 0}, 0.7,
							{
								ease: FlxEase.quadInOut,
								onComplete: function(t:FlxTween) {
									firstLoad = false;
									menuTransition(isTitle);
								}
							});
					});
				});
			});
		}
		else
		{
			FlxG.camera.fade(FlxColor.BLACK, 2, true);
			menuTransition(isTitle);
		}
	}

	var totalElapsed:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		totalElapsed += elapsed;
		cloudShader.setFloat('iTime', totalElapsed);

		clouds.x -= elapsed * 5;
		fog.x -= elapsed * 5;

		final pressedEnter:Bool = FlxG.gamepads.lastActive?.justPressed.START
			|| FlxG.keys.justPressed.ENTER
			|| controls.ACCEPT
			|| FlxG.mouse.justPressed;

		#if debug
		if (FlxG.keys.justPressed.F) FlxG.switchState(FreeplayState.new);
		#end

		if (!transitioning)
		{
			if (isTitle)
			{
				if (pressedEnter && !startTween.active)
				{
					menuTransition(false);
				}
			}
			else
			{
				if (diffGrp != null)
				{
					if (isNewGame)
					{
						if (controls.UI_LEFT_P || controls.NOTE_LEFT_P)
						{
							curSelectedDiff = 0;
						}
						if (controls.UI_RIGHT_P || controls.NOTE_RIGHT_P)
						{
							curSelectedDiff = 1;
						}
						for (i in diffGrp.members)
						{
							if (FlxG.mouse.deltaX + FlxG.mouse.deltaY != 0)
							{
								if (FlxG.mouse.overlaps(i))
								{
									curSelectedDiff = i.ID;
								}
							}

							i.alpha = i.ID == curSelectedDiff ? 1 : 0.5;
						}

						if (FlxG.mouse.justPressed || controls.ACCEPT)
						{
							isNewGame = false;
							FlxTween.tween(camFollow, {y: 0 - FlxG.height / 2}, 3, {ease: FlxEase.quadInOut});

							Highscore.clearSongSaveData();
							FlxG.save.data.story_difficulty = curSelectedDiff;
							FlxG.save.flush();

							new FlxTimer().start(4, function(tmr:FlxTimer) {
								dialogue_box.loadDialogue('intro_dialogue', true);
							});
						}

						if (FlxG.mouse.overlaps(diffGrp) && isNewGame)
						{
							FlxG.mouse.load(Paths.image("overworld/ui/cursor/click").bitmap, 0.325);
						}
						else
						{
							FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursor").bitmap, 0.325);
						}

						if (controls.BACK)
						{
							isNewGame = false;
							FlxTween.cancelTweensOf(diffsBG);
							FlxTween.tween(diffsBG, {y: 720}, 1.0,
								{
									ease: FlxEase.smootherStepOut,
									onComplete: function(t:FlxTween) {
										canClick = true;
									}
								});

							if (optionGrp != null)
							{
								for (opt in optionGrp.members)
									opt.alpha = 0.5;
							}
						}
					}
				}

				if (optionGrp != null)
				{
					if (canClick && !isNewGame)
					{
						if (controls.UI_DOWN_P || controls.NOTE_DOWN_P)
						{
							curSelected++;
							// having a bunch of if statements like this feels odd but its fine, what we get for adding keyboard controls to a menu designed with the mouse in mind
							if (curSelected > optionGrp.members.length - 1) curSelected = 0;
							if (curSelected == 1 && !overworldData) curSelected = 2;
							if (curSelected == 2 && !beatenGame) curSelected = 3;
						}
						if (controls.UI_UP_P || controls.NOTE_UP_P)
						{
							curSelected--;
							if (0 > curSelected) curSelected = optionGrp.members.length - 1;
							if (curSelected == 2 && !beatenGame) curSelected = 1;
							if (curSelected == 1 && !overworldData) curSelected = 0;
						}

						for (i in optionGrp.members)
						{
							if (FlxG.mouse.deltaX + FlxG.mouse.deltaY != 0)
							{
								if (FlxG.mouse.overlaps(optionGrp))
								{
									if (FlxG.mouse.overlaps(i))
									{
										curSelected = i.ID;
									}
								}
								else
								{
									curSelected = -1;
								}
							}

							if (i.ID != curSelected)
							{
								i.alpha = 0.5;
								if (i.ID == 1 && !overworldData) i.alpha = 0.25;
								if (i.ID == 2 && !beatenGame) i.alpha = 0.25;
								if (FlxG.mouse.overlaps(i) && FlxG.mouse.justPressed)
								{
									curSelected = i.ID;
								}
							}

							if (i.ID == curSelected)
							{
								switch (i.ID)
								{
									case 1:
										curSelected = overworldData ? i.ID : -1;
									case 2:
										curSelected = beatenGame ? i.ID : -1;
									default:
										curSelected = i.ID;
								}

								if (i.ID == curSelected)
								{
									i.alpha = 1;
									if (FlxG.mouse.overlaps(i)) FlxG.mouse.load(Paths.image("overworld/ui/cursor/click").bitmap, 0.325);

									if ((FlxG.mouse.justPressed || controls.ACCEPT))
									{
										FlxG.mouse.load(Paths.image("overworld/ui/cursor/click").bitmap, 0.325);
										selectOption(curSelected);
									}
								}
							}
						}

						if (FlxG.mouse.overlaps(optionGrp) != true)
						{
							FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursor").bitmap, 0.325);
						}

						if (controls.BACK)
						{
							menuTransition(true);
						}
					}
				}
			}

			if (diffGrp != null)
			{
				for (i in diffGrp.members)
				{
					switch (i.ID)
					{
						case 0:
							i.y = diffsBG.y + 183;
						case 1:
							i.y = diffsBG.y + 177;
					}
				}
			}
		}

		if (poster != null)
		{
			if (poster.alpha == 1)
			{
				if (controls.ACCEPT || FlxG.mouse.justPressed || FlxG.keys.justPressed.ENTER)
				{
					FlxTween.tween(poster, {alpha: 0, y: poster.y + 30}, 0.5, {ease: FlxEase.quartOut});
					dialogue_box.loadDialogue('intro_dialogue_cont', true);
				}
			}
		}

		super.update(elapsed);
	}

	function menuTransition(isTitleScreen:Bool = false)
	{
		var transTime:Float = 0;

		if (isTitleScreen)
		{
			trace('true');
			isTitle = true;
			canClick = false;
			FlxG.mouse.visible = false;
			FlxTween.tween(logo, {alpha: 1}, 1, {startDelay: 0.5});
			startTween = FlxTween.tween(pressStart, {alpha: 1}, 1, {startDelay: 1.25});
			FlxTween.tween(optionsBG, {y: 720}, 1.25, {ease: FlxEase.smootherStepOut});
			for (i in optionGrp.members)
			{
				FlxTween.tween(i, {alpha: 0}, 0.1);
			}
			transTime = 1.5;
		}
		else
		{
			trace('false');
			isTitle = false;
			transTime = 1.9;
			FlxTween.tween(logo, {alpha: 0}, 0.5);
			FlxTween.tween(pressStart, {alpha: 0}, 0.5);
			FlxTween.tween(optionsBG, {y: 121}, 1.5, {ease: FlxEase.smootherStepOut, startDelay: 0.5});
		}

		transitioning = true;

		transitionTimer = FlxTimer.wait(transTime, () -> {
			transitioning = false;
			if (isTitleScreen)
			{
				//
			}
			else
			{
				FlxTween.tween(versionText, {x: 0}, 1.5, {ease: FlxEase.smootherStepOut});
				for (i in optionGrp.members)
				{
					FlxTween.tween(i, {alpha: 0.5}, 0.25,
						{
							startDelay: i.ID * 0.2,
							onComplete: function(tween:FlxTween) {
								if (i.ID == optionGrp.members.length - 1)
								{
									canClick = true;
									FlxG.mouse.visible = true;
								}
							}
						});
				}
			}
		});
	}

	function selectOption(id:Int)
	{
		canClick = false;
		switch (options[id])
		{
			case 'newgame': // liz will handle this one //yerps, i am!
				canClick = false;
				isNewGame = true;
				FlxTween.cancelTweensOf(diffsBG);
				FlxTween.tween(diffsBG, {y: 450}, 1.0, {ease: FlxEase.smootherStepOut});
			case 'continue':
				FlxG.sound.music.fadeOut(0.35);
				if (OverworldState.map_name == 'main_street_day') OverworldState.map_name = 'main_street';
				camHUD.fade(FlxColor.BLACK, 0.4, false, function() {
					FlxG.switchState(OverworldState.new);
				});
			case 'credits':
				FlxG.switchState(CreditsState.new);
			case 'options':
				camHUD.fade(FlxColor.BLACK, 0.4, false, function() {
					FlxG.switchState(funkin.states.options.OptionsState.new);
				});
				OptionsState.onPhone = false;
				OptionsState.onPlayState = false;
		}
	}

	var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

	override function beatHit()
	{
		super.beatHit();
	}

	function newShader(?fragFile:String, ?vertFile:String)
	{ // Surely this should just be in a util or something right
		var fragPath = fragFile != null ? Paths.fragment(fragFile) : null;
		var vertPath = vertFile != null ? Paths.vertex(vertFile) : null;

		if (fragPath != null)
		{
			if (FunkinAssets.exists(fragPath)) fragPath = FunkinAssets.getContent(fragPath);
		}

		if (vertPath != null)
		{
			if (FunkinAssets.exists(vertPath)) vertPath = FunkinAssets.getContent(vertPath);
		}

		return new funkin.backend.FunkinShader.FunkinRuntimeShader(fragPath, vertPath);
	}

	public function loadOverworld()
	{
		FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
			OverworldState.curCutscene = 'pre_overworld';
			OverworldState.map_name = 'billies_house';
			FlxG.switchState(OverworldState.new);
		});
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}

	public function runEvent(eventName:String)
	{
		switch (eventName)
		{
			case 'poster':
				FlxTween.tween(poster, {alpha: 1, y: poster.y - 30}, 0.5, {ease: FlxEase.quartOut});
		}
	}
}
