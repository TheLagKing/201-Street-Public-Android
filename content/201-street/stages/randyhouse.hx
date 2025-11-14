var bg:FlxBackdrop;
var bgRED:FlxBackdrop;
var fg:FlxBackdrop;
var peekaboo:FlxSprite;
var Iseeyou:FlxSprite;
var SCARYbg:FlxBackdrop;
var SCARYbars:FlxBackdrop;
var SCARYfront:FlxBackdrop;
var bgbg:FlxBackdrop;
var bg2:FlxBackdrop;
var black:FlxSprite;
var blacklast:FlxSprite;
var red:FlxSprite;
var barTop:FlxSprite;
var barBottom:FlxSprite;
var ahhScary:Bool = false;
var walkinere:Bool = true;

// INTRO
var zoomIn:FlxSprite;
var introBG:FlxSprite;
var chimney:FlxSprite;
var sky:FlxSprite;
var window:FlxSprite;

function onLoad()
{
	loadIntroAssets();

	SCARYbg = new FlxSprite(-900, -50).loadGraphic(Paths.image("backgrounds/hello-randy/scary_BACK"));
	SCARYbg.antialiasing = false;
	add(SCARYbg);

	bgbg = new FlxBackdrop(Paths.image("backgrounds/hello-randy/bgbg"), FlxAxes.X, 0, 0);
	bgbg.antialiasing = false;
	add(bgbg);

	peekaboo = new FlxSprite(-1140, 220);
	peekaboo.frames = Paths.getSparrowAtlas("backgrounds/hello-randy/window_ghostface");
	peekaboo.animation.addByPrefix('idle', 'ghostface_window', 24, true);
	peekaboo.animation.play('idle');
	peekaboo.antialiasing = false;
	peekaboo.visible = false;
	add(peekaboo);

	// this is for tracking ghostface so im not using backdrop
	bg2 = new FlxSprite(-2625, 0).loadGraphic(Paths.image("backgrounds/hello-randy/bg"));
	bg2.antialiasing = false;
	bg2.visible = true;
	add(bg2);

	bg = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/hello-randy/bg"));
	bg.antialiasing = false;
	bg.visible = true;
	add(bg);

	bgRED = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/hello-randy/bg_RED"));
	bgRED.antialiasing = false;
	bgRED.visible = false;
	add(bgRED);

	Iseeyou = new FlxSprite(-1140, 220);
	Iseeyou.frames = Paths.getSparrowAtlas("backgrounds/hello-randy/window_ghostface_RED");
	Iseeyou.animation.addByPrefix('idle', 'ghostface_window0000', 1, true);
	Iseeyou.animation.play('idle');
	Iseeyou.antialiasing = false;
	Iseeyou.visible = false;
	add(Iseeyou);

	barTop = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(75), FlxColor.BLACK);
	barTop.screenCenter(FlxAxes.X);
	barTop.cameras = [game.camHUD];
	barBottom = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(75), FlxColor.BLACK);
	barBottom.screenCenter(FlxAxes.X);
	barBottom.cameras = [game.camHUD];
	barBottom.y = 649;
	barTop.alpha = 0;
	barBottom.alpha = 0;
	add(barTop);
	add(barBottom);
}

function loadIntroAssets()
{
	zoomIn = new FlxSprite().loadGraphic(Paths.image("backgrounds/hello-randy/intro/zoom_frame"));
	zoomIn.setGraphicSize(FlxG.width, FlxG.height);
	zoomIn.screenCenter();
	zoomIn.camera = camOther;
	zoomIn.antialiasing = false;

	introBG = new FlxSprite().loadGraphic(Paths.image("backgrounds/hello-randy/intro/intro_bg"));
	introBG.setGraphicSize(FlxG.width, FlxG.height);
	introBG.screenCenter();
	introBG.camera = camOther;
	introBG.antialiasing = false;

	window = new FlxSprite();
	window.frames = Paths.getSparrowAtlas("backgrounds/hello-randy/intro/randy-window");
	window.animation.addByPrefix("anim", "frame0", 24, false);
	window.animation.play("anim");
	window.updateHitbox();
	window.scale.set(2 / 3, 2 / 3);
	window.x += 320;
	window.y += 160;
	window.camera = camOther;
	window.antialiasing = false;

	sky = new FlxSprite();
	sky.frames = Paths.getSparrowAtlas("backgrounds/hello-randy/intro/sky");
	sky.animation.addByPrefix("idle", "frame0", 24, true);
	sky.animation.play("idle");
	sky.updateHitbox();
	sky.scale.set(2 / 3, 2 / 3);
	sky.x -= 320;
	sky.y -= 186;
	sky.camera = camOther;
	sky.antialiasing = false;

	chimney = new FlxSprite();
	chimney.frames = Paths.getSparrowAtlas("backgrounds/hello-randy/intro/chimney");
	chimney.animation.addByPrefix("idle", "frame0", 24, true);
	chimney.animation.play("idle");
	chimney.updateHitbox();
	chimney.scale.set(2 / 3, 2 / 3);
	chimney.x -= 305;
	chimney.y -= 185;
	chimney.camera = camOther;
	chimney.antialiasing = false;
}

function addIntroAssets()
{
	add(zoomIn);
	add(introBG);
	add(window);
	add(sky);
	add(chimney);
}

