var control_ui:FlxSprite;
var move_pop_up:Bool = false;
var base_pos:Int;

function onLoad()
{
	if (FlxG.save.data.overworldData.contains('FirstMove')) return;
	control_ui = new FlxSprite().loadGraphic(Paths.image('overworld/ui/controlstuff'));
	control_ui.scale.set(0.5, 0.5);
	control_ui.camera = camHUD;
	control_ui.screenCenter();
	control_ui.x += 400;
	control_ui.y -= 250;
	control_ui.alpha = 0;
	insert(1, control_ui);

	base_pos = camFollow.x;
}

function onEndDialogue()
{
	if (FlxG.save.data.overworldData.contains("MustReturn") == true
		&& FlxG.save.data.overworldData.contains("ReturnedToShop") != true
		&& FlxG.save.data.overworldData.contains("LetsReturn") != true)
	{
		new FlxTimer().start(4.011, function(tmr:FlxTimer) {
			canMove = false;
			loadDialogue('lets_return');
		});
	}

	if (FlxG.save.data.songsBeaten.contains("pokemon")
		&& FlxG.save.data.songsBeaten.contains("herobrine")
		&& FlxG.save.data.songsBeaten.contains("dhmis")
		&& FlxG.save.data.songsBeaten.contains("repo")
		&& FlxG.save.data.overworldData.contains("CollectedAllItems") != true)
	{
		new FlxTimer().start(4.011, function(tmr:FlxTimer) {
			canMove = false;
			loadDialogue('all_items');
		});
	}

	if (!FlxG.save.data.overworldData.contains('FirstMove'))
	{
		if (move_pop_up) return;
		FlxTween.tween(control_ui, {alpha: 1}, 1.7);
	}
}

function onUpdate(elapsed)
{
	if (FlxG.save.data.overworldData.contains('FirstMove')) return;

	if (camFollow.x != base_pos && !move_pop_up)
	{
		move_pop_up = true;
		FlxTween.cancelTweensOf(control_ui);
		FlxTween.tween(control_ui, {alpha: 0}, 1.7);
		if (FlxG.save.data.overworldData.contains('FirstMove') != true)
		{
			FlxG.save.data.overworldData.push('FirstMove');
			FlxG.save.flush();
		}
	}
}

function onEvent(name, v1, v2)
{
	switch (name)
	{
		case "Hide Leticia":
			for (obj in objects.members)
			{
				if (obj.name == "Leticia")
				{
					obj.visible = false;
				}
			}

		case "Tween Leticia":
			for (obj in objects.members)
			{
				if (obj.name == "Leticia")
				{
					obj.x -= 300;
					obj.visible = true;
					FlxTween.tween(obj, {x: obj.x + 300}, 1, {ease: FlxEase.quadOut});
				}
			}
	}
}

function onDestroy()
{
	if (control_ui != null) control_ui.destroy();
}

function onChangeMap()
{
	if (control_ui != null)
	{
		FlxTween.cancelTweensOf(control_ui);
		FlxTween.tween(control_ui, {alpha: 0}, 0.3);
	}
}
