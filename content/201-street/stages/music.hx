import funkin.game.shaders.DropShadowShader;
import funkin.objects.stageobjects.ABotVis;
import openfl.filters.ShaderFilter;
import funkin.game.huds.DHMISHUD;

var curCharacterSinging:String = '';
var frankie_y:Float;

function onLoad()
{
	void = new FlxSprite(-300, -700).makeGraphic(2000, 2000, FlxColor.BLACK);
	void.scrollFactor.set(0.5, 0.5);
	// void.blend = BlendMode.ADD;
	add(void);

	void_overlay = new FlxSprite(-300, -700).makeGraphic(2000, 2000, FlxColor.BLACK);
	void_overlay.scrollFactor.set(0.5, 0.5);
	// void.blend = BlendMode.ADD;
	void_overlay.alpha = 0.7;
	add(void_overlay);

	curCharacterSinging = 'yellow';
	bg = new FlxSprite(0, -30).loadGraphic(Paths.image('backgrounds/music/BGNIGHT'));
	bg.loadGraphic(Paths.image('backgrounds/music/bg'));
	bg.scale.set(1.3, 1.3);
	add(bg);

	cloudsky = new FlxSprite(0, -30).loadGraphic(Paths.image('backgrounds/music/1'));
	cloudsky.scale.set(1.3, 1.3);
	cloudsky.scrollFactor.set(0.1, 1);
	cloudsky.visible = false;
	add(cloudsky);

	backdrop = new FlxSprite(0, -30).loadGraphic(Paths.image('backgrounds/music/2'));
	backdrop.scale.set(1.3, 1.3);
	backdrop.scrollFactor.set(0.25, 1);
	backdrop.visible = false;
	add(backdrop);

	clouds = new FlxSprite(0, -30).loadGraphic(Paths.image('backgrounds/music/3'));
	clouds.scale.set(1.3, 1.3);
	clouds.scrollFactor.set(0.8, 1);
	clouds.visible = false;
	add(clouds);

	scaryBG = new FlxSprite(-500, -220).loadGraphic(Paths.image('backgrounds/music/EVIL bg'));
	scaryBG.scale.set(3, 1.1);
	scaryBG.visible = false;
	add(scaryBG);

	speaker = new FlxSprite(350, 480);
	speaker.frames = Paths.getSparrowAtlas('backgrounds/music/Speaker');
	speaker.animation.addByPrefix('idle', 'SpeakerIdle', 24, false);
	speaker.animation.play('idle');
	add(speaker);

	oats = new FlxSprite(1225, 800).loadGraphic(Paths.image('backgrounds/music/oats'));
	oats.scale.set(1.05, 1.05);
	oats.angle = -120;
	add(oats);

	chuds = new FlxSprite(oats.x - 100, oats.y + 200).loadGraphic(Paths.image('backgrounds/music/chuds'));
	chuds.scale.set(oats.scale.x, oats.scale.y);
	chuds.angle = -125;
	add(chuds);

	apple = new FlxSprite(oats.x - 70, oats.y - 70).loadGraphic(Paths.image('backgrounds/music/apple'));
	apple.scale.set(oats.scale.x, oats.scale.y);
	apple.angle = -100;
	add(apple);

	kick = new FlxSprite(250, 160).loadGraphic(Paths.image('backgrounds/music/kick'));
	add(kick);
	hat = new FlxSprite(570, -100).loadGraphic(Paths.image('backgrounds/music/hat'));
	add(hat);
	snare = new FlxSprite(930, 160).loadGraphic(Paths.image('backgrounds/music/snare'));
	add(snare);
	kick.visible = hat.visible = snare.visible = false;

	skipCountdown = true;

	ending_cutscene = new FunkinVideoSprite();
	ending_cutscene.onFormat(() -> {
		ending_cutscene.setGraphicSize(0, FlxG.height);
		ending_cutscene.updateHitbox();
		ending_cutscene.screenCenter();
		ending_cutscene.cameras = [camHUD];
	});
	ending_cutscene.onEnd(() -> {
		endSong();
	});
	ending_cutscene.load(Paths.video('DHMIS_Ending_Cutscene'), []);
	add(ending_cutscene);
	ending_cutscene.visible = false;
	ending_cutscene.tiedToGame = false;

	songStartCallback = dhmis_intro;

	if (isStoryMode) songEndCallback = cutscene_ending;
}

