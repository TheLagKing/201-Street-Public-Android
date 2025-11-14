import funkin.game.shaders.DropShadowShader;
import funkin.game.huds.EBHUD;

var bg:FlxSprite;
var psi_bg:FlxSprite;
var scaleyy:Float = 1.8;
var momoKO:FlxSprite;
var okarunKick:Character;

// UI SHIT
var char_starman:FlxSprite;
var char_billie:FlxSprite;
var char_okarun:FlxSprite;
var char_momo:FlxSprite;
var char_leticia:FlxSprite;
var party_box:FlxSprite;
var party_counters:FlxSprite;
var party_names:FlxSprite;

// billie counters
var billie_counter:Array = [0, 9, 0];
var billie_tenth:FlxSprite;
var billie_ones:FlxSprite;

// starman counters
var starman_counterHP:Array = [5, 4, 5];
var starman_counterPP:Array = [0, 9, 9];
var starman_hundredthsHP:FlxSprite;
var starman_tenthHP:FlxSprite;
var starman_onesHP:FlxSprite;
var starman_tenthPP:FlxSprite;
var starman_onesPP:FlxSprite;

// okarun's PP hehehe PP
var okarun_counterPP:Array = [0, 0, 0];
var okarun_hundredthsPP:FlxSprite;
var okarun_tenthPP:FlxSprite;
var okarun_onesPP:FlxSprite;
var psi:Character;
var psiShield:Character;
var red:FlxSprite;
var smash:FlxSprite;
var locked:Bool = false;
var rimBf;
var rimGf;
var black:FlxSprite;
var box;
var starname;

function onLoad()
{
	bg = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/starbound/bg"));
	bg.scale.set(scaleyy, scaleyy);
	add(bg);

	momoKO = new FlxSprite(290, 210);
	momoKO.frames = Paths.getSparrowAtlas("backgrounds/starbound/momoKO");
	momoKO.animation.addByPrefix('idle', 'Momo KO', 24, true);
	momoKO.animation.play('idle');
	add(momoKO);

	psi_bg = new FlxSprite(570, 300);
	psi_bg.frames = Paths.getSparrowAtlas("backgrounds/starbound/starmanbg");
	psi_bg.antialiasing = false;
	psi_bg.setGraphicSize(Std.int(psi_bg.width * 10));
	psi_bg.animation.addByPrefix('idle', 'bg', 24, true);
	psi_bg.animation.play('idle');
	psi_bg.alpha = 0;
	add(psi_bg);

	psi = new Character(20, 300, 'starmanPSI', false);
	add(psi);

	red = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
	red.setGraphicSize(Std.int(bg.width));
	red.scale.set(scaleyy, scaleyy);
	red.alpha = 0;
	add(red);

	if (isStoryMode) songEndCallback = cutscene_ending;
}

