var adjustColorPlayer:FlxShader;
var adjustColorOpp:FlxShader;
var introVid:FunkinVideoSprite;
var blackScreen:FlxSprite;

// monster bg
var monsterSky:FlxSprite;
var bgtrees:FlxSprite;
var floor:FlxSprite;
var thosetwo:FlxSprite;
var treeright:FlxSprite;
var treeleft:FlxSprite;
var bushfg:FlxSprite;
var multiply:FlxSprite;
var monsterBG:Array<FlxSprite> = [];

// cecilia bg
var week2BG:FlxSprite;

// mandy bg
var limoSunset:FlxSprite;
var limo:FlxSprite;
var week4BG:Array<FlxSprite> = [];

// enrique bg
var week7sky:FlxSprite;
var mountains:FlxSprite;
var furthertrees:FlxSprite;
var forest:FlxSprite;
var ground:FlxSprite;
var week7BG:Array<FlxSprite> = [];

// LIST OF SHIT TO IMPLEMENT PLEASE HELP ME
// - Tons of camera events :sob: (In progress)
// - Subtitles

function onLoad()
{
	// Monster BG

	monsterSky = new FlxSprite(-697, -670).makeGraphic(2617, 1576, FlxColor.fromRGB(16, 13, 23));
	monsterSky.updateHitbox();
	monsterSky.zIndex = -2;
	add(monsterSky);

	bgtrees = new FlxSprite(-976, -819).loadGraphic(Paths.image("backgrounds/citrus-sacrement/trees"));
	bgtrees.scrollFactor.set(0.9, 0.9);
	bgtrees.zIndex = -2;
	add(bgtrees);

	floor = new FlxSprite(-833, 0).loadGraphic(Paths.image("backgrounds/citrus-sacrement/floor"));
	floor.zIndex = -1;
	add(floor);

	thosetwo = new FlxSprite(456, 197);
	thosetwo.frames = Paths.getSparrowAtlas("backgrounds/citrus-sacrement/them");
	thosetwo.animation.addByPrefix('normal', 'normal0', 24, true);
	thosetwo.animation.addByPrefix('corruption', 'corrupted0', 24, true);
	thosetwo.animation.play('normal');
	thosetwo.zIndex = -1;
	thosetwo.visible = false;
	add(thosetwo);

	rock = new FlxSprite(673, 483).loadGraphic(Paths.image("backgrounds/citrus-sacrement/rock"));
	rock.zIndex = 0;
	add(rock);

	treeright = new FlxSprite(1480, -786).loadGraphic(Paths.image("backgrounds/citrus-sacrement/treefg"));
	treeright.scrollFactor.set(1.1, 1.1);
	treeright.zIndex = 1;
	add(treeright);

	treeleft = new FlxSprite(-1029, -721).loadGraphic(Paths.image("backgrounds/citrus-sacrement/treefg"));
	treeleft.flipX = true;
	treeleft.scrollFactor.set(1.1, 1.1);
	treeleft.zIndex = 1;
	add(treeleft);

	bushfg = new FlxSprite(-1006, 352).loadGraphic(Paths.image("backgrounds/citrus-sacrement/bushfg"));
	bushfg.scrollFactor.set(1.2, 1.2);
	bushfg.zIndex = 1;
	add(bushfg);

	multiply = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/citrus-sacrement/multiply"));
	multiply.blend = 9;
	multiply.zIndex = 2;
	multiply.screenCenter();
	multiply.visible = false;
	multiply.scrollFactor.set(0, 0);
	add(multiply);

	monsterBG = [
		monsterSky,
		bgtrees,
		floor,
		thosetwo,
		rock,
		treeright,
		treeleft,
		bushfg,
		multiply
	];

	// Week 2 BG (Cecilia)

	week2BG = new FlxSprite(-1093, -618).loadGraphic(Paths.image("backgrounds/citrus-sacrement/week2/halloween_bg"));
	week2BG.zIndex = 0;
	week2BG.visible = false;
	add(week2BG);

	// Week 4 BG (Mandy)

	limoSunset = new FlxSprite(-400, -285).loadGraphic(Paths.image("backgrounds/citrus-sacrement/week4/sky"));
	limoSunset.zIndex = -1;
	limoSunset.scrollFactor.set(0.1, 0.1);
	limoSunset.visible = false;
	add(limoSunset);

	limo = new FlxSprite(-525, 425).loadGraphic(Paths.image("backgrounds/citrus-sacrement/week4/car"));
	limo.zIndex = 0;
	limo.visible = false;
	add(limo);

	week4BG = [limoSunset, limo];

	// Week 7 BG (Enrique)

	week7sky = new FlxSprite(-852, -805).loadGraphic(Paths.image("backgrounds/citrus-sacrement/week7/sky"));
	week7sky.zIndex = -1;
	week7sky.scrollFactor.set(0, 0);
	week7sky.visible = false;
	add(week7sky);

	mountains = new FlxSprite(-861, -459).loadGraphic(Paths.image("backgrounds/citrus-sacrement/week7/mountains"));
	mountains.zIndex = -1;
	mountains.scrollFactor.set(0.2, 0.2);
	mountains.visible = false;
	add(mountains);

	furthertrees = new FlxSprite(-675, 25).loadGraphic(Paths.image("backgrounds/citrus-sacrement/week7/bg destroyed buildings darker"));
	furthertrees.zIndex = -1;
	furthertrees.scrollFactor.set(0.5, 0.5);
	furthertrees.visible = false;
	add(furthertrees);

	forest = new FlxSprite(-765, -275).loadGraphic(Paths.image("backgrounds/citrus-sacrement/week7/city ruins"));
	forest.zIndex = -1;
	forest.scrollFactor.set(0.7, 0.7);
	forest.visible = false;
	add(forest);

	ground = new FlxSprite(-926, 255).loadGraphic(Paths.image("backgrounds/citrus-sacrement/week7/ground w gradient"));
	ground.zIndex = 0;
	ground.visible = false;
	add(ground);

	week7BG = [week7sky, mountains, furthertrees, forest, ground];

	blackScreen = new FlxSprite(0, 0).makeGraphic(1283, 720, FlxColor.BLACK);
	blackScreen.cameras = [camHUD];
	add(blackScreen);

	skipCountdown = true;
}

