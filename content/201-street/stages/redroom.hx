var blackScreen:FlxSprite;

// 0.625

function onLoad()
{
	var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("backgrounds/black-sea/background"));
	add(bg);

	blackScreen = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK);
	// blackScreen.visible = false;
	blackScreen.cameras = [camOther];
	add(blackScreen);

	skipCountdown = true;
}

function onCreatePost()
{
	modManager.setValue("opponentSwap", 1);
	game.playHUD.flipBar();
	game.playHUD.reloadHealthBarColors();
	playHUD.healthBarFG.loadGraphic(Paths.image('ui/global/healthbarFG_evil'));

	game.snapCamToPos(1100, 625, true);
}

function onEvent(eventName, value1, value2)
{
	switch (eventName)
	{
		case 'black sea events':
			trace('temp');
		case 'blackscreen':
			// Value 1: Target Alpha Value
			// Value 2: Time,Ease
			// If value 2 is blank it'll instantly set the alpha instead

			var targetAlpha = Std.parseFloat(value1);
			var tween = value2.split(',');

			var time = Std.parseFloat(tween[0]);
			var easingMethod = CoolUtil.getEaseFromString(tween[1]);

			if (value2 == '')
			{
				blackScreen.alpha = targetAlpha;
			}
			else
			{
				FlxTween.tween(blackScreen, {alpha: targetAlpha}, time, {ease: easingMethod});
			}
	}
}

function onEndSong(){
	if(isStoryMode) OverworldState.curCutscene = 'dream_exit_evil';
}