import funkin.game.huds.MCHUD;

var bg:FlxSprite;
var sightings:FlxSprite;
var introVid:FunkinVideoSprite;
var blackScreen:FlxSprite;
var fog:FlxSprite;
var redVin:FlxSprite;
var blackVin:FlxSprite;
var coolSine:Float = 0;
var updateSine:Bool = false;
var chickenTrigger:Int;

function onLoad()
{
	bg = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/headlights/BG"));
	add(bg);

	chicken = new FlxSprite(0, 600);
	chicken.frames = Paths.getSparrowAtlas("backgrounds/headlights/chicken");
	chicken.animation.addByPrefix('wsg', 'chickenAnim0', 30, false);
	add(chicken);

	skipCountdown = true;

	introVid = new FunkinVideoSprite();
	introVid.onFormat(() -> {
		introVid.setGraphicSize(0, FlxG.height);
		introVid.updateHitbox();
		introVid.screenCenter();
		introVid.cameras = [camHUD];
	});
	introVid.onEnd(() -> {
		camGame.visible = true;
	});
	introVid.load(Paths.video('herobrine_intro'), [FunkinVideoSprite.muted]);
	add(introVid);

	fog = new FlxSprite(0, 0).makeGraphic(1283, 720, FlxColor.fromRGB(213, 210, 236));
	fog.cameras = [camHUD];
	fog.alpha = 0;
	add(fog);

	redVin = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/headlights/vignettereddanger"));
	redVin.cameras = [camHUD];
	redVin.alpha = 0;
	redVin.scale.x = 1.1;
	add(redVin);

	blackVin = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/headlights/vignetteblack"));
	blackVin.cameras = [camHUD];
	blackVin.alpha = 0;
	blackVin.scale.x = 1.1;
	add(blackVin);

	blackScreen = new FlxSprite(0, 0).makeGraphic(1283, 720, FlxColor.BLACK);
	blackScreen.cameras = [camHUD];
	add(blackScreen);

	sightings = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/headlights/sightings/1"));
	sightings.cameras = [camOther];
	sightings.screenCenter();
	sightings.visible = false;
	add(sightings);
	camGame.visible = false;
}

function onCreatePost()
{
	game.snapCamToPos(bg.x + (bg.width / 2), bg.y + (bg.height / 2), true);
	// 960
	// 540
	modManager.setValue("transform0X", -125, 0);
	modManager.setValue("transform1X", -100, 0);
	modManager.setValue("transform2X", 100, 0);
	modManager.setValue("transform3X", 125, 0);
	modManager.setValue("alpha", 1, 1);
	modManager.setValue("opponentSwap", 0.5);

	playHUD.kill();
	playHUD = new MCHUD(PlayState.instance);
	playHUD.cameras = [camHUD];
	insert(members.indexOf(playFields), playHUD);

	boyfriend.kill();
	dadGroup.y = -175;

	chickenTrigger = FlxG.random.int(55, 180);
}

function onUpdate(elapsed:Float)
{
	if (updateSine)
	{
		coolSine += 180 * elapsed;
		redVin.alpha = 1 - Math.sin((Math.PI * coolSine) / 180);
	}
}

function onSongStart()
{
	introVid.play();
}

function onBeatHit()
{
	if (curBeat == chickenTrigger)
	{
		chicken.animation.play('wsg');
	}
}

function onEvent(name, v1, v2)
{
	switch (name)
	{
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
		case 'fog':
			switch (v1)
			{
				case 'on':
					FlxTween.tween(fog, {alpha: 1}, 1);
				case 'off':
					FlxTween.tween(fog, {alpha: 0}, 0.5);
			}
		case 'herobrine events':
			switch (v1)
			{
				case 'hb float down':
					FlxTween.tween(dadGroup, {y: 25}, 1, {ease: FlxEase.quadOut});
				case 'sighting':
					sightings.visible = true;

					switch (v2)
					{
						case 'blank':
							sightings.visible = false;
						case '2':
							sightings.loadGraphic(Paths.image("backgrounds/headlights/sightings/2"));
						case '3':
							sightings.loadGraphic(Paths.image("backgrounds/headlights/sightings/3"));
						case '4':
							sightings.loadGraphic(Paths.image("backgrounds/headlights/sightings/4"));
						case '5':
							sightings.loadGraphic(Paths.image("backgrounds/headlights/sightings/5"));
						case '6':
							sightings.loadGraphic(Paths.image("backgrounds/headlights/sightings/6"));
						case '7':
							sightings.loadGraphic(Paths.image("backgrounds/headlights/sightings/7"));
					}
				case 'im gay':
					camHUD.visible = false;
					camGame.visible = false;
				case 'redVin':
					switch (v2)
					{
						case 'on':
							FlxTween.tween(redVin, {alpha: 1}, 0.5,
								{
									onComplete: function(twn:FlxTween) {
										updateSine = true;
									}
								});
						case 'off':
							updateSine = false;
							FlxTween.tween(redVin, {alpha: 0}, 0.5);
					}
				case 'blackVin':
					switch (v2)
					{
						case 'on':
							FlxTween.tween(blackVin, {alpha: 1}, 1);
						case 'off':
							FlxTween.tween(blackVin, {alpha: 0}, 1);
					}
				case 'gayHUDfade':
					// dslkfgjsdlkfjjklfsdjklfdsjhklfsdhjklfsdhjkfesdwhjkfewdshjklfewshjoiuewsfdojhuifhjuiofrejoihufewrsjoki

					var hudMembers:Array = [playHUD.healthBar, playHUD.scoreTxt];

					switch (v2)
					{
						case 'on':
							for (i in hudMembers)
							{
								FlxTween.tween(i, {alpha: 1.5}, 1.5);
							}

							for (i in playerStrums)
							{
								FlxTween.tween(i, {alpha: 1.5}, 1.5);
							}
						case 'off':
							for (i in hudMembers)
							{
								FlxTween.tween(i, {alpha: 0}, 0.25);
							}

							for (i in playerStrums)
							{
								FlxTween.tween(i, {alpha: 0}, 0.25);
							}
					}
			}
	}
}

function onEndSong()
{
	if (isStoryMode) OverworldState.curCutscene = 'herobrine_exit';
}