var vibe = newShader('vibe');
var void_shader = newShader('void');

function onCreatePost()
{
	playHUD.kill();
	playHUD = new DHMISHUD(PlayState.instance);
	playHUD.cameras = [camHUD];
	insert(members.indexOf(playFields), playHUD);

	frankie_y = dadGroup.y;

	scaryEndingSequence = false;
	gf.visible = false;

	// isCameraOnForcedPos = true;
	camFollow.setPosition(800, 300);
	FlxG.camera.snapToTarget();

	boyfriend.x += 770;
	boyfriend.y -= 160;

	red_guy = new Character(-80, -105, 'red_guy');
	startCharacterPos(red_guy);
	add(red_guy);

	duck = new Character(770, 150, 'duck');
	startCharacterPos(duck);
	insert(20, duck);

	foreground_clouds = new FlxSprite(0, -30).loadGraphic(Paths.image('backgrounds/music/4'));
	foreground_clouds.scale.set(1.3, 1.3);
	foreground_clouds.scrollFactor.set(1.15, 1);
	foreground_clouds.visible = false;
	insert(21, foreground_clouds);

	red_guy_ending = new Character(-80, -105, 'red_guy_ending');
	startCharacterPos(red_guy_ending);
	red_guy_ending.visible = false;
	insert(20, red_guy_ending);

	duck_ending = new Character(770, 150, 'duck_ending');
	startCharacterPos(duck_ending);
	duck_ending.visible = false;
	insert(20, duck_ending);

	yellow_guy_ending = new Character(770, 150, 'yellow_guy_ending');
	startCharacterPos(yellow_guy_ending);
	yellow_guy_ending.visible = false;
	insert(20, yellow_guy_ending);

	camHUD.alpha = 0;

	void.shader = void_shader;

	lighting = newShader('adjustColor');
	lighting.setFloat('hue', -5);
	lighting.setFloat('brightness', -3);
	lighting.setFloat('contrast', 10);
	lighting.setFloat('saturation', -25);

	camGame.filters = [new ShaderFilter(lighting)];

	cutscene_video = new FunkinVideoSprite();
	cutscene_video.onFormat(() -> {
		cutscene_video.setGraphicSize(0, FlxG.height);
		cutscene_video.updateHitbox();
		cutscene_video.screenCenter();
		cutscene_video.cameras = [camHUD];
	});
	cutscene_video.onEnd(() -> {
		onEvent("DHMIS Events", "final", "");
	});
	cutscene_video.load(Paths.video('music_for_your_ears_cutscene'), [FunkinVideoSprite.muted]);
	add(cutscene_video);
	cutscene_video.tiedToGame = false;
	// cutscene_video.visible = false;

	genres = new FlxSprite().loadGraphic(Paths.image('backgrounds/music/happy'));
	for (item in ['funky', 'computer', 'happy', 'ego', 'guilt', 'mixing'])
		genres.loadGraphic(Paths.image('backgrounds/music/' + item));
	genres.visible = false;
	genres.cameras = [camHUD];
	add(genres);

	logo = new FlxSprite().loadGraphic(Paths.image('backgrounds/music/logo'));
	logo.cameras = [camOther];
	logo.screenCenter();
	logo.alpha = 0;
	add(logo);

	fabric = new FlxSprite(150, -70).loadGraphic(Paths.image('backgrounds/music/fabric'));
	fabric.setGraphicSize(1700);
	fabric.blend = BlendMode.MULTIPLY;
	fabric.alpha = 0.5;
	fabric.scrollFactor.set(0, 0);
	insert(200, fabric);

	remove(gfGroup);
	insert(999, gfGroup);
}

function onMoveCamera(char)
{
	if (isCameraOnForcedPos) return;
	switch (char)
	{
		case 'dad':
			defaultCamZoom = 0.83;
			camFollow.setPosition(800, 300);

		default:
			defaultCamZoom = 0.8;
			camFollow.setPosition(curCharacterSinging == 'red' ? 730 : 870, 300);
	}
}

