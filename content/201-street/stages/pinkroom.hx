import funkin.data.Chart;
import funkin.backend.SyncedFlxSoundGroup;
import funkin.game.huds.PinkHUD;

var bg:FlxSprite;
var gayHitbox:FlxSprite;
var blackScreen:FlxSprite;
var ifthisdoesntgetreplacedsomeonefuckedup:Bool = true;
var canClick:Bool = false;
var clickedLight:Bool = false;

function onLoad()
{
	bg = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/pink-sea/room"));
	bg.setGraphicSize(Std.int(bg.width * 6));
	bg.antialiasing = false;
	add(bg);

	blackScreen = new FlxSprite(0, 0).makeGraphic(960, 720, FlxColor.BLACK);
	blackScreen.alpha = 0;
	blackScreen.cameras = [camHUD];
	add(blackScreen);

	skipCountdown = true;
}

function onCreatePost()
{
	FlxG.scaleMode.width = 960;
	FlxG.camera.width = 960;
	camHUD.width = 960;

	playHUD.kill();
	playHUD = new PinkHUD(PlayState.instance);
	playHUD.cameras = [camHUD];
	insert(members.indexOf(playFields), playHUD);

	playHUD.healthBar.screenCenter(FlxAxes.X);
	playHUD.scoreTxt.screenCenter(FlxAxes.X);
	playHUD.flipBar();
	playHUD.reloadHealthBarColors();

	snapCamToPos(bg.x + (bg.width / 2) + (960 / 6), bg.y + (bg.height / 2) + 10, true);
	FlxG.camera.pixelPerfectRender = true;

	modManager.setValue("transformX", -75, 0);
	modManager.setValue("transformX", 75, 1);
	modManager.setValue("opponentSwap", 1);

	if (isStoryMode)
	{
		canClick = true;
		FlxG.mouse.visible = true;
		FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursor").bitmap, 0.325);

		gayHitbox = new FlxSprite(bg.x + 260, bg.y - 320).makeGraphic(100, 175, FlxColor.RED);
		gayHitbox.visible = false;
		add(gayHitbox);
	}
}

function onUpdate(elapsed)
{
	if (gayHitbox != null && FlxG.mouse.overlaps(gayHitbox) && canClick)
	{
		FlxG.mouse.load(Paths.image("overworld/ui/cursor/click").bitmap, 0.325);
		if (FlxG.mouse.justPressed)
		{
			if (FlxG.save.data.songsBeaten.contains('pink-sea') != true)
			{
				PlayState.storyMeta.playlist = ['pink-sea', 'black-sea'];
				blackScreen.alpha = 1;
				FlxTween.tween(blackScreen, {alpha: 0}, 1);
				FlxG.sound.play(Paths.sound('lightswitch'));
				clickedLight = true;
				songEndCallback = blackSeaTransition;
			}
			else
			{
				loadBlackSea();
			}
			canClick = false;
			FlxG.mouse.visible = false;
		}
	}
	else
	{
		FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursor").bitmap, 0.325);
	}

	camZooming = false;
}

function onDestroy()
{
	FlxG.camera.pixelPerfectRender = false;
	FlxG.mouse.visible = false;

	FlxG.scaleMode.width = 1280;
	FlxG.camera.width = 1280;
}

function blackSeaTransition()
{
	FlxG.sound.play(Paths.sound('lightswitch'), 1);
	camGame.alpha = 0;
	camHUD.alpha = 0;
	new FlxTimer().start(2, function(tmr:FlxTimer) {
		endSong();
	});
}

function loadBlackSea()
{
	FlxG.sound.play(Paths.sound('lightswitch'));
	new FlxTimer().start(1.5, function(tmr:FlxTimer) {
		FlxG.resetState();
	});
	PlayState.SONG = Chart.fromSong("Black-Sea", PlayState.storyMeta.difficulty);
	paused = true;
	canPause = false;
	for (i in [camGame, camHUD, FlxG.mouse])
	{
		i.visible = false;
	}
	set_volumeMult(0); // setting vocals.volume = 0 doesn't work idk why
}

function onEndSong()
{
	if (isStoryMode) OverworldState.curCutscene = 'dream_exit';
}