function onCreatePost()
{
	addCharacterToList('monster', 1);
	addCharacterToList('cecilia', 1);
	addCharacterToList('mandy', 1);
	addCharacterToList('enrique', 1);

	adjustColorPlayer = newShader('adjustColor');
	adjustColorPlayer.setFloat('hue', 11);
	adjustColorPlayer.setFloat('brightness', -3);
	adjustColorPlayer.setFloat('contrast', -16);
	adjustColorPlayer.setFloat('saturation', -46);

	adjustColorOpp = newShader('adjustColor');
	adjustColorOpp.setFloat('hue', 11);
	adjustColorOpp.setFloat('brightness', -3);
	adjustColorOpp.setFloat('contrast', -16);
	adjustColorOpp.setFloat('saturation', -46);

	boyfriend.shader = adjustColorPlayer;
	gf.shader = adjustColorPlayer;
	dad.shader = adjustColorOpp;

	game.snapCamToPos(710, 200, true);
	defaultCamZoom = 0.5;
	FlxG.camera.zoom = 0.5;

	gfGroup.zIndex = -1;

	introVid = new FunkinVideoSprite();
	introVid.onFormat(() -> {
		introVid.setGraphicSize(0, FlxG.height);
		introVid.updateHitbox();
		introVid.screenCenter();
		introVid.cameras = [camOther];
	});
	introVid.onEnd(() -> {
		triggerEventNote('Change Character', 'dad', 'monster');
		triggerEventNote('Camera Follow Pos', '', '');
		triggerEventNote('blackscreen', '0', '2,quadout');
		dad.shader = adjustColorOpp;
		gf.kill();
		thosetwo.visible = true;
		defaultCamZoom = 0.65;
	});
	introVid.load(Paths.video('monsterintro_final'), [FunkinVideoSprite.muted]);
	add(introVid);
	introVid.visible = false;

	playerStrums.members[0].alpha = 0;
	playerStrums.members[1].alpha = 0;
	playerStrums.members[2].alpha = 0;
	playerStrums.members[3].alpha = 0;

	opponentStrums.members[0].alpha = 0;
	opponentStrums.members[1].alpha = 0;
	opponentStrums.members[2].alpha = 0;
	opponentStrums.members[3].alpha = 0;

	playHUD.updateIconScale = false;

	// switchStage('week4'); // temp for testing
}

function onSongStart()
{
	// Desync prevention (at least as much as I can do)
	introVid.play();
	introVid.pause();
	introVid.tiedToGame = false;
}

function onEvent(name, v1, v2)
{
	switch (name)
	{
		case 'Monster Stage Switch':
			switchStage(v1);
		case 'blackscreen':
			var targetAlpha = Std.parseFloat(v1);
			var tween = v2.split(',');

			var time = Std.parseFloat(tween[0]);
			var easingMethod = CoolUtil.getEaseFromString(tween[1]);

			if (v2 == '')
			{
				blackScreen.alpha = targetAlpha;
			}
			else
			{
				FlxTween.tween(blackScreen, {alpha: targetAlpha}, time, {ease: easingMethod});
			}
		case 'Monster Events':
			switch (v1)
			{
				case 'intro':
					introVid.play();
					introVid.tiedToGame = true;
					blackScreen.alpha = 1;
					introVid.visible = true;
					playHUD.updateIconScale = true;
					modManager.setValue("alpha", 1, 1);
				case 'fakecountdown':
					var countdownNum:Int = -1;
					var countdownGraphic:FlxSprite = null;

					switch (Std.parseInt(v2))
					{
						case 3:
							playerStrums.fadeIn();
							opponentStrums.fadeIn();
						case 2:
							countdownNum = 2;
						case 1:
							countdownNum = 1;
					}

					if (countdownNum > -1) // i didn't think this 100% thru when coding it so heres a dumb bandaid fix for my terrible logic
					{
						countdownGraphic = makeFakeCountdownSprite(countdownNum);
						insert(members.indexOf(playFields), countdownGraphic);
					}
			}
	}
}

