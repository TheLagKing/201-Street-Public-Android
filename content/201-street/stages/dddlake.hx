import funkin.game.shaders.DropShadowShader;

var sky:FlxSprite;
var ground:FlxSprite;
var light:FlxSprite;
var sky_green:FlxSprite;
var ground_green:FlxSprite;
var light_green:FlxSprite;
var ground_ufo:FlxSprite;
var addColorshader;
var leticia:Character;
var bgx:Int = -600;
var bgy:Int = -300;
var scaleyy:Float = 1.2;

function onLoad()
{
	sky_green = new FlxSprite(bgx, bgy).loadGraphic(Paths.image("backgrounds/fallen-skies/dddgreensky"));
	sky_green.scale.set(scaleyy, scaleyy);
	add(sky_green);

	ground_green = new FlxSprite(bgx, bgy).loadGraphic(Paths.image("backgrounds/fallen-skies/dddgreenground"));
	ground_green.scale.set(scaleyy, scaleyy);
	add(ground_green);

	ground_ufo = new FlxSprite(bgx, bgy).loadGraphic(Paths.image("backgrounds/fallen-skies/dddgreengroundufo"));
	ground_ufo.scale.set(scaleyy, scaleyy);
	add(ground_ufo);
	ground_ufo.alpha = 0;

	sky = new FlxSprite(bgx, bgy).loadGraphic(Paths.image("backgrounds/fallen-skies/dddsky"));
	sky.scale.set(scaleyy, scaleyy);
	add(sky);

	ground = new FlxSprite(bgx, bgy).loadGraphic(Paths.image("backgrounds/fallen-skies/dddground"));
	ground.scale.set(scaleyy, scaleyy);
	add(ground);

	leticia = new Character(1000, 70, 'leticia', false);
	add(leticia);

	if (isStoryMode) songEndCallback = cutscene_ending;
}

function onCreatePost()
{
	skipCountdown = true;
	
	light_green = new FlxSprite(bgx, bgy).loadGraphic(Paths.image("backgrounds/fallen-skies/dddgreenlight"));
	light_green.scale.set(scaleyy, scaleyy);
	add(light_green);
	light_green.alpha = 0;

	light = new FlxSprite(bgx, bgy).loadGraphic(Paths.image("backgrounds/fallen-skies/dddlight"));
	light.scale.set(scaleyy, scaleyy);
	add(light);

	dadGroup.zIndex = 0;
	gfGroup.zIndex = 1;
	light_green.zIndex = 2;
	light.zIndex = 3;

	addColorshader = newShader('addColor');
	light.shader = addColorshader;
	light_green.shader = addColorshader;

	snapCamToPos(450, 225, false);
}

function onCountdownTick(tick:Int)
{
	if (tick % 2 == 0) leticia.dance();
}

function onBeatHit()
{
	if (curBeat % leticia.danceEveryNumBeats == 0)
	{
		leticia.dance();
	}
}

function onEvent(name, v1, v2)
{
	if (name == "Events")
	{
		switch (v1)
		{
			case "cam":
				switch (v2)
				{
					case "default":
						game.defaultCamZoom = 0.7;
						game.isCameraOnForcedPos = false;
					case "center":
						game.defaultCamZoom = 0.6;
						game.isCameraOnForcedPos = true;
						game.camFollow.x = 350;
						game.camFollow.y = 220;
				}
			case "norm":
				FlxTween.tween(sky, {alpha: 1}, 1);
				FlxTween.tween(ground, {alpha: 1}, 1);
				FlxTween.tween(light, {alpha: 1}, 1);
				FlxTween.tween(light_green, {alpha: 0}, 1);
			case "empty space":
				FlxTween.tween(sky, {alpha: 0}, 1);
				FlxTween.tween(ground, {alpha: 0}, 1);
				FlxTween.tween(light, {alpha: 0}, 1);
				FlxTween.tween(light_green, {alpha: 1}, 1);
			case "danse": // for the dance idles in last chorus
				dad.danceEveryNumBeats = 1;
				gf.danceEveryNumBeats = 1;
			case "icon change":
				iconP2.changeIcon("okarun");
				healthBar.setColors(FlxColor.fromRGB(68, 131, 235), boyfriend.healthColour);
			case "strum owner": // the cam change goes earlier before icon change ok
				if (v2 == "gf")
				{
					opponentStrums.owner = gf;
				}
				else
				{
					opponentStrums.owner = dad;
					iconP2.changeIcon("momo");
					healthBar.setColors(dad.healthColour, boyfriend.healthColour);
				}
			case "ufo":
				FlxTween.tween(sky_green, {alpha: 0}, 0.3);
				FlxTween.tween(ground_green, {alpha: 0}, 0.3);
				FlxTween.tween(ground_ufo, {alpha: 1}, 0.3);

				// there has to be a better way to do this
				var rimBf = new DropShadowShader();
				rimBf.setAdjustColor(-46, -38, -25, -20);
				rimBf.color = 0xB3EA86;
				rimBf.angle = 70;
				boyfriend.shader = rimBf;
				rimBf.attachedSprite = boyfriend;
				boyfriend.animation.onFrameChange.add(function() {
					rimBf.updateFrameInfo(boyfriend.frame);
				});
				var rimGf = new DropShadowShader();
				rimGf.setAdjustColor(-46, -38, -25, -20);
				rimGf.color = 0xB3EA44;
				rimGf.angle = 20;
				gf.shader = rimGf;
				rimGf.attachedSprite = gf;
				gf.animation.onFrameChange.add(function() {
					rimGf.updateFrameInfo(gf.frame);
				});
				var rimDad = new DropShadowShader();
				rimDad.setAdjustColor(-46, -38, -25, -20);
				rimDad.color = 0xB3EA44;
				rimDad.angle = 20;
				rimDad.distance = 6;
				dad.shader = rimDad;
				rimDad.attachedSprite = dad;
				dad.animation.onFrameChange.add(function() {
					rimDad.updateFrameInfo(dad.frame);
				});
				var rimLet = new DropShadowShader();
				rimLet.setAdjustColor(-46, -38, -25, -20);
				rimLet.color = 0xB3EA44;
				rimLet.angle = 90;
				leticia.shader = rimLet;
				rimLet.attachedSprite = leticia;
				leticia.animation.onFrameChange.add(function() {
					rimLet.updateFrameInfo(leticia.frame);
				});

			case 'ending':
				var ending_time:Float = 1.8;
				isCameraOnForcedPos = true;
				FlxTween.tween(game, {defaultCamZoom: 1.2}, ending_time);
				FlxTween.tween(camFollow, {x: 900}, ending_time);
				FlxTween.tween(camFollow, {y: -100}, ending_time);
				FlxTween.tween(camHUD, {alpha: 0}, ending_time);
				FlxG.camera.fade(FlxColor.BLACK, ending_time, false);

		}
	}
}

function cutscene_ending()
{
	camGame.visible = false;
	camHUD.visible = false;
	canPause = false;
	endingSong = true;
	camZooming = false;
	inCutscene = false;
	updateTime = false;

	FlxG.sound.play(Paths.sound('post_fallen_skies'));

	new FlxTimer().start(7.5, function(tmr:FlxTimer) {
		endSong();
	});
}
