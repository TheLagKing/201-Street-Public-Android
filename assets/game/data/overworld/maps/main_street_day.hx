import funkin.states.TitleState201;

function onLoad()
{
	FlxG.mouse.visible = false;
}

function onCreatePost()
{
	FlxG.mouse.visible = false;
	new FlxTimer().start(1.21, function(tmr:FlxTimer) {
		FlxTween.cancelTweensOf(FlxG.sound.music);
		FlxG.sound.music.volume = 0;
		FlxG.sound.music.pitch = 1;
		FlxG.mouse.visible = false;
	});
}

function onTransitioned()
{
	FlxG.mouse.visible = false;
	OverworldState.ui.moveItems(false);
	loadCreditsVideo();
}

function onEvent(eventName, value1, value2)
{
	switch (eventName)
	{
		case 'Credits':
			loadCreditsVideo();
	}
}

function onUpdate(elapsed)
{
	canMove = false;
}

function loadCreditsVideo()
{
	creditsVideo = new FunkinVideoSprite();
	creditsVideo.onFormat(() -> {
		creditsVideo.setGraphicSize(0, FlxG.height);
		creditsVideo.updateHitbox();
		creditsVideo.screenCenter();
		creditsVideo.cameras = [camHUD];
	});
	creditsVideo.onEnd(() -> {
		FlxG.switchState(() -> {
			new TitleState201();
		});
	});
	creditsVideo.load(Paths.video('credits'));
	add(creditsVideo);

	creditsVideo.play();
}