function switchStage(stage:String)
{
	var playerPos:Arrary<Float> = [0, 0];
	var playerColor:Arrary<Float> = [0, 0, 0, 0];
	var oppPos:Arrary<Float> = [0, 0];
	var oppColor:Arrary<Float> = [0, 0, 0, 0];

	var oldDad:Character = dad;

	for (i in monsterBG)
	{
		i.visible = stage == 'monster';
	}

	week2BG.visible = stage == 'week2';

	for (i in week4BG)
	{
		i.visible = stage == 'week4';
	}

	for (i in week7BG)
	{
		i.visible = stage == 'week7';
	}

	switch (stage) // stage settings (shader params, char pos, etc)
	{
		case 'monster':
			// For when it switches back to monster
			playerPos = [1140, -65];
			oppPos = [-100, -65];
			playerColor = [-3, 11, -16, -46];
			oppColor = [-3, 11, -16, -46];
			defaultCamZoom = 0.6;
			boyfriendCameraOffset[0] = -200;
			boyfriendCameraOffset[1] = 0;
			opponentCameraOffset[0] = 100;
			opponentCameraOffset[1] = 0;
			triggerEventNote('Change Character', 'dad', 'monster');
			thosetwo.animation.play('corruption');
		case 'week2':
			playerPos = [650, 40];
			oppPos = [-100, 55];
			playerColor = [-59, -16, -39, 4];
			oppColor = [-40, -10, -25, 6];
			// defaultCamZoom = 0.65;
			boyfriendCameraOffset[0] = 0;
			boyfriendCameraOffset[1] = 0;
			opponentCameraOffset[0] = 140;
			opponentCameraOffset[1] = -160;
			triggerEventNote('Change Character', 'dad', 'cecilia');
		case 'week4':
			playerPos = [1150, -25];
			oppPos = [0, -50];
			playerColor = [-22, 13, -6, 3];
			oppColor = [-22, 13, -6, 3];
			defaultCamZoom = 0.65;
			boyfriendCameraOffset[0] = -200;
			boyfriendCameraOffset[1] = 25;
			opponentCameraOffset[0] = 125;
			opponentCameraOffset[1] = -25;
			triggerEventNote('Change Character', 'dad', 'mandy');
		case 'week7':
			playerPos = [975, -60];
			oppPos = [25, -50];
			playerColor = [-9, 0, -18, -57];
			oppColor = [-9, 0, -18, -57];
			boyfriendCameraOffset[0] = -75;
			boyfriendCameraOffset[1] = 0;
			opponentCameraOffset[0] = 25;
			opponentCameraOffset[1] = 0;
			triggerEventNote('Change Character', 'dad', 'enrique');
	}

	if (oldDad != dad)
	{
		dad.shader = adjustColorOpp;
	}

	boyfriendGroup.x = playerPos[0];
	boyfriendGroup.y = playerPos[1];

	dadGroup.x = oppPos[0];
	dadGroup.y = oppPos[1];

	adjustColorPlayer.setFloat('brightness', playerColor[0]);
	adjustColorPlayer.setFloat('hue', playerColor[1]);
	adjustColorPlayer.setFloat('contrast', playerColor[2]);
	adjustColorPlayer.setFloat('saturation', playerColor[3]);

	adjustColorOpp.setFloat('brightness', oppColor[0]);
	adjustColorOpp.setFloat('hue', oppColor[1]);
	adjustColorOpp.setFloat('contrast', oppColor[2]);
	adjustColorOpp.setFloat('saturation', oppColor[3]);
}

// Copy of teh playstate func with a few minor changes idgaf rn

var countdownImages:Array<String> = ['go', 'set', 'ready'];

function makeFakeCountdownSprite(num:Int)
{
	var spr = new FlxSprite().loadGraphic(Paths.image(countdownImages[num]));
	spr.scrollFactor.set();
	spr.updateHitbox();
	spr.screenCenter();
	spr.antialiasing = ClientPrefs.globalAntialiasing;
	spr.cameras = [camHUD];

	FlxTween.tween(spr, {alpha: 0}, Conductor.crotchet / 1000 / playbackRate,
		{
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween) {
				remove(spr);
				spr.destroy();
			}
		});
	return spr;
}

function onEndSong()
{
	if (isStoryMode) OverworldState.curCutscene = 'monster_post';
}
