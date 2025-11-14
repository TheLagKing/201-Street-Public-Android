import funkin.game.huds.ILOVEHUD;
import openfl.filters.ShaderFilter;
import flixel.text.FlxText;

var hallway:FlxSprite;
var bg:FlxSprite;
var taxman:FlxSprite;
var chandelier:FlxSprite;
var extractionFront:FlxSprite;
var extractionBack:FlxSprite;
var black:FlxSprite;
var ttsText:FlxText;
var ttsColorTimer:FlxTimer;
final TTS_Y:Float = 450.0;
final TTS_Y_BUMP:Float = 5.0;
final TTS_COLOR:FlxColor = 0xFFF4DB12;
var camPhase = 0;
var lockZoom:Bool = false;
var cameos:Array<FlxSprite> = [];
var cameo_pos = [2000, 800, 800, 2000, 2000];
var cameo_destination = [800, 2000, 2000, 800, 800];
var myRed:FlxSprite;

function onLoad()
{
	myRed = new FlxSprite(0, 0).makeGraphic(FlxG.width + 1, FlxG.height + 1, FlxColor.RED);
	myRed.cameras = [camOther];
	myRed.blend = BlendMode.ADD;
	myRed.alpha = 0;
	add(myRed);

	black = new FlxSprite(0, 0).makeGraphic(FlxG.width + 1, FlxG.height + 1, FlxColor.BLACK);
	black.cameras = [camOther];
	add(black);

	hallway = new FlxSprite(191, 109).loadGraphic(Paths.image("backgrounds/headman/bgFloor"));
	taxman = new FlxSprite(-32, 72);
	taxman.frames = Paths.getSparrowAtlas('backgrounds/headman/bgTaxman');
	for (i in 0...6)
	{
		taxman.animation.addByPrefix('face' + (i + 1), 'face' + (i + 1), 24);
	}

	taxman.animation.addByPrefix('end', 'endingAnim', 24, false);
	taxman.animation.play('face1');
	chandelier = new FlxSprite(797, 66).loadFromSheet('backgrounds/headman/chandelier', 'bgChandelier', 24);
	bg = new FlxSprite(-92, -29);
	bg.frames = Paths.getSparrowAtlas("backgrounds/headman/bgMain");
	bg.animation.addByPrefix('still', 'mainBG0', 0);
	bg.animation.addByPrefix('fall', 'mainBG extract0', 24, false);
	bg.animation.play('still');
	overlay = new FlxSprite(bg.x, bg.y).loadGraphic(Paths.image('backgrounds/headman/overlay'));
	overlay.zIndex = 10;
	overlay.blend = BlendMode.MULTIPLY;
	hallway.setGraphicSize(hallway.width * 2);
	hallway.updateHitbox();
	hallway.setPosition(hallway.x * 2, hallway.y * 2);
	add(hallway);

	for (i in 0...5)
	{
		var cam:FlxSprite = new FlxSprite(cameo_pos[i], 230).loadGraphic(Paths.image("backgrounds/headman/cameo/" + (i + 1)));
		cam.y = 940 - cam.height;
		cameos.push(cam);
		add(cam);
	}

	for (i in [taxman, bg, chandelier, overlay])
	{
		i.setGraphicSize(i.width * 2);
		i.updateHitbox();
		i.setPosition(i.x * 2, i.y * 2);
		add(i);
	}

	final exX:Float = 80;
	final exY:Float = -50;

	extractionBack = new FlxSprite(exX, exY);
	extractionBack.frames = Paths.getSparrowAtlas("backgrounds/headman/extractionBelow");
	extractionBack.animation.addByPrefix("fall", "bgExtraction20", 24, false);
	extractionBack.animation.play("fall");
	extractionBack.setGraphicSize(extractionBack.width * 2, extractionBack.height * 2);
	extractionBack.visible = false;
	add(extractionBack);

	extractionFront = new FlxSprite(exX, exY);
	extractionFront.frames = Paths.getSparrowAtlas("backgrounds/headman/extractionAbove");
	extractionFront.animation.addByPrefix("fall", "bgExtraction10", 24, false);
	extractionFront.animation.play("fall");
	extractionFront.setGraphicSize(extractionFront.width * 2, extractionFront.height * 2);
	extractionFront.visible = false;

	ttsText = new FlxText(0, 0).setFormat("repo.ttf", 70, FlxColor.WHITE, FlxTextAlign.CENTER);
	ttsText.text = "where";
	ttsText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 5, 1);
	ttsText.screenCenter(FlxAxes.X);
	ttsText.y = TTS_Y;
	ttsText.camera = camHUD;
	ttsText.visible = false;
	add(ttsText);

	ttsColorTimer = new FlxTimer();

	camHUD.alpha = 1;
	defaultCamZoom = 1.3;
	lockZoom = true;
}