function onBeatHit()
{
	speaker.animation.play('idle', true);
	dadGroup.y += 4;
	FlxTween.cancelTweensOf(dadGroup);
	FlxTween.tween(dadGroup, {y: frankie_y}, 0.75, {ease: FlxEase.circOut});

	for (char in [red_guy, duck])
	{
		if (curBeat % char.danceEveryNumBeats == 0 && char.animation.curAnim.name == 'idle')
		{
			char.dance();
		}
	}

	if (scaryEndingSequence)
	{
		FlxTween.cancelTweensOf(scaryBG);
		scaryBG.alpha = 1;
		FlxTween.tween(scaryBG, {alpha: 0.5}, 0.75, {startDelay: 0.15});

		camGame.shake(0.01, 0.005);
		camGame.zoom += 0.15;
		camHUD.zoom += 0.055;
	}
}

function extraNoteHitPre(note)
{
	note.owner = boyfriend;
}

function onEvent(eventName, value1, value2)
{
	switch (eventName)
	{
		case 'DHMIS Characters':
			curCharacterSinging = value1.toLowerCase();
			switch (value1.toLowerCase())
			{
				case 'red':
					playerStrums.owner = scaryEndingSequence ? red_guy_ending : red_guy;

				case 'yellow':
					playerStrums.owner = scaryEndingSequence ? yellow_guy_ending : boyfriend;

				case 'duck':
					playerStrums.owner = scaryEndingSequence ? duck_ending : duck;
			}

		case 'DHMIS Events':
			switch (value1.toLowerCase())
			{
				// case 'logo': logo.visible = false;
				case 'oats':
					for (item in [oats, apple, chuds])
					{
						FlxTween.tween(item, {y: item.y - 1750, angle: item.angle + 160}, FlxG.random.float(5.2, 6.1));
					}

				case 'sky':
					camGame.visible = false;
					new FlxTimer().start(0.2, function(tmr:FlxTimer) {
						camGame.visible = true;
						FlxG.camera.flash(FlxColor.BLACK, 2);
					});
					FlxTween.cancelTweensOf(dadGroup);
					dadGroup.y = frankie_y = -300;
					bg.alpha = 0;

					for (item in [backdrop, clouds, cloudsky, foreground_clouds])
						item.visible = true;

				case 'normal':
					FlxG.camera.flash(FlxColor.BLACK, 1.25);
					FlxTween.tween(bg, {alpha: 1}, 1.3);
					FlxTween.cancelTweensOf(dadGroup);
					dadGroup.y = frankie_y = -201;
					for (item in [backdrop, clouds, cloudsky, foreground_clouds])
						item.visible = false;

					for (item in [boyfriend, duck, red_guy])
					{
						item.shader = null;
					}

					for (item in dadGroup.members)
					{
						item.shader = null;
					}

				case 'kick':
					kick.visible = true;
					kick.angle -= 3;
					FlxTween.tween(kick, {angle: 0}, 0.2);

				case 'hat':
					hat.visible = true;
					hat.scale.set(1.15, 0.95);
					FlxTween.tween(hat.scale, {x: 1, y: 1}, 0.2);

				case 'snare':
					snare.visible = true;
					snare.angle += 3;
					FlxTween.tween(snare, {angle: 0}, 0.2);

				case 'whatever else':
					kick.visible = hat.visible = snare.visible = false;

				case 'genres':
					if (value2 == '')
					{
						genres.visible = false;
					}
					else
					{
						genres.visible = true;
						genres.loadGraphic(Paths.image('backgrounds/music/' + value2));
						genres.screenCenter();
					}

				case 'angrier':
					defaultCamZoom += 0.1;
					camGame.zoom = defaultCamZoom;
					camFollow.y += 5;
					camFollow.x = 800;
					FlxG.camera.snapToTarget();
					isCameraOnForcedPos = true;

				case 'zoom in during angry':
					FlxTween.tween(camFollow, {y: camFollow.y + 10}, 2.4);
					FlxTween.tween(game, {defaultCamZoom: defaultCamZoom + 0.25}, 2.4);

				case 'space':
					camGame.visible = false;
					new FlxTimer().start(0.5, function(tmr:FlxTimer) {
						camGame.visible = true;
						FlxG.camera.flash(FlxColor.BLACK, 3);
					});
					FlxTween.cancelTweensOf(dadGroup);
					dadGroup.y = frankie_y = -299;
					bg.alpha = 0;
					isCameraOnForcedPos = false;

					for (item in dadGroup.members)
					{
						var frankieRim = new DropShadowShader();
						frankieRim.setAdjustColor(-25, -38, -25, -20);
						frankieRim.color = 0xFFFFFF;
						frankieRim.angle = 90;
						item.shader = frankieRim;
						frankieRim.attachedSprite = item;
						item.animation.onFrameChange.add(function() {
							frankieRim.updateFrameInfo(item.frame);
						});

						if (item != dad)
						{
							frankieRim.threshold = 1;
						}
					}

					var speakerRim = new DropShadowShader();
					speakerRim.setAdjustColor(-25, -38, -25, -20);
					speakerRim.color = 0xFFFFFF;
					speakerRim.angle = 90;
					speaker.shader = speakerRim;
					speakerRim.attachedSprite = speaker;
					speaker.animation.onFrameChange.add(function() {
						speakerRim.updateFrameInfo(speaker.frame);
					});

					for (item in [boyfriend, duck, red_guy])
					{
						var characterRim = new DropShadowShader();
						// characterRim.setAdjustColor(-46, -38, -25, -20);
						characterRim.setAdjustColor(-25, -38, -25, -20);
						characterRim.color = 0x00FFFFFF;
						characterRim.threshold = 0.3;
						item.shader = characterRim;
						characterRim.attachedSprite = item;
						item.animation.onFrameChange.add(function() {
							characterRim.updateFrameInfo(item.frame);
						});
						switch (item)
						{
							case boyfriend:
								characterRim.angle = 140;
							case duck:
								characterRim.angle = 105;
							case red_guy:
								characterRim.threshold = 0.15;
								characterRim.angle = 60;
						}
					}

				case 'fadeout':
					FlxG.camera.fade(FlxColor.BLACK, 0.3, false);

				case 'video':
					for(item in [scoreTxt, iconP1, iconP2, healthBar, playHUD.ratingGraphic])
						item.alpha = 0;

					for(num in playHUD.ratingNumGroup.members) num.alpha = 0;
					camHUD.alpha = 1;
					cutscene_video.play();
					cutscene_video.visible = true;
					cutscene_video.tiedToGame = true;
					playHUD.showRating = false;
					playHUD.showRatingNum = false;

				case 'final':
					speaker.visible = false;
					FlxG.camera.fade(FlxColor.BLACK, 0.01, true);
					fabric.visible = false;
					opponentStrums.owner = gf;
					scaryEndingSequence = true;
					dadGroup.visible = false;
					gf.visible = true;
					void.visible = false;
					void_overlay.visible = false;
					defaultCamZoom = 0.97;
					camGame.zoom = defaultCamZoom;
					isCameraOnForcedPos = true;
					camFollow.setPosition(820, 215);
					FlxG.camera.snapToTarget();
					scaryBG.visible = true;
					camGame.filters = [];
					cutscene_video.visible = false;

					for (item in [boyfriend, duck, red_guy, yellow_guy_ending, duck_ending, red_guy_ending])
						item.visible = !item.visible;
					for (item in [yellow_guy_ending, duck_ending, red_guy_ending])
						item.y += 800;

					onEvent("DHMIS Characters", curCharacterSinging, "");

				case 'add char heads':
					var headToMove:Character;
					switch (value2.toLowerCase())
					{
						case 'red':
							headToMove = red_guy_ending;

						case 'yellow':
							headToMove = yellow_guy_ending;

						case 'duck':
							headToMove = duck_ending;
					}

					FlxTween.tween(headToMove, {y: headToMove.y - 800}, 2, {ease: FlxEase.quartOut});

				case 'ending':
					scaryEndingSequence = false;
					for (item in [boyfriend, duck, red_guy, yellow_guy_ending, duck_ending, red_guy_ending])
						item.visible = !item.visible;
					camGame.filters = [new ShaderFilter(lighting)];
					onEvent("DHMIS Events", "normal", "");
					scaryBG.visible = false;
					gf.visible = false;
					fabric.visible = true;
					scoreTxt.alpha = 1;
					bg.loadGraphic(Paths.image('backgrounds/music/BGNIGHT'));

					defaultCamZoom = 0.78;
					camGame.zoom = defaultCamZoom + 0.3;
					camFollow.setPosition(800, 285);
					FlxG.camera.snapToTarget();

					for (item in [boyfriend, duck, red_guy])
					{
						item.idleSuffix = "-alt";
						item.recalculateDanceIdle();
					}

				case 'gone':
					modManager.setValue("alpha", 1, 0);
					camGame.visible = false;
					playHUD.visible = false;
					opponentStrums.visible = false;
					playerStrums.visible = false;
			}
	}
}