function onCreatePost()
{
	game.isCameraOnForcedPos = true;
	// game.camFollow.x = 700; og cam positions
	// game.camFollow.y = 420;
	// game.defaultCamZoom = 0.6;

	game.camFollow.x = 300;
	game.camFollow.y = 100;
	game.defaultCamZoom = 1.9;
	dad.visible = false;
	boyfriend.visible = false;
	gf.visible = false;
	momoKO.visible = false;
	psi.visible = false;
	camHUD.alpha = 0;

	skipCountdown = true;
	modManager.setValue("alpha", 1, 1);
	opponentStrums.owner = psi;

	psiShield = new Character(20, 300, 'starmanPSI', false);
	add(psiShield);
	psiShield.visible = false;

	okarunKick = new Character(2000, 160, 'okarun_kick', false);
	add(okarunKick);

	smash = new FlxSprite(350, 200).loadGraphic(Paths.image("ui/starbound/smash"));
	smash.setGraphicSize(Std.int(smash.width * 10));
	smash.antialiasing = false;
	smash.updateHitbox();
	smash.alpha = 0;
	add(smash);

	barTop = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(75), FlxColor.BLACK);
	barTop.y = -75;
	barTop.screenCenter(FlxAxes.X);
	barTop.cameras = [game.camHUD];
	barBottom = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(75), FlxColor.BLACK);
	barBottom.screenCenter(FlxAxes.X);
	barBottom.cameras = [game.camHUD];
	barBottom.y = 795;
	add(barTop);
	add(barBottom);

	// your days are numbered jcjack
	// score text
	var score = new FlxSprite(225, 610).loadGraphic(Paths.image("ui/starbound/score"));
	score.y = !ClientPrefs.downScroll ? 610 : 70;
	score.setGraphicSize(Std.int(score.width * 2));
	score.updateHitbox();
	score.antialiasing = false;
	score.cameras = [game.camHUD];
	add(score);

	var misses = new FlxSprite(225, 650).loadGraphic(Paths.image("ui/starbound/misses"));
	misses.setGraphicSize(Std.int(misses.width * 2));
	misses.y = !ClientPrefs.downScroll ? 650 : 110;
	misses.updateHitbox();
	misses.antialiasing = false;
	misses.cameras = [game.camHUD];
	add(misses);

	// starman
	char_starman = new FlxSprite(70, 513).loadGraphic(Paths.image("ui/starbound/chars/starman"));
	char_starman.y = !ClientPrefs.downScroll ? 513 : 20;
	char_starman.setGraphicSize(Std.int(char_starman.width * 2));
	char_starman.updateHitbox();
	char_starman.antialiasing = false;
	char_starman.cameras = [game.camHUD];
	add(char_starman);

	box = new FlxSprite(30, 550);
	box.y = !ClientPrefs.downScroll ? 550 : 60;
	box.frames = Paths.getSparrowAtlas("ui/starbound/fuck");
	box.animation.addByPrefix('idle', 'normal', 1, false);
	box.animation.addByPrefix('down', 'down', 1, false);
	box.setGraphicSize(Std.int(box.width * 2));
	box.updateHitbox();
	box.antialiasing = false;
	box.animation.play('idle');
	box.cameras = [game.camHUD];
	add(box);

	starname = new FlxSprite(55, 575);
	starname.y = !ClientPrefs.downScroll ? 575 : 85;
	starname.frames = Paths.getSparrowAtlas("ui/starbound/names/starman");
	starname.animation.addByPrefix('idle', 'normal', 1, false);
	starname.animation.addByPrefix('down', 'down', 1, false);
	starname.setGraphicSize(Std.int(starname.width * 2));
	starname.updateHitbox();
	starname.antialiasing = false;
	starname.animation.play('idle');
	starname.cameras = [game.camHUD];
	add(starname);

	// PSYCHO BASTARD AT WORK
	char_billie = new FlxSprite(767, 503).loadGraphic(Paths.image("ui/starbound/chars/billie"));
	char_billie.y = !ClientPrefs.downScroll ? 503 : 20;
	char_billie.setGraphicSize(Std.int(char_billie.width * 2));
	char_billie.updateHitbox();
	char_billie.antialiasing = false;
	char_billie.cameras = [game.camHUD];
	add(char_billie);

	char_okarun = new FlxSprite(877, 503).loadGraphic(Paths.image("ui/starbound/chars/okarun"));
	char_okarun.y = !ClientPrefs.downScroll ? 503 : 20;
	char_okarun.setGraphicSize(Std.int(char_okarun.width * 2));
	char_okarun.updateHitbox();
	char_okarun.antialiasing = false;
	char_okarun.cameras = [game.camHUD];
	add(char_okarun);

	char_turbokarun = new FlxSprite(877, 553).loadGraphic(Paths.image("ui/starbound/chars/turbookarun"));
	char_turbokarun.y = !ClientPrefs.downScroll ? 553 : 70;
	char_turbokarun.setGraphicSize(Std.int(char_turbokarun.width * 2));
	char_turbokarun.updateHitbox();
	char_turbokarun.antialiasing = false;
	char_turbokarun.cameras = [game.camHUD];
	add(char_turbokarun);

	char_momo = new FlxSprite(987, 503).loadGraphic(Paths.image("ui/starbound/chars/momo"));
	char_momo.y = !ClientPrefs.downScroll ? 503 : 20;
	char_momo.setGraphicSize(Std.int(char_momo.width * 2));
	char_momo.updateHitbox();
	char_momo.antialiasing = false;
	char_momo.cameras = [game.camHUD];
	add(char_momo);

	char_leticia = new FlxSprite(1095, 503).loadGraphic(Paths.image("ui/starbound/chars/leticia"));
	char_leticia.y = !ClientPrefs.downScroll ? 503 : 20;
	char_leticia.setGraphicSize(Std.int(char_leticia.width * 2));
	char_leticia.updateHitbox();
	char_leticia.antialiasing = false;
	char_leticia.cameras = [game.camHUD];
	add(char_leticia);

	party_box = new FlxSprite(726, 550).loadGraphic(Paths.image("ui/starbound/party_box"));
	party_box.y = !ClientPrefs.downScroll ? 550 : 60;
	party_box.setGraphicSize(Std.int(party_box.width * 2));
	party_box.updateHitbox();
	party_box.antialiasing = false;
	party_box.cameras = [game.camHUD];
	add(party_box);

	party_counters = new FlxSprite(726, 550).loadGraphic(Paths.image("ui/starbound/party_counters"));
	party_counters.y = !ClientPrefs.downScroll ? 550 : 60;
	party_counters.setGraphicSize(Std.int(party_counters.width * 2));
	party_counters.updateHitbox();
	party_counters.antialiasing = false;
	party_counters.cameras = [game.camHUD];
	add(party_counters);

	party_names = new FlxSprite(726, 550).loadGraphic(Paths.image("ui/starbound/party_names"));
	party_names.y = !ClientPrefs.downScroll ? 550 : 60;
	party_names.setGraphicSize(Std.int(party_names.width * 2));
	party_names.updateHitbox();
	party_names.antialiasing = false;
	party_names.cameras = [game.camHUD];
	add(party_names);

	// ROLLING COUNTERS

	// starman
	starman_hundredthsHP = new FlxSprite(78, 598);
	starman_hundredthsHP.y = !ClientPrefs.downScroll ? 598 : 108;
	starman_hundredthsHP.frames = Paths.getSparrowAtlas("ui/starbound/numbers");
	starman_hundredthsHP.setGraphicSize(Std.int(starman_hundredthsHP.width * 2));
	starman_hundredthsHP.updateHitbox();
	starman_hundredthsHP.antialiasing = false;
	starman_hundredthsHP.cameras = [game.camHUD];
	add(starman_hundredthsHP);

	starman_tenthHP = new FlxSprite(94, 598);
	starman_tenthHP.y = !ClientPrefs.downScroll ? 598 : 108;
	starman_tenthHP.frames = Paths.getSparrowAtlas("ui/starbound/numbers");
	starman_tenthHP.setGraphicSize(Std.int(starman_tenthHP.width * 2));
	starman_tenthHP.updateHitbox();
	starman_tenthHP.antialiasing = false;
	starman_tenthHP.cameras = [game.camHUD];
	add(starman_tenthHP);

	starman_onesHP = new FlxSprite(110, 598);
	starman_onesHP.y = !ClientPrefs.downScroll ? 598 : 108; //
	starman_onesHP.frames = Paths.getSparrowAtlas("ui/starbound/numbers");
	starman_onesHP.setGraphicSize(Std.int(starman_onesHP.width * 2));
	starman_onesHP.updateHitbox();
	starman_onesHP.antialiasing = false;
	starman_onesHP.cameras = [game.camHUD];
	add(starman_onesHP);

	starman_tenthPP = new FlxSprite(94, 630);
	starman_tenthPP.y = !ClientPrefs.downScroll ? 630 : 140;
	starman_tenthPP.frames = Paths.getSparrowAtlas("ui/starbound/numbers");
	starman_tenthPP.setGraphicSize(Std.int(starman_tenthPP.width * 2));
	starman_tenthPP.updateHitbox();
	starman_tenthPP.antialiasing = false;
	starman_tenthPP.cameras = [game.camHUD];
	add(starman_tenthPP);

	starman_onesPP = new FlxSprite(110, 630);
	starman_onesPP.y = !ClientPrefs.downScroll ? 630 : 140;
	starman_onesPP.frames = Paths.getSparrowAtlas("ui/starbound/numbers");
	starman_onesPP.setGraphicSize(Std.int(starman_onesPP.width * 2));
	starman_onesPP.updateHitbox();
	starman_onesPP.antialiasing = false;
	starman_onesPP.cameras = [game.camHUD];
	add(starman_onesPP);

	// okarun
	okarun_hundredthsPP = new FlxSprite(886, 630);
	okarun_hundredthsPP.y = !ClientPrefs.downScroll ? 630 : 140;
	okarun_hundredthsPP.frames = Paths.getSparrowAtlas("ui/starbound/numbers");
	okarun_hundredthsPP.setGraphicSize(Std.int(okarun_hundredthsPP.width * 2));
	okarun_hundredthsPP.updateHitbox();
	okarun_hundredthsPP.antialiasing = false;
	okarun_hundredthsPP.cameras = [game.camHUD];
	add(okarun_hundredthsPP);

	okarun_tenthPP = new FlxSprite(902, 630);
	okarun_tenthPP.y = !ClientPrefs.downScroll ? 630 : 140;
	okarun_tenthPP.frames = Paths.getSparrowAtlas("ui/starbound/numbers");
	okarun_tenthPP.setGraphicSize(Std.int(okarun_tenthPP.width * 2));
	okarun_tenthPP.updateHitbox();
	okarun_tenthPP.antialiasing = false;
	okarun_tenthPP.cameras = [game.camHUD];
	add(okarun_tenthPP);

	okarun_onesPP = new FlxSprite(918, 630);
	okarun_onesPP.y = !ClientPrefs.downScroll ? 630 : 140;
	okarun_onesPP.frames = Paths.getSparrowAtlas("ui/starbound/numbers");
	okarun_onesPP.setGraphicSize(Std.int(okarun_onesPP.width * 2));
	okarun_onesPP.updateHitbox();
	okarun_onesPP.antialiasing = false;
	okarun_onesPP.cameras = [game.camHUD];
	add(okarun_onesPP);

	// billie
	billie_tenth = new FlxSprite(790, 598);
	billie_tenth.y = !ClientPrefs.downScroll ? 598 : 108;
	billie_tenth.frames = Paths.getSparrowAtlas("ui/starbound/numbers");
	billie_tenth.setGraphicSize(Std.int(billie_tenth.width * 2));
	billie_tenth.updateHitbox();
	billie_tenth.antialiasing = false;
	billie_tenth.cameras = [game.camHUD];
	add(billie_tenth);

	billie_ones = new FlxSprite(806, 598);
	billie_ones.y = !ClientPrefs.downScroll ? 598 : 108;
	billie_ones.frames = Paths.getSparrowAtlas("ui/starbound/numbers");
	billie_ones.setGraphicSize(Std.int(billie_ones.width * 2));
	billie_ones.updateHitbox();
	billie_ones.antialiasing = false;
	billie_ones.cameras = [game.camHUD];
	add(billie_ones);

	for (i in 0...10) // im a genius!
	{
		billie_tenth.animation.addByPrefix(Std.string(i) + '-', Std.string(i) + '-', 1, false); // number
		billie_tenth.animation.addByIndices(Std.string(i) + 'trans-up', Std.string(i) + 'trans', [0, 1, 2, 3, 4, 5], "", 48, false); // transition up
		billie_tenth.animation.addByIndices(Std.string(i) + 'trans-down', Std.string(i) + 'trans', [5, 4, 3, 2, 1, 0], "", 48, false); // transition down
		billie_ones.animation.addByPrefix(Std.string(i) + '-', Std.string(i) + '-', 1, false); // number
		billie_ones.animation.addByIndices(Std.string(i) + 'trans-up', Std.string(i) + 'trans', [0, 1, 2, 3, 4, 5], "", 48, false); // transition up
		billie_ones.animation.addByIndices(Std.string(i) + 'trans-down', Std.string(i) + 'trans', [5, 4, 3, 2, 1, 0], "", 48, false); // transition down
		starman_hundredthsHP.animation.addByPrefix(Std.string(i) + '-', Std.string(i) + '-', 1, false); // number
		starman_hundredthsHP.animation.addByIndices(Std.string(i) + 'trans-up', Std.string(i) + 'trans', [0, 1, 2, 3, 4, 5], "", 48, false); // transition up
		starman_hundredthsHP.animation.addByIndices(Std.string(i) + 'trans-down', Std.string(i) + 'trans', [5, 4, 3, 2, 1, 0], "", 48,
			false); // transition down
		starman_tenthHP.animation.addByPrefix(Std.string(i) + '-', Std.string(i) + '-', 1, false); // number
		starman_tenthHP.animation.addByIndices(Std.string(i) + 'trans-up', Std.string(i) + 'trans', [0, 1, 2, 3, 4, 5], "", 48, false); // transition up
		starman_tenthHP.animation.addByIndices(Std.string(i) + 'trans-down', Std.string(i) + 'trans', [5, 4, 3, 2, 1, 0], "", 48, false); // transition down
		starman_onesHP.animation.addByPrefix(Std.string(i) + '-', Std.string(i) + '-', 1, false); // number
		starman_onesHP.animation.addByIndices(Std.string(i) + 'trans-up', Std.string(i) + 'trans', [0, 1, 2, 3, 4, 5], "", 48, false); // transition up
		starman_onesHP.animation.addByIndices(Std.string(i) + 'trans-down', Std.string(i) + 'trans', [5, 4, 3, 2, 1, 0], "", 48, false); // transition down
		starman_tenthPP.animation.addByPrefix(Std.string(i) + '-', Std.string(i) + '-', 1, false); // number
		starman_tenthPP.animation.addByIndices(Std.string(i) + 'trans-up', Std.string(i) + 'trans', [0, 1, 2, 3, 4, 5], "", 48, false); // transition up
		starman_tenthPP.animation.addByIndices(Std.string(i) + 'trans-down', Std.string(i) + 'trans', [5, 4, 3, 2, 1, 0], "", 48, false); // transition down
		starman_onesPP.animation.addByPrefix(Std.string(i) + '-', Std.string(i) + '-', 1, false); // number
		starman_onesPP.animation.addByIndices(Std.string(i) + 'trans-up', Std.string(i) + 'trans', [0, 1, 2, 3, 4, 5], "", 48, false); // transition up
		starman_onesPP.animation.addByIndices(Std.string(i) + 'trans-down', Std.string(i) + 'trans', [5, 4, 3, 2, 1, 0], "", 48, false); // transition down
		okarun_hundredthsPP.animation.addByPrefix(Std.string(i) + '-', Std.string(i) + '-', 1, false); // number
		okarun_hundredthsPP.animation.addByIndices(Std.string(i) + 'trans-up', Std.string(i) + 'trans', [0, 1, 2, 3, 4, 5], "", 48, false); // transition up
		okarun_hundredthsPP.animation.addByIndices(Std.string(i) + 'trans-down', Std.string(i) + 'trans', [5, 4, 3, 2, 1, 0], "", 48, false); // transition down
		okarun_tenthPP.animation.addByPrefix(Std.string(i) + '-', Std.string(i) + '-', 1, false); // number
		okarun_tenthPP.animation.addByIndices(Std.string(i) + 'trans-up', Std.string(i) + 'trans', [0, 1, 2, 3, 4, 5], "", 48, false); // transition up
		okarun_tenthPP.animation.addByIndices(Std.string(i) + 'trans-down', Std.string(i) + 'trans', [5, 4, 3, 2, 1, 0], "", 48, false); // transition down
		okarun_onesPP.animation.addByPrefix(Std.string(i) + '-', Std.string(i) + '-', 1, false); // number
		okarun_onesPP.animation.addByIndices(Std.string(i) + 'trans-up', Std.string(i) + 'trans', [0, 1, 2, 3, 4, 5], "", 48, false); // transition up
		okarun_onesPP.animation.addByIndices(Std.string(i) + 'trans-down', Std.string(i) + 'trans', [5, 4, 3, 2, 1, 0], "", 48, false); // transition down
	}

	billie_tenth.animation.play(Std.string(billie_counter[1]) + '-');
	billie_ones.animation.play(Std.string(billie_counter[2]) + '-');
	starman_hundredthsHP.animation.play(Std.string(starman_counterHP[0]) + '-');
	starman_tenthHP.animation.play(Std.string(starman_counterHP[1]) + '-');
	starman_onesHP.animation.play(Std.string(starman_counterHP[2]) + '-');
	starman_tenthPP.animation.play(Std.string(starman_counterPP[1]) + '-');
	starman_onesPP.animation.play(Std.string(starman_counterPP[2]) + '-');
	okarun_hundredthsPP.animation.play(Std.string(okarun_counterPP[0]) + '-');
	okarun_tenthPP.animation.play(Std.string(okarun_counterPP[1]) + '-');
	okarun_onesPP.animation.play(Std.string(okarun_counterPP[2]) + '-');

	// there has to be a better way to do this
	rimBf = new DropShadowShader();
	rimBf.setAdjustColor(-30, -22, -16, -20);
	rimBf.color = 0x1BFFFF;
	rimBf.angle = 135;
	boyfriend.shader = rimBf;
	rimBf.attachedSprite = boyfriend;
	boyfriend.animation.onFrameChange.add(function() {
		rimBf.updateFrameInfo(boyfriend.frame);
	});
	rimGf = new DropShadowShader();
	rimGf.setAdjustColor(-30, -22, -16, -20);
	rimGf.color = 0x1BFFFF;
	rimGf.angle = 170;
	gf.shader = rimGf;
	rimGf.attachedSprite = gf;
	gf.animation.onFrameChange.add(function() {
		rimGf.updateFrameInfo(gf.frame);
	});
	var rimMomo = new DropShadowShader();
	rimMomo.setAdjustColor(-30, -22, -16, -20);
	rimMomo.color = 0x1BFFFF;
	rimMomo.angle = 35;
	momoKO.shader = rimMomo;
	rimMomo.attachedSprite = momoKO;
	momoKO.animation.onFrameChange.add(function() {
		rimMomo.updateFrameInfo(momoKO.frame);
	});
	var rimOkarun = new DropShadowShader();
	rimOkarun.setAdjustColor(-30, -22, -16, -20);
	rimOkarun.color = 0x1BFFFF;
	rimOkarun.angle = 35;
	okarunKick.shader = rimOkarun;
	rimOkarun.attachedSprite = okarunKick;
	okarunKick.animation.onFrameChange.add(function() {
		rimOkarun.updateFrameInfo(okarunKick.frame);
	});

	playHUD.kill();
	playHUD = new EBHUD(PlayState.instance);
	playHUD.cameras = [camHUD];
	insert(members.indexOf(playFields), playHUD);

	// remove for the intro
	black = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	black.cameras = [game.camOther];
	black.alpha = 1;
	add(black);
}