function onCreatePost()
{
	addIntroAssets();

	isCameraOnForcedPos = true;
	camFollow.setPosition(600, 455);
	FlxG.camera.snapToTarget();
	skipCountdown = true;

	modManager.setValue("opponentSwap", 1);
	modManager.setValue("alpha", 1, 1);

	SCARYfront = new FlxSprite(-900, -50).loadGraphic(Paths.image("backgrounds/hello-randy/scary_FRONT"));
	SCARYfront.antialiasing = false;
	SCARYfront.visible = false;
	add(SCARYfront);

	SCARYbars = new FlxSprite(-900, -50).loadGraphic(Paths.image("backgrounds/hello-randy/SCARY_bars"));
	SCARYbars.antialiasing = false;
	SCARYbars.visible = false;
	add(SCARYbars);

	fg = new FlxBackdrop(Paths.image("backgrounds/hello-randy/fg"), FlxAxes.X, 0, 0);
	fg.antialiasing = false;
	add(fg);

	blacklast = new FlxSprite(-900, 50).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	blacklast.setGraphicSize(Std.int(bg.SCARYbg));
	blacklast.scale.set(2, 2);
	blacklast.alpha = 0;
	add(blacklast);

	black = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	black.cameras = [game.camOther];
	black.alpha = 1;
	add(black);

	red = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
	red.cameras = [game.camHUD];
	red.blend = BlendMode.MULTIPLY;
	red.alpha = 0;
	add(red);

	iconP1.antialiasing = false;
	iconP2.antialiasing = false;
	playHUD.healthBarFG.loadGraphic(Paths.image('ui/hello-randy/healthbar-randy'));
	camHUD.alpha = 0;
}

function onSongStart()
{
	camGame.visible = false;
	camHUD.visible = false;

	sky.animation.play("idle", true);
	chimney.animation.play("idle", true);
	window.animation.play("anim", true);

	FlxTween.tween(black, {alpha: 0}, 1);
	FlxG.sound.play(Paths.sound("randyPhoneRing"));
}

function onUpdate(elapsed:Float)
{
	// shmoovement
	var dalapsed:Float = elapsed / 0.016;
	var speed:Float = 1.12 * dalapsed;

	if (walkinere)
	{
		peekaboo.x += speed;
		bg.x += speed;
		bg2.x += speed;
		bgbg.x += speed;
		fg.x += speed;

		if (bg.x > 1800) bg.x = bg2.x + -2625;
		if (bg2.x > 1800) bg2.x = bg.x + -2625;
		bgRED.x = bg2.x;
		peekaboo.x = bg.x + -1140;
		Iseeyou.x = bg.x + -1140;
	}

	if (ahhScary)
	{
		if (!mustHitSection)
		{
			game.defaultCamZoom = 1.3;
		}
		else
		{
			game.defaultCamZoom = 1.1;
		}
	}
}

function onEvent(name, v1, v2)
{
	if (name == "Events")
	{
		switch (v1)
		{
			case "intro":
				switch (Std.parseInt(v2))
				{
					case 0:
						introBG.visible = false;
						sky.visible = false;
						chimney.visible = false;
						window.visible = false;
					case 1:
						zoomIn.visible = false;
						camGame.visible = true;
						camHUD.visible = true;
				}
			case "snapcam":
				defaultCamZoom = 1.1;
				FlxG.camera.zoom = 1.1;
				camHUD.alpha = 1;
			case "do you see him":
				peekaboo.visible = true;
			case "whats going on im scared":
				game.health = 1;
				camZooming = false;
				dad.visible = false;
				walkinere = false;
				healthBar.alpha = 0;
				iconP1.alpha = 0;
				iconP2.alpha = 0;
				scoreTxt.alpha = 0;
				bgRED.visible = true;
				Iseeyou.visible = true;
				peekaboo.visible = false;
				fg.visible = false;
			case "hello bro":
				camZooming = true;
				black.alpha = 1;
			case "pls no":
				dad.visible = true;
				game.defaultCamZoom = 1.6;
				camFollow.setPosition(550, 455);
				peekaboo.visible = false;
			case "where am I":
				barTop.alpha = 1;
				barBottom.alpha = 1;
				FlxTween.tween(black, {alpha: 0}, 0.3);
				modManager.setValue("opponentSwap", 0);
				SCARYbars.visible = true;
				SCARYfront.visible = true;
				bgRED.visible = false;
				Iseeyou.visible = false;
				bgbg.visible = false;
				bg.visible = false;
				bg2.visible = false;
			case "BEHIND YOU":
				game.defaultCamZoom = 1.3;
			case "YOU GONNA DIE BRO":
				playHUD.healthBarFG.loadGraphic(Paths.image('ui/hello-randy/healthbar-randySCARY'));
				FlxTween.tween(healthBar, {alpha: 1}, 0.3);
				FlxTween.tween(iconP1, {alpha: 1}, 0.3);
				FlxTween.tween(iconP2, {alpha: 1}, 0.3);
				FlxTween.tween(scoreTxt, {alpha: 1}, 0.3);
				isCameraOnForcedPos = false;
				ahhScary = true;
			case "virtual boy":
				FlxTween.tween(red, {alpha: (ClientPrefs.flashing ? 1 : 0.3)}, 0.7);
				scoreTxt.color = FlxColor.RED;
			case "done":
				switch (v2)
				{
					case "black":
						blacklast.alpha = 1;
					case "fade":
						FlxTween.tween(camHUD, {alpha: 0}, 0.5);
				}
		}
	}
}

function onEndSong()
{
	if (isStoryMode) OverworldState.curCutscene = 'post_randy';
}