function onEndSong()
{
	if (isStoryMode) OverworldState.curCutscene = 'dhmis_exit';
}

var totalElapsed:Float = 0;

function onUpdate(elapsed)
{
	totalElapsed += elapsed;
	void_shader.setFloat('iTime', totalElapsed);

	speaker.y = frankie_y + speaker.height + 270;
}

function onUpdatePost(elapsed){
	camOther.zoom = camHUD.zoom;
}

function goodNoteHit(note)
{
	switch (curCharacterSinging)
	{
		case 'yellow':
			iconP1.changeIcon(boyfriend.healthIcon);
		case 'duck':
			iconP1.changeIcon(duck.healthIcon);
		case 'red':
			iconP1.changeIcon(red_guy.healthIcon);
	}
	healthBar.setColors(dad.healthColour, playerStrums.owner.healthColour);
}

function dhmis_intro(){
	camGame.visible = false;
	FlxTimer.wait(0.23, () -> {
		logo.alpha = 1;

		// defaultCamZoom = 0.83;
		// camFollow.setPosition(800, 300);

		FlxG.sound.play(Paths.sound('dhmis_jingle'), 0.7);
		FlxTimer.wait(2, () -> {
			FlxG.camera.flash(FlxColor.BLACK, 2.5);
			camGame.visible = true;
			
			FlxTween.tween(camFollow, {x: 800, y: 300}, 1.5);
			FlxTween.tween(camGame, {zoom: 0.8}, 3.5, {ease: FlxEase.quadOut, onComplete: function(t:FlxTween){
				isCameraOnForcedPos = false;
			}});
		});

		FlxG.camera.zoom = 1.4;
		camFollow.setPosition(800, 100);
		FlxG.camera.snapToTarget();
		isCameraOnForcedPos = true;

		FlxTimer.wait(4, () -> {
			FlxTween.tween(logo, {alpha: 0}, 2.5, {ease: FlxEase.quadInOut});
			startCountdown();
		});
	});
}

