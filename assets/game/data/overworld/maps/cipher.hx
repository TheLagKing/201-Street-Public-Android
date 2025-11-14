import funkin.backend.PlayerSettings;

var controls = PlayerSettings.player1.controls;
var monotone_rapture:Bool = false;
var add_hidden_monotone:Bool;
var base_pos:Int;
var control_ui:FlxSprite;
var move_pop_up:Bool = false;
var control_timer:FlxTimer;

function onLoad()
{
	add_hidden_monotone = FlxG.save.data.overworldData.contains('HouseMonotone')
		&& FlxG.save.data.overworldData.contains('TownMonotone')
		&& FlxG.save.data.overworldData.contains('LakeMonotone')
		&& FlxG.save.data.overworldData.contains('StreetMonotone')
		&& FlxG.save.data.overworldData.contains('ShopMonotone')
		&& FlxG.save.data.overworldData.contains('Raptured') != true;

	remove(main_background);

	camFollow.y = 750;
	FlxG.camera.snapToTarget();

	insert(13, main_background);

	OverworldState.ui.billie.loadGraphic(Paths.image('overworld/ui/corner_billie_scared'));
	FlxTween.cancelTweensOf(OverworldState.ui.billie);

	if (FlxG.save.data.songsBeaten.contains('bill-cipher') != true)
	{
		for (teleporter in teleporters.members)
			teleporter.kill();
	}

	if (!FlxG.save.data.overworldData.contains('BillMove'))
	{
		control_ui = new FlxSprite().loadGraphic(Paths.image('overworld/ui/controlupdown'));
		control_ui.scale.set(0.4, 0.4);
		control_ui.camera = camHUD;
		control_ui.screenCenter();
		control_ui.y += 208;
		control_ui.alpha = 0;
		insert(1, control_ui);

		base_pos = camFollow.y;
	}

	if (!add_hidden_monotone) return;

	hidden_monotone = new FlxSprite(475, 0);
	hidden_monotone.frames = Paths.getSparrowAtlas('overworld/maps/cipher/objects/rapture');
	hidden_monotone.animation.addByPrefix('rapture', 'hiddenrapture', 24, false);
	hidden_monotone.scale.set(0.4, 0.4);
	hidden_monotone.antialiasing = false;

	hidden_monotone_clicker = new FlxSprite(hidden_monotone.x + 230, hidden_monotone.y + 560).makeGraphic(30, 30, FlxColor.RED);
	hidden_monotone_clicker.alpha = 0;

	rapture_beam = new FlxSprite(hidden_monotone.x + 90 + hidden_monotone.width / 3, hidden_monotone.y).makeGraphic(150, 2000, FlxColor.WHITE);
	rapture_beam.scale.x = 0;
	objects.insert(10, rapture_beam);
	objects.insert(11, hidden_monotone);
	objects.insert(12, hidden_monotone_clicker);
}

function onUpdate(elapsed)
{
	if (!canMove) return;
	var vert_movement:Float = 3 * (60 * elapsed);
	if (controls.UI_UP == true || controls.NOTE_UP == true) camFollow.y -= vert_movement;
	else if (FlxG.mouse.wheel > 0) camFollow.y -= vert_movement * 15;
	else if (controls.UI_DOWN == true || controls.NOTE_DOWN == true) camFollow.y += vert_movement;
	else if (FlxG.mouse.wheel < 0) camFollow.y += vert_movement * 15;

	if (!FlxG.save.data.overworldData.contains('BillMove'))
	{
		if (camFollow.y != base_pos && !move_pop_up)
		{
			move_pop_up = true;
			FlxTween.cancelTweensOf(control_ui);
			FlxTween.tween(control_ui, {alpha: 0}, 1.7);
			if (FlxG.save.data.overworldData.contains('BillMove') != true)
			{
				FlxG.save.data.overworldData.push('BillMove');
				FlxG.save.flush();
			}
		}
	}

	if (!add_hidden_monotone) return;
	if (FlxG.overlap(mouse_object, hidden_monotone_clicker) && !monotone_rapture && hidden_monotone.visible)
	{
		if (FlxG.mouse.justPressed)
		{
			rapture_the_Tone();
		}
	}
}

function onTransitioned()
{
	if (FlxG.save.data.overworldData.contains('BillMove')) return;
	control_timer = new FlxTimer().start(5, function(tmr:FlxTimer) {
		if (move_pop_up) return;
		FlxTween.tween(control_ui, {alpha: 1}, 1.7);
	});
}

function rapture_the_Tone()
{
	monotone_rapture = true;
	FlxTween.tween(hidden_monotone, {x: hidden_monotone.x + 80}, 0.5, {startDelay: 0.05, ease: FlxEase.quartIn});
	hidden_monotone.animation.play('rapture');
	hidden_monotone.animation.finishCallback = function(pog:String) {
		hidden_monotone.visible = false;
	}

	rapture_beam.scale.x = 0;
	new FlxTimer().start(1.17, tmr -> {
		rapture_beam.scale.x = 0.08;
		new FlxTimer().start(0.1, tmr -> {
			rapture_beam.scale.x = 1;
			rapture_beam.color = FlxColor.BLACK;
			new FlxTimer().start(0.05, tmr -> {
				rapture_beam.color = FlxColor.WHITE;
			});
		});
	});
	FlxTween.tween(rapture_beam.scale, {x: 0}, 0.4, {startDelay: 5.4, ease: FlxEase.quadIn});

	FlxG.sound.play(Paths.sound('201-street/monotone/rapture'));

	if (FlxG.save.data.overworldData.contains('Raptured') != true)
	{
		FlxG.save.data.overworldData.push('Raptured');
		FlxG.save.flush();
	}
}

function onDestroy()
{
	if (control_ui != null) control_ui.destroy();
}

function onOpenPhone()
{
	if (control_timer != null) control_timer.active = false;
}

function onClosePhone()
{
	if (control_timer != null) control_timer.active = true;
}

function onChangeMap()
{
	if (control_ui != null)
	{
		control_timer.active = false;
		FlxTween.cancelTweensOf(control_ui);
		FlxTween.tween(control_ui, {alpha: 0}, 1.7);
	}
}

function onUpdatePost()
{
	OverworldState.ui.billie.y = FlxG.height - OverworldState.ui.billie.height / 1.5;

	camFollow.x = main_background.width / 2;

	if (camFollow.y < FlxG.height / 2) camFollow.y = FlxG.height / 2;
	if (camFollow.y > 750) camFollow.y = 750;
}