function goodNoteHit()
{
	if (billie_counter[1] != 9 && billie_counter[1] < 9)
	{
		if (billie_counter[2] == 9 && billie_counter[1] != 9)
		{
			billie_counter[1] = billie_counter[1] + 1; // tenth
			billie_tenth.animation.play(Std.string(billie_counter[1]) + 'trans-up');
			billie_counter[2] = 0; // ones
			billie_ones.animation.play(Std.string(billie_counter[2]) + 'trans-up');
			billie_tenth.animation.finishCallback = function(pog:String) {
				billie_tenth.animation.play(Std.string(billie_counter[1]) + '-');
			}
			billie_ones.animation.finishCallback = function(pog:String) {
				billie_ones.animation.play(Std.string(billie_counter[2]) + '-');
			}
		}
		else
		{ // oneth counter goes up
			billie_counter[2] = billie_counter[2] + 1;
			billie_ones.animation.play(Std.string(billie_counter[2]) + 'trans-up');
			billie_ones.animation.finishCallback = function(pog:String) {
				billie_ones.animation.play(Std.string(billie_counter[2]) + '-');
			}
		}
	}
}

function noteMiss()
{
	if (billie_counter[2] == 0 && billie_counter[1] != 0)
	{
		billie_tenth.animation.play(Std.string(billie_counter[1]) + 'trans-down');
		billie_counter[1] = billie_counter[1] - 1; // tenth
		billie_counter[2] = 9; // ones
		billie_ones.animation.play(Std.string(billie_counter[2]) + 'trans-down');
		billie_tenth.animation.finishCallback = function(pog:String) {
			billie_tenth.animation.play(Std.string(billie_counter[1]) + '-');
		}
		billie_ones.animation.finishCallback = function(pog:String) {
			billie_ones.animation.play(Std.string(billie_counter[2]) + '-');
		}
	}
	else
	{
		billie_ones.animation.play(Std.string(billie_counter[2]) + 'trans-down');
		billie_counter[2] = billie_counter[2] - 1;
		billie_ones.animation.finishCallback = function(pog:String) {
			if (billie_counter[1] <= 0 && billie_counter[2] <= 0)
			{
				game.health = 0;
			} // gameover
			billie_ones.animation.play(Std.string(billie_counter[2]) + '-');
		}
	}
}

