import openfl.filters.ShaderFilter;

var bg:FlxSprite;
var trees:FlxSprite;
var ground:FlxSprite;
var truck:FlxSprite;
var leggies:FlxSprite;
var ground_run:FlxSprite;
var blueMult:FlxSprite;
var goggles:FlxSprite;
var scramble:FlxSprite;
var egg:FlxSprite;
var grain = newShader('grain');
var chromaticWarp = newShader('chromaticWarp');
var rampUp:Float = 0;
var scrambling:Bool = false;
var goggleblink:Bool = false;
var gogglestate:Bool = true;
var onTruck:Bool = false;
var black:FlxSprite;
var dadAnchorPoint:Array<Float> = [0, 0];

function onLoad()
{
	bg = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/scp/bg"));
	add(bg);
	trees = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/scp/trees"));
	add(trees);
	ground = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/scp/ground"));
	add(ground);

	ground_run = new FlxSprite(0, 0);
	ground_run.frames = Paths.getSparrowAtlas("backgrounds/scp/096_bg");
	ground_run.animation.addByPrefix('idle', '096_bg loop', 12, true);
	ground_run.alpha = 0;

	leggies = new FlxSprite(245, 0);
	leggies.frames = Paths.getSparrowAtlas("backgrounds/scp/096_legs");
	leggies.animation.addByPrefix('idle', '096_legs idle', 12, true);
	leggies.scale.set(0.8, 0.8);
	leggies.alpha = 0;

	truck = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/scp/truck"));
	truck.scale.set(0.8, 0.8);
	truck.alpha = 0;

	add(ground_run);
	add(leggies);
	add(truck);
}

function onCreatePost()
{
	isCameraOnForcedPos = true;
	camFollow.setPosition(750, 500);
	FlxG.camera.snapToTarget();
	modManager.setValue("alpha", 1, 1);
	skipCountdown = true;

	dadAnchorPoint[0] = game.dad.x;
	dadAnchorPoint[1] = game.dad.y;

	blueMult = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/scp/bluemult"));
	blueMult.cameras = [game.camHUD];
	blueMult.alpha = 0.5;
	blueMult.blend = BlendMode.MULTIPLY;
	add(blueMult);

	// das shaders, was also on repo
	if (ClientPrefs.shaders)
	{
		chromaticWarp.setFloat('distortion', 0.25);
		grain.setFloat("multiplier", 0.5);
		camGame.filters = [new ShaderFilter(chromaticWarp)];
		FlxG.game.setFilters([new ShaderFilter(grain), new ShaderFilter(chromaticWarp)]);
	}

	goggles = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/scp/vig"));
	goggles.cameras = [game.camHUD];
	add(goggles);

	scramble = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/scp/vig_die"));
	scramble.cameras = [game.camOther];
	scramble.alpha = 0;
	scramble.scale.x = 1.1;
	add(scramble);

	egg = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/scp/vig_offline"));
	egg.cameras = [game.camOther];
	egg.alpha = 0;
	add(egg);

	black = new FlxSprite(0, 0).makeGraphic(1283, FlxG.height, FlxColor.BLACK);
	black.cameras = [game.camOther];
	black.alpha = 1;
	add(black);

	playHUD.comboOffsets[0] = -500;
	playHUD.ratingLines.x = 50;

	healthBar.alpha = 0;
	iconP1.alpha = 0;
	iconP2.alpha = 0;
	scoreTxt.alpha = 0;
	for (i in 0...game.playerStrums.members.length)
	{
		game.playerStrums.members[i].alpha = 0;
	}
	for (i in 0...game.opponentStrums.members.length)
	{
		game.opponentStrums.members[i].alpha = 0;
	}
}

function onSongStart()
{
	// w fade
	FlxTween.tween(black, {alpha: 0}, 15,
		{
			ease: FlxEase.expoInOut,
			onComplete: function(twn:FlxTween) {
				FlxTween.tween(healthBar, {alpha: 1}, 10);
				FlxTween.tween(iconP1, {alpha: 1}, 10);
				FlxTween.tween(iconP2, {alpha: 1}, 10);
				FlxTween.tween(scoreTxt, {alpha: 1}, 10);
				for (i in 0...game.playerStrums.members.length)
				{
					FlxTween.tween(game.playerStrums.members[i], {alpha: 1}, 10, {ease: FlxEase.linear});
				}
				for (i in 0...game.opponentStrums.members.length)
				{
					FlxTween.tween(game.opponentStrums.members[i], {alpha: 1}, 10, {ease: FlxEase.linear});
				}
			}
		});
}

var total_elapsed:Int = 0;
var legPosY = [-40, -35, -30, -30, -35, -40]; // ty vs impostor

function onUpdate(elapsed)
{
	total_elapsed += elapsed;
	grain.setFloat("iTime", total_elapsed);

	if (game.dad.curCharacter == '096_running') game.dad.y = dadAnchorPoint[1] + legPosY[leggies.animation.curAnim.curFrame] + -50;

	if (scrambling)
	{ // that abberation shit that looks cool
		if (rampUp <= 2.5)
		{
			rampUp += 0.01;
			chromaticWarp.setFloat('distortion', rampUp + 0.5);
			grain.setFloat("multiplier", rampUp + 0.5);
		}
	}

	if (goggleblink)
	{ // for scramble goggles
		if (gogglestate)
		{ // on
			new FlxTimer().start(1, () -> {
				egg.alpha = 1;
				gogglestate = false;
			});
		}
		else
		{ // off
			new FlxTimer().start(1, () -> {
				egg.alpha = 0;
				gogglestate = true;
			});
		}
	}
}

function onBeatHit()
{
	if (onTruck)
	{ // bumpy road
		FlxTween.tween(camFollow, {y: 485}, 0.2,
			{
				ease: FlxEase.expoInOut,
				onComplete: function(twn:FlxTween) {
					FlxTween.tween(camFollow, {y: 500}, 0.2, {ease: FlxEase.expoInOut});
				}
			});
	}
}

function onDestroy()
{
	FlxG.game.setFilters([]);
}

function onGameOverStart()
{
	FlxG.game.setFilters([]);
}

function onEvent(name, v1, v2)
{
	if (name == "Events")
	{
		switch (v1)
		{
			case "bad reception":
				chromaticWarp.setFloat('distortion', 0.5);
				grain.setFloat("multiplier", 1);
			case "gulp":
				scrambling = true;
			case "shits nuts":
				chromaticWarp.setFloat('distortion', 0);
				scrambling = false;
				FlxG.game.setFilters([]);
				goggles.alpha = 0;
				scramble.alpha = 1;
				goggleblink = true;
				playHUD.healthBarFG.loadGraphic(Paths.image('ui/global/healthbarFG_evil'));
			case "goggles off":
				goggleblink = false;
				egg.visible = false;
				FlxTween.tween(scramble, {y: -720}, 0.3, {ease: FlxEase.expoInOut});
				leggies.animation.play('idle');
				ground_run.animation.play('idle');
				onTruck = true;
			case "run bitch":
				dad.y = 0;
				truck.alpha = 1;
				ground_run.alpha = 1;
				leggies.alpha = 1;
				ground.alpha = 0;
			case "job well done":
				FlxTween.tween(black, {alpha: 1}, 0.3, {ease: FlxEase.expoInOut});
		}
	}
}

function onEndSong()
{
	if (isStoryMode) OverworldState.curCutscene = 'scp_post';
}