var bloom = newShader('bloom');
var bloom2 = newShader('bloom2');
var grain = newShader('grain');
var chromaticWarp = newShader('chromaticWarp');

function onCreatePost()
{
	modManager.setValue("alpha", 1, 1);
	playHUD.kill();
	playHUD = new ILOVEHUD(PlayState.instance);
	playHUD.cameras = [camHUD];
	insert(members.indexOf(playFields), playHUD);

	add(extractionFront);

	var front:FlxSprite = new FlxSprite(-124, 605 - 69).loadGraphic(Paths.image("backgrounds/headman/foreground"));
	front.setGraphicSize(front.width * 2);
	front.updateHitbox();
	front.setPosition(front.x * 2, front.y * 2);
	add(front);

	if (ClientPrefs.shaders)
	{
		bloom.setFloat('blurSize', 0.1);
		bloom.setFloat('intensity', 0.1);
		chromaticWarp.setFloat('distortion', 0.1);
		grain.setFloat("multiplier", 0.0);

		dad.shader = bloom2;
		camGame.filters = [new ShaderFilter(chromaticWarp)];
		FlxG.game.setFilters([new ShaderFilter(grain), new ShaderFilter(chromaticWarp)]);
	}

	vignette = new FlxSprite().loadGraphic(Paths.image('backgrounds/headman/vignette'));
	vignette.antialiasing = ClientPrefs.globalAntialiasing;
	vignette.camera = camHUD;
	vignette.setGraphicSize(FlxG.width + 1, FlxG.height + 1);
	add(vignette);

	skipCountdown = true;
}

function cameoMove(which:Int)
{
	if (which != 4) FlxTween.tween(cameos[which], {x: cameo_destination[which]}, which == 0 ? 4 : 6);
	else
	{
		if (FlxG.random.int(0, 10) != 0) return;

		cameos[which].x = 1973;
		FlxTween.tween(cameos[which], {x: cameos[which].x - 170}, 1,
			{
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween) {
					FlxTween.tween(cameos[which], {x: cameos[which].x + 170}, 1, {ease: FlxEase.quadIn, startDelay: 1});
				}
			});
	}
}

function changeTTSText(tts:String)
{
	ttsText.text = tts;
	ttsText.screenCenter(FlxAxes.X);
	ttsText.color = TTS_COLOR;
	ttsText.y = TTS_Y + TTS_Y_BUMP;
	FlxTween.cancelTweensOf(ttsText);
	FlxTween.tween(ttsText, {y: TTS_Y}, 0.5,
		{
			ease: FlxEase.elasticOut
		});

	ttsColorTimer.cancel();
	ttsColorTimer.start(0.2, () -> {
		ttsText.color = FlxColor.WHITE;
	});

	ttsText.visible = true;
}

function onMoveCamera(isDad)
{
	if (lockZoom) return;

	if (isDad == 'boyfriend')
	{
		game.defaultCamZoom = 0.8;
	}
	else
	{
		game.defaultCamZoom = 0.6;
	}
}

