import funkin.game.shaders.DropShadowShader;
import funkin.backend.Difficulty;
import flixel.text.FlxText;
import funkin.backend.PlayerSettings;

var sky2d:FlxSprite;
var floor2d:FlxSprite;
var forest2d:FlxSprite;
var pyramid2d:FlxSprite;
var mountains2d:FlxSprite;
var bubble:FlxSprite;
var black:FlxSprite;
var scaleyy:Float = 1.3;
var lazy:Float = -50;
var monochrome;
var angry:Bool = false;
var overlay:FlxSprite;
var rimBillie:DropShadowShader;
var rays:FlxSprite;
var whiteglow:FlxSprite;
var leave:Bool = false;
var pop:Bool = false;
var skip:FlxText;
var introVid:FunkinVideoSprite;
var zoom:Bool = false;
var counter:Int = -1;
var skipEnter = PlayerSettings.player1.controls;
var total_elapsed:Float = 0;

// JESS YOU BETTER NOT BITCH ABT THIS CODEEEEEEE IMM TOOO LAAAAZYYY TO ORGANIZE ITTT IM SOO LAAAAAAAAAAAZYYYYYYYYYYY

function onLoad()
{
	game.addCharacterToList('billred');
	game.addCharacterToList('billie_emotional');

	sky2d = new FlxSprite(-225 + lazy, -225).loadGraphic(Paths.image("backgrounds/weirdmageddon/2d/sky"));
	sky2d.scale.set(scaleyy, scaleyy);
	sky2d.scrollFactor.set(0.2, 0.2);
	add(sky2d);

	mountains2d = new FlxSprite(-275 + lazy, 75).loadGraphic(Paths.image("backgrounds/weirdmageddon/2d/mountians"));
	mountains2d.scale.set(scaleyy, scaleyy);
	mountains2d.scrollFactor.set(0.5, 0.5);
	add(mountains2d);

	pyramid2d = new FlxSprite(-120 + lazy, -130).loadGraphic(Paths.image("backgrounds/weirdmageddon/2d/pyramid"));
	pyramid2d.scale.set(scaleyy, scaleyy);
	pyramid2d.scrollFactor.set(0.2, 0.2);
	add(pyramid2d);

	bubble = new FlxSprite(150 + lazy, -375);
	bubble.frames = Paths.getSparrowAtlas("backgrounds/weirdmageddon/2d/bubble");
	bubble.scale.set(scaleyy, scaleyy);
	bubble.scrollFactor.set(0.75, 0.75);
	bubble.animation.addByPrefix('bubble', 'bubble0', 24, true);
	bubble.animation.addByPrefix('pop', 'pop0', 24, false);
	bubble.animation.play('bubble');
	bubble.animation.onFrameChange.add(function(name:String, frame:Int) {
		if (name == "pop" && frame == 33) bubble.y += 50;
	});

	bubble.animation.onFinish.add(function(name:String) {
		if (name == "pop") bubble.visible = false;
	});
	add(bubble);

	forest2d = new FlxSprite(-340 + lazy, 30).loadGraphic(Paths.image("backgrounds/weirdmageddon/2d/forest"));
	forest2d.scale.set(scaleyy, scaleyy);
	forest2d.scrollFactor.set(0.8, 0.8);
	add(forest2d);

	floor2d = new FlxSprite(-300 + lazy, -400).loadGraphic(Paths.image("backgrounds/weirdmageddon/2d/floor"));
	floor2d.scale.set(scaleyy, scaleyy);
	add(floor2d);

	sky3d = new FlxSprite(-470 + lazy, -320).loadGraphic(Paths.image("backgrounds/weirdmageddon/3d/Sky"));
	sky3d.visible = false;
	sky3d.scale.set(1.2, 1.2);
	sky3d.scrollFactor.set(0.2, 0.2);
	add(sky3d);

	floats3d = new FlxSprite(-360 + lazy, -350).loadGraphic(Paths.image("backgrounds/weirdmageddon/3d/Floating"));
	floats3d.visible = false;
	floats3d.scale.set(1.2, 1.2);
	floats3d.scrollFactor.set(0.4, 0.4);
	add(floats3d);

	street3d = new FlxSprite(-300 + lazy, -350).loadGraphic(Paths.image("backgrounds/weirdmageddon/3d/Street"));
	street3d.scale.set(scaleyy, scaleyy);
	street3d.visible = false;
	add(street3d);

	rays = new FlxSprite(400, -320).loadGraphic(Paths.image("backgrounds/weirdmageddon/3d/rays"));
	rays.scale.set(0, 0);
	rays.blend = BlendMode.ADD;
	rays.alpha = 0.8;
	rays.visible = false;
	add(rays);

	whiteglow = new FlxSprite(350, -320).loadGraphic(Paths.image("backgrounds/weirdmageddon/3d/whiteball"));
	whiteglow.scale.set(0, 0);
	whiteglow.visible = false;
	add(whiteglow);

	black = new FlxSprite(-350, -350).makeGraphic(2000, 2000, FlxColor.BLACK);
	black.alpha = 1;
	black.cameras = [camOther];
	add(black);
	white = new FlxSprite(-350, -350).makeGraphic(2000, 2000, FlxColor.WHITE);
	white.alpha = 0;
	white.cameras = [camOther];
	add(white);

	overlay = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/weirdmageddon/3d/overlay"));
	overlay.blend = BlendMode.MULTIPLY;
	overlay.cameras = [camHUD];
	overlay.alpha = 0;
	add(overlay);

	red = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/weirdmageddon/3d/redglow"));
	red.cameras = [camOther];
	red.alpha = 0;
	add(red);

	total_elapsed = FlxG.random.float(-2, 2);

	gfGroup.visible = false;

	skipCountdown = true;

	introVid = new FunkinVideoSprite();
	introVid.onFormat(() -> {
		introVid.setGraphicSize(1280);
		introVid.updateHitbox();
		introVid.screenCenter();
		introVid.cameras = [camOther];
	});
	introVid.onEnd(() -> {
		PlayState.seenCutscene = true;
		endIntro();
	});
	introVid.load(Paths.video('bill_intro'));
	add(introVid);

	if (!isStoryMode)
	{
		skip = new FlxText(10, 690).setFormat(Paths.font('ATTFShinGoProBold.ttf'), 24, 0xFFFFFFFF, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		skip.text = 'Press Enter to skip';
		skip.cameras = [game.camOther];
		add(skip);
	}

	songStartCallback = PlayState.seenCutscene ? endIntro : billCutscene;
}

function onCreatePost()
{
	white.zIndex = 4;
	dadGroup.zIndex = 1;
	gfGroup.zIndex = 2;
	boyfriendGroup.zIndex = 3;
	boyfriendGroup.scrollFactor.set(1.1, 1.1);

	monochrome = newShader('monochrome');

	var rimLeticia = new DropShadowShader();
	rimLeticia.setAdjustColor(-20, -22, -16, -10);
	rimLeticia.color = 0xFF7272;
	rimLeticia.angle = 50;
	rimLeticia.threshold = 0.07;
	rimLeticia.distance = 10;
	gf.shader = rimLeticia;
	rimLeticia.attachedSprite = gf;
	gf.animation.onFrameChange.add(function() {
		rimLeticia.updateFrameInfo(gf.frame);
	});

	rimBillie = new DropShadowShader();
	rimBillie.setAdjustColor(-20, -22, -16, 0);
	rimBillie.color = 0xFFF3E77D;
	rimBillie.angle = 180;
	rimBillie.threshold = 0.07;
	boyfriend.shader = rimBillie;
	rimBillie.attachedSprite = boyfriend;
	boyfriend.animation.onFrameChange.add(function() {
		if (rimBillie.attachedSprite != null)
		{
			rimBillie.updateFrameInfo(boyfriend.frame);
		}
	});

	playHUD.healthBarFG.loadGraphic(Paths.image('ui/global/healthbarFG_leticia'));
	snapCamToPos(600, 275, false);

	gayTimer = FlxTimer.wait(0.05, () -> { // Speed face
		introVid.play();
	});
}

function onUpdate(elapsed)
{
	total_elapsed += elapsed;
	dad.y = -190 + Math.sin(total_elapsed * 1.7) * 16;

	if (!pop)
	{
		bubble.y = -240 + Math.sin(total_elapsed * 0.3) * 25;
	}

	if (leave)
	{
		rays.angle += 1 * (60 * elapsed);
	}
}

function onMoveCamera(isDad)
{
	if (angry)
	{
		if (isDad != 'dad')
		{
			if (!zoom) defaultCamZoom = 0.65;
			if (playerStrums.owner == gf)
			{
				opponentCameraOffset[0] = 250;
				opponentCameraOffset[1] = -160;
			}
		}
		else
		{
			opponentCameraOffset[0] = 670;
			opponentCameraOffset[1] = 300;
			if (!zoom) defaultCamZoom = 0.51;
		}
	}
	else if (!angry && !zoom)
	{
		if (isDad != 'dad') defaultCamZoom = 0.65;
		else defaultCamZoom = 0.7;
	}
}

function onEvent(name, v1, v2)
{
	if (name == "Bill Events")
	{
		switch (v1)
		{
			case "zoom":
				if (zoom) zoom = false;
				else zoom = true;
			case "dark":
				FlxTween.tween(black, {alpha: 1}, 0.1);
			case "eyes":
				counter += 1;
				var xPos:Int = [506, 980, 320, 50, 940, 400, 200];
				var yPos:Int = [268, 510, 55, 320, 120, 40, 450];
				var eye = new FlxSprite(xPos[counter], yPos[counter]);
				eye.frames = Paths.getSparrowAtlas("backgrounds/weirdmageddon/2d/eye");
				eye.animation.addByPrefix('eye', 'Eye instance 1', 20, false);
				eye.cameras = [game.camOther];
				add(eye);
				eye.animation.play('eye');

				gayTimer = FlxTimer.wait(0.2, () -> {
					FlxTween.tween(eye, {alpha: 0}, 0.5);
				});

				eye.animation.onFinish.add(function(name:String) {
					remove(eye);
				});
			case "light":
				floor2d.shader = monochrome;
				sky2d.shader = monochrome;
				pyramid2d.shader = monochrome;
				mountains2d.shader = monochrome;
				forest2d.shader = monochrome;
				monochrome.data.grayAmount.value = [1];
				FlxTween.tween(black, {alpha: 0}, 0.3);
			case "lightnorm":
				FlxTween.tween(black, {alpha: 0}, 0.1);
			case "prepop":
				pop = true;
				bubble.animation.play('pop');
				bubble.x -= 247;
				bubble.y -= 247;
			case "pop":
				game.dad.playAnim("what", true);
				dad.specialAnim = true;
				FlxTween.num(1, 0, 0.3, {ease: FlxEase.quadOut}, function(v:Float) {
					monochrome.data.grayAmount.value = [v];
				});
			case "glow":
				red.alpha = 1;
				FlxTween.tween(red, {alpha: 0}, 0.5);
			case "almost":
				FlxTween.tween(white, {alpha: 0.8}, 0.9);
			case "3d":
				health = 1;
				black.alpha = 0;
				white.alpha = 1;
				FlxTween.tween(white, {alpha: 0}, 0.3);
				angry = true;
				sky2d.visible = false;
				pyramid2d.visible = false;
				mountains2d.visible = false;
				bubble.visible = false;
				forest2d.visible = false;
				floor2d.visible = false;

				sky3d.visible = true;
				floats3d.visible = true;
				street3d.visible = true;
				gfGroup.visible = true;
				overlay.alpha = 0.3;

				boyfriendGroup.scrollFactor.set(1, 1);

				dadGroup.x = 460;
				dadGroup.y = -170;
				boyfriendGroup.x = 725;
				boyfriendGroup.y = 155;

				opponentCameraOffset[0] = 670;
				opponentCameraOffset[1] = 300;
				boyfriendCameraOffset[0] = 0;
				boyfriendCameraOffset[1] = -120;
				girlfriendCameraOffset[0] = -300;
				girlfriendCameraOffset[1] = -400;
				boyfriend.shader = null;

				game.triggerEventNote('Change Character', 'bf', 'billie_emotional');
				game.triggerEventNote('Change Character', 'dad', 'billred');

				iconP1.changeIcon('yuri');
				iconP2.changeIcon('billsmad');
				playHUD.healthBarFG.loadGraphic(Paths.image('ui/global/healthbarFG_evil'));
				healthBar.setColors(FlxColor.fromRGB(255, 72, 72), boyfriend.healthColour);
				// rimBillie = new DropShadowShader();
				rimBillie.setAdjustColor(-20, -22, -16, -10);
				rimBillie.color = 0xFF7272;
				rimBillie.angle = 140;
				boyfriend.shader = rimBillie;
				rimBillie.attachedSprite = boyfriend;
				boyfriend.animation.onFrameChange.add(function() {
					if (rimBillie.attachedSprite != null)
					{
						rimBillie.updateFrameInfo(boyfriend.frame);
					}
				});
			case '3dgray':
				sky3d.shader = monochrome;
				floats3d.shader = monochrome;
				street3d.shader = monochrome;
				FlxTween.num(0, 1, 0.4, {ease: FlxEase.quadInOut}, function(v:Float) {
					monochrome.data.grayAmount.value = [v];
				});
			case '3dnorm':
				white.alpha = 1;
				white.scale.set(3, 3);
				white.cameras = [camGame];
				monochrome.data.grayAmount.value = [0];
				FlxTween.tween(white, {alpha: 0}, 0.3);
			case "leave":
				leave = true;
				game.dad.playAnim("leave", true);
				game.dad.specialAnim = true;
				game.dad.skipDance = true;

				rays.visible = true;
				whiteglow.visible = true;
				FlxTween.num(0, 1.5, 1.1, {ease: FlxEase.quadOut}, function(v:Float) {
					rays.scale.set(v, v);
					if (v < 1.1) rays.alpha = v;
				});
				FlxTween.num(0, 1, 1.2, {ease: FlxEase.quadOut}, function(v:Float) {
					whiteglow.scale.set(v, v);
				});
			case "leave2":
				var leaveTimer:FlxTimer = null;
				white.alpha = 0.05;
				FlxTween.num(1, 10, 0.8, {ease: FlxEase.quadIn}, function(v:Float) {
					whiteglow.scale.set(v, v);
					white.alpha = v / 10;
					if (Difficulty.getCurDifficulty().toUpperCase() != "FRIGHTFUL")
					{
						modManager.setValue("alpha0", v / 10, 0);
						modManager.setValue("alpha1", v / 10, 0);
					}
				});

				for (i in [playHUD.scoreTxt, playHUD.healthBar, playHUD.iconP1, playHUD.iconP2])
				{
					FlxTween.tween(i, {alpha: 0}, 0.8, {ease: FlxEase.quadIn});
				}

				gayTimer = FlxTimer.wait(0.9, () -> {
					white.alpha = 1;
					rays.visible = false;
					whiteglow.visible = false;
					dadGroup.visible = false;
					iconP2.visible = false;
					// game.camHUD.alpha = 0;
					FlxTween.tween(white, {alpha: 0}, 0.4);

					for (item in boyfriendGroup.members)
						item.shader = null;
					for (item in gfGroup.members)
						item.shader = null;
				});

				gayTimer = FlxTimer.wait(1.9, () -> {
					FlxTween.num(0, 1, 0.8, {ease: FlxEase.quadOut}, function(v:Float) {
						if (Difficulty.getCurDifficulty().toUpperCase() != "FRIGHTFUL")
						{
							modManager.setValue("alpha2", v, 0);
							modManager.setValue("alpha3", v, 0);
						}
						else
						{
							modManager.setValue("alpha0", v, 0);
							modManager.setValue("alpha1", v, 0);
							modManager.setValue("alpha2", v, 0);
							modManager.setValue("alpha3", v, 0);
						}
					});
				});
			case "down":
				FlxTween.tween(boyfriendGroup, {y: boyfriendGroup.y + 1300}, 5.5, {ease: FlxEase.quadIn});
				FlxTween.tween(gfGroup, {y: gfGroup.y + 1300}, 5.5, {ease: FlxEase.quadIn});
				FlxTween.tween(street3d, {y: street3d.y + 1300}, 5.5, {ease: FlxEase.quadIn});
				FlxTween.tween(floats3d, {y: floats3d.y + 1200}, 6, {ease: FlxEase.quartIn});

				gayTimer = FlxTimer.wait(2.5, () -> {
					FlxTween.tween(black, {alpha: 1}, 1.3);
				});
		}
	}
}

function billCutscene()
{
	inCutscene = true;
}

function onCountdownStarted()
{
	modManager.setValue("alpha", 1, 1);
}

var singAnimations = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

function goodNoteHit(note:Note)
{
	if (note.noteType == 'Note Type Shit')
	{
		gf.holdTimer = 0;
		gf.playAnim(singAnimations[note.noteData], true);
	}

	if (angry)
	{
		if (note.noteType == 'GF Sing')
		{
			playerStrums.owner = gf;
			if (mustHitSection)
			{
				opponentCameraOffset[0] = 250;
				opponentCameraOffset[1] = -160;
			}
			// WE NEED A REWRITE OF THE CAMERA SYSTEM SO BADLY - Orbyy
		}
		else
		{
			playerStrums.owner = boyfriend;
			if (mustHitSection)
			{
				opponentCameraOffset[0] = 250;
				opponentCameraOffset[1] = -160;
			}
		}
	}
}

function opponentNoteHit(note)
{
	if (angry)
	{
		if (health > 0.5 && !note.isSustainNote)
		{
			health -= 0.030;
		}
	}
}

function onUpdatePost(elapsed:Float)
{
	if (!inCutscene) return; // yo chloe did all this

	if (!isStoryMode)
	{
		if (skipEnter.ACCEPT) endIntro(); // no nvm
	}
}

function endIntro()
{
	FlxTween.tween(black, {alpha: 0}, 1);
	introVid.stop();
	introVid.destroy();
	inCutscene = false;
	skipEnter = null;
	game.startCountdown();

	if (skip != null) skip.destroy();
	skipCountdown = true;
}

function onEndSong()
{
	if (isStoryMode) OverworldState.curCutscene = 'ending';
}