function onCountdownStarted()
{
	ending_cutscene.play();
	ending_cutscene.pause();

	modManager.setValue("transform0X", -125, 0);
	modManager.setValue("transform1X", -100, 0);
	modManager.setValue("transform2X", 100, 0);
	modManager.setValue("transform3X", 125, 0);
	modManager.setValue("alpha", 1, 0);
	modManager.setValue("alpha", 1, 1);
	modManager.setValue("alpha", 1, 2);
	modManager.setValue("opponentSwap", 0.5);
	modManager.queueEase(48, 70, "alpha", 0, FlxEase.expoInOut, 0);
	modManager.queueEase(684, 688, "alpha", 1, FlxEase.expoInOut, 0);
	modManager.queueEase(944, 960, "alpha", 0, FlxEase.expoInOut, 0);

	modManager.queueFuncOnce(48, (s, s2) -> { FlxTween.tween(camHUD, {alpha: 1}, 3, {ease: FlxEase.expoInOut}); });
	modManager.queueFuncOnce(684, (s, s2) -> { FlxTween.tween(camHUD, {alpha: 0}, 0.4, {ease: FlxEase.expoInOut}); });
}
	

function cutscene_ending()
{
	camGame.visible = false;
	canPause = false;
	endingSong = true;
	camZooming = false;
	inCutscene = false;
	updateTime = false;

	ending_cutscene.visible = true;
	ending_cutscene.play();
	ending_cutscene.tiedToGame = true;
}
