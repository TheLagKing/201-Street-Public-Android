import funkin.game.huds.PKMNHUD;
import openfl.filters.ShaderFilter;

var glitchdistort:FlxShader;
var glitchfilter:ShaderFilter;
var glitch = false;
var healthDrain = false;
var blackScreen:FlxSprite;

function onLoad()
{
	var bg = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/pkmn/ghost_bg"));
	bg.setGraphicSize(Std.int(bg.width * 5));
	bg.updateHitbox();
	bg.antialiasing = false;
	add(bg);

	blackScreen = new FlxSprite(0, 0).makeGraphic(800, 720, FlxColor.BLACK);
	blackScreen.cameras = [camOther];
	add(blackScreen);

	skipCountdown = true;
}

function onCreatePost()
{
	FlxG.scaleMode.width = 800;
	FlxG.camera.width = 800;
	game.camHUD.width = 800;

	snapCamToPos(639, 359, true);

	var strumYpos:Int = !ClientPrefs.downScroll ? -30 : 15;

	modManager.setValue("transformY", strumYpos, 0);
	modManager.setValue("alpha", 1, 1);
	modManager.setValue("transform0X", 136, 0);
	modManager.setValue("transform1X", 119, 0);
	modManager.setValue("transform2X", 102, 0);
	modManager.setValue("transform3X", 85, 0);

	if (ClientPrefs.downScroll)
	{
		boyfriendGroup.y -= 45;
		dadGroup.y -= 45;
	}

	glitchdistort = newShader('glitch');
	glitchdistort.data.time.value = [0];
	glitchdistort.setFloat('u_alpha', 1.0);

	glitchfilter = new ShaderFilter(glitchdistort);

	FlxG.camera.pixelPerfectRender = true;

	// overwrite the default hud with a different class we want to use ! (I prefer hardcoding huds in this engine so this works for me)
	playHUD.kill();
	playHUD = new PKMNHUD(PlayState.instance);
	playHUD.cameras = [camHUD];
	insert(members.indexOf(playFields), playHUD);

	dad.alpha = 0;

	startTimer = new FlxTimer().start(0.25, function(tmr:FlxTimer) {
		if (tmr.loopsLeft < 4)
		{
			blackScreen.alpha -= 0.25;
		}
	}, 4);
}

var gayValue1:Float = 0.1;
var gayValue2:Float = 0.2;

function onUpdate(elapsed)
{
	camZooming = false;

	if (glitch)
	{
		glitchdistort.data.time.value = [Conductor.songPosition / 1000];
		glitchdistort.data.prob.value = [FlxG.random.float(gayValue1, gayValue2)];
	}

	if (healthDrain && health > 1) health = 1;
}

function opponentNoteHit(note)
{
	if (healthDrain)
	{
		if (health > 0.5 && !note.isSustainNote)
		{
			health -= 0.035;
		}
	}
}

function onEvent(name, v1, v2)
{
	if (name == "Pokemon Events")
	{
		switch (v1)
		{
			case "glitch":
				switch (v2)
				{
					case 'on':
						if (ClientPrefs.flashing)
						{
							camGame.filters = [glitchfilter];
							glitch = true;
						}
					case 'off':
						if (ClientPrefs.flashing)
						{
							camGame.filters = [];
							glitch = false;
						}
					case 'gay':
						gayValue1 = 0.25;
						gayValue2 = 0.5;
				}
			case 'health gone':
				health = 0.5;
				healthDrain = true;
			case 'ghost fade':
				startTimer = new FlxTimer().start(0.25, function(tmr:FlxTimer) {
					if (tmr.loopsLeft < 4)
					{
						dad.alpha += 0.25;
					}
				}, 4);
			case 'blackscreen':
				blackScreen.alpha = blackScreen.alpha == 1 ? blackScreen.alpha = 0 : blackScreen.alpha = 1;
		}
	}
}

function onDestroy()
{
	FlxG.camera.pixelPerfectRender = false;
	FlxG.scaleMode.width = 1280;
	FlxG.camera.width = 1280;
	camGame.filters = [];
}

function onGameOverStart()
{
	camGame.filters = [];
}

function onEndSong()
{
	if (isStoryMode) OverworldState.curCutscene = 'pokemon_exit';
}