function onStepHit()
{
	var anim:String = psi.animation.curAnim.name;
	if (locked)
	{
		if (anim == 'idle')
		{
			game.dad.playAnim("idle");
		}
		else
		{
			game.dad.playAnim("idle-alt");
		}
	}
}

function onUpdate()
{
	game.health = 2;
	var anim:String = psi.animation.curAnim.name;
	if (locked)
	{
		if (anim == 'idle')
		{
			psi.visible = false;
		}
		else
		{
			psi.visible = true;
		}
	}
}

function onEvent(name, v1, v2)
{
	if (name == "Events")
	{
		if (v1 == "intro")
		{
			if (v2 == "die")
			{
				FlxTween.tween(black, {alpha: 1}, 0.2);
			}
			if (v2 == "momo")
			{
				FlxTween.tween(black, {alpha: 0}, 0.2);
				momoKO.visible = true;
			}
			if (v2 == "ye")
			{
				FlxTween.tween(black, {alpha: 0}, 0.2);
			}
		}
		if (v1 == "return")
		{
			FlxG.camera.zoom = 0.6;
			game.defaultCamZoom = 0.6;
			game.camFollow.x = 700;
			game.camFollow.y = 420;
			game.isCameraOnForcedPos = true;
			new FlxTimer().start(1, () -> {
				FlxTween.tween(black, {alpha: 0}, 5);
			});
			boyfriend.visible = true;
			gf.visible = true;
		}
		if (v1 == "hi bro")
		{
			dad.visible = true;
			dad.playAnim("intro");
			dad.specialAnim = true;
			dad.animation.finishCallback = function(pog:String) {
				locked = true;
				psiShield.visible = true;
				psiShield.animation.play('shield');
				psiShield.specialAnim = true;
				psiShield.animation.finishCallback = function(pog:String) {
					psiShield.visible = false;
				}
			}
		}
		if (v1 == "hud time")
		{
			psi.visible = true;
			FlxTween.tween(camHUD, {alpha: 1}, 0.3);
		}
		if (v1 == "domain expansion")
		{
			if (v2 == "on")
			{
				FlxTween.tween(barTop, {y: 0}, 2);
				FlxTween.tween(barBottom, {y: 649}, 2);
				FlxTween.tween(psi_bg, {alpha: 1}, 2);
				for (item in boyfriendGroup.members)
					item.shader = null;
				for (item in gfGroup.members)
					item.shader = null;
			}
			else
			{
				FlxTween.tween(barTop, {y: -75}, 0.7);
				FlxTween.tween(barBottom, {y: 795}, 0.7);
				FlxTween.tween(psi_bg, {alpha: 0}, 0.7);
				boyfriend.shader = rimBf;
				rimBf.attachedSprite = boyfriend;
				boyfriend.animation.onFrameChange.add(function() {
					rimBf.updateFrameInfo(boyfriend.frame);
				});
				gf.shader = rimGf;
				rimGf.attachedSprite = gf;
				gf.animation.onFrameChange.add(function() {
					rimGf.updateFrameInfo(gf.frame);
				});
			}
		}
		if (v1 == "charge bro")
		{
			FlxG.sound.play(Paths.sound('transform bro'));
		}
		if (v1 == "YOU HURT MOMO CHAN") // foreshadowing...
		{
			if (!ClientPrefs.downScroll)
			{
				FlxTween.tween(char_okarun, {y: 553}, 0.1);
				FlxTween.tween(char_turbokarun, {y: 503}, 0.1);
			}
			else
			{
				FlxTween.tween(char_okarun, {y: 70}, 0.1);
				FlxTween.tween(char_turbokarun, {y: 20}, 0.1);
			}
		}
		if (v1 == "GOING ALL OUT")
		{
			FlxTween.tween(okarunKick, {x: 60}, 0.2,
				{ // okarun flies in
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween) {
						locked = false; // shield break start
						psi.visible = false;
						psiShield.visible = true;
						psiShield.animation.play('shatter');
						dad.animation.play('shatter');
						okarunKick.animation.play('impact-connect');
						FlxG.camera.shake(0.01, 0.1);
						okarunKick.updateHitbox();
						okarun_hundredthsPP.animation.play('1trans-up'); // okarun appears with his PP hehehe up
						okarun_hundredthsPP.animation.finishCallback = function(pog:String) {
							okarun_hundredthsPP.animation.play(Std.string('1-'));
						}
						okarun_tenthPP.animation.play('0trans-up');
						okarun_tenthPP.animation.finishCallback = function(pog:String) {
							okarun_tenthPP.animation.play(Std.string('0-'));
						}
						okarun_onesPP.animation.play('0trans-up');
						okarun_onesPP.animation.finishCallback = function(pog:String) {
							okarun_onesPP.animation.play(Std.string('0-'));
						}
						okarunKick.animation.finishCallback = function(pog:String) { // okarun lands, shield is breaking
							okarunKick.animation.play('impact');
							okarunKick.updateHitbox();
							psiShield.animation.finishCallback = function(pog:String) { // shield breaks
								FlxTween.tween(dad, {x: -1000}, 0.1, {ease: FlxEase.linear}); // starman flies away
								red.alpha = 1;
								FlxTween.tween(red, {alpha: 0}, 0.2);
								smash.alpha = 1;
								FlxG.camera.shake(0.01, 0.1);
								psiShield.alpha = 0;
								psi.alpha = 0;
								dad.animation.play('shatter-end');
								okarunKick.animation.play('flip');
								box.animation.play('down');
								starname.animation.play('down');
								starman_hundredthsHP.animation.play('0trans-down'); // starman HP goes down to 0
								starman_hundredthsHP.animation.finishCallback = function(pog:String) {
									starman_hundredthsHP.animation.play(Std.string('0-'));
								}
								starman_tenthHP.animation.play('0trans-down');
								starman_tenthHP.animation.finishCallback = function(pog:String) {
									starman_tenthHP.animation.play(Std.string('0-'));
								}
								starman_onesHP.animation.play('0trans-down');
								starman_onesHP.animation.finishCallback = function(pog:String) {
									starman_onesHP.animation.play(Std.string('0-'));
								}
								okarunKick.animation.finishCallback = function(pog:String) { // okarun flips then lands
									okarunKick.animation.play('land'); // w okarun <3 <3 <3
									okarunKick.updateHitbox();
									FlxTween.tween(smash, {alpha: 0}, 0.5);
									okarunKick.x = 793;
									okarunKick.y = 441;
								}
							}
						}
					}
				});
		}
		if(v1 == 'ending'){
			camGame.visible = false;
			camHUD.visible = false;
		}
	}
}

function cutscene_ending()
{
	canPause = false;
	endingSong = true;
	camZooming = false;
	inCutscene = false;
	updateTime = false;

	FlxG.sound.play(Paths.sound('post_starbound'));

	new FlxTimer().start(10, function(tmr:FlxTimer) {
		endSong();
	});
}

	
function onEndSong()
{
	if (isStoryMode) OverworldState.curCutscene = 'post_dandadan';
}