function onEvent(name, v1, v2)
{
	if (name == "repo events")
	{
		switch (v1)
		{
			case 'starting camera':
				snapCamToPos(boyfriend.x + 200, boyfriend.y + 100);
				isCameraOnForcedPos = true;

				var dur:Float = 6.5;
				FlxTween.tween(FlxG.camera, {zoom: 1}, dur, {ease: FlxEase.quadOut});
				FlxTween.tween(black, {alpha: 0}, dur,
					{
						onComplete: function(twn:FlxTween) {
							FlxTween.tween(FlxG.camera, {zoom: 0.8}, 4, {ease: FlxEase.sineInOut});
							FlxTween.tween(camFollow, {x: dad.x + 1100, y: dad.y + 400}, 4, {ease: FlxEase.sineInOut});
						}
					});

			case 'scream':
				defaultCamZoom = 0.5;
				camFollow.x = dad.x + 1350;

			case 'SING BOY':
				lockZoom = false;
				FlxTween.tween(camHUD, {alpha: 1}, 0.5);
				isCameraOnForcedPos = false;

			case 'change tts':
				changeTTSText(v2);

			case 'close tts':
				ttsText.visible = false;

			case 'extraction':
				switch (Std.parseInt(v2))
				{
					case 0:
						lockZoom = true;
						isCameraOnForcedPos = true;

						FlxTween.tween(game, {defaultCamZoom: 0.6}, (Conductor.crotchet / 1000) * 6, {ease: FlxEase.sineInOut});
						FlxTween.tween(camFollow, {x: dad.x + 1300, y: dad.y + 400}, (Conductor.crotchet / 1000) * 6, {ease: FlxEase.sineInOut});

					case 1:
						defaultCamZoom = 0.5;
						camFollow.x = dad.x + 1350;
						taxman.animation.play('end');

					case 2:
						bg.animation.play("fall");
						extractionFront.visible = true;
						extractionFront.animation.play("fall");
						extractionBack.visible = true;
						extractionBack.animation.play("fall");
				}

			case 'duck':
				new FlxTimer().start(0.5, () -> {
					dad.playAnimForDuration('shock', 2.3, true);
					boyfriend.playAnimForDuration('shocked', 2.3, true);
				});

				camFollow.x = dad.x + 1350;
				camFollow.y = dad.y + 400;

				isCameraOnForcedPos = true;
				lockZoom = true;
				defaultCamZoom = 0.5;

			case 'end duck':
				isCameraOnForcedPos = false;
				lockZoom = false;

			case 'because we are using an older version of nmv the character playAnim function is forever fucked so this is my bandage fix':
				isCameraOnForcedPos = false;

			case 'cameo':
				var cameo:Int = Std.parseInt(v2);
				if (cameo >= 0 && cameo < 5) cameoMove(cameo);

			case 'bro please flash red':
				FlxTween.cancelTweensOf(myRed);

				if (!ClientPrefs.flashing)
				{
					FlxTween.cancelTweensOf(myRed);
					myRed.alpha = 0.1;
					FlxTween.tween(myRed, {alpha: 0.05}, (Conductor.crotchet / 1000) * 3, {ease: FlxTween.expoOut});
				}
				else
				{
					FlxTween.cancelTweensOf(myRed);
					myRed.alpha = 0.2;
					FlxTween.tween(myRed, {alpha: 0.15}, (Conductor.crotchet / 1000) * 3, {ease: FlxTween.expoOut});
				}

			case "cut to black":
				black.alpha = 1;

			case "fade from black":
				FlxTween.tween(black, {alpha: 0}, Std.parseFloat(v2));
		}
	}
}

var total_elapsed:Float = 0;

function onUpdate(elapsed)
{
	total_elapsed += elapsed;
	grain.setFloat("iTime", total_elapsed);
}

function onRecalculateRating()
{
	if (taxman != null)
	{
		if (taxman.animation.curAnim.name != "end")
		{
			switch (ratingFC.toLowerCase())
			{
				case "gfc":
					taxman.animation.play("face2");
				case "fc":
					taxman.animation.play("face3");
				case "sdcb":
					taxman.animation.play("face4");
				case "clear":
					if (songMisses > 15) taxman.animation.play("face6");
					else taxman.animation.play("face5");
				default:
					taxman.animation.play("face1");
			}
		}
	}
}

function onDestroy()
{
	FlxG.game.setFilters([]);
	camGame.filters = [];
}

function onGameOverStart()
{
	FlxG.game.setFilters([]);
	camGame.filters = [];
}

function onEndSong()
{
	if (isStoryMode) OverworldState.curCutscene = 'repo_exit';
}
