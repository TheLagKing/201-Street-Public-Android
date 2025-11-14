import funkin.backend.PlayerSettings;

var controls = PlayerSettings.player1.controls;

var bill_array:Array<String> = [
	"dandadan",
	"earthbound",
	"ghostface",
	"pokemon",
	"herobrine",
	"dhmis",
	"pink-sea",
	"black-sea",
	"repo",
	"scp",
	"monster"
];

var base_pos:Int;
var control_timer:FlxTimer;
var shift_timer:FlxTimer;
var control_ui:FlxSprite;

function onLoad()
{
	if (OverworldState.curMusic != '')
	{
		loadBillStuff(0.8);
	}

	OverworldState.ui.billie.loadGraphic(Paths.image('overworld/ui/corner_billie'));
	OverworldState.ui.billie.updateHitbox();
	OverworldState.ui.billie.y = FlxG.height - OverworldState.ui.billie.height;
	base_pos = camFollow.x;

	if (FlxG.save.data.overworldData.contains('GotEarbuds') != true) // this works I guess
	{
		FlxG.save.data.overworldData.push("GotEarbuds");
		FlxG.save.flush();
	}

	if (FlxG.save.data.overworldData.contains('FirstMove') != true) // this also works I guess
	{
		FlxG.save.data.overworldData.push('FirstMove');
		FlxG.save.flush();
	}

	if (FlxG.save.data.overworldData.contains('ShiftMove')) return;
	control_ui = new FlxSprite().loadGraphic(Paths.image('overworld/ui/controlshift'));
	control_ui.scale.set(0.5, 0.5);
	control_ui.camera = camHUD;
	control_ui.screenCenter();
	control_ui.y += 190;
	control_ui.alpha = 0;
	insert(1, control_ui);
}

function onCreatePost()
{
	new FlxTimer().start(1.2, function(tmr:FlxTimer) {
		loadBillStuff(4);
	});
}

function onEndDialogue()
{
	new FlxTimer().start(1.01, function(tmr:FlxTimer) {
		if (FlxG.save.data.overworldData.contains('BillArrived') != true) loadBillStuff(3);
	});
}

var move_pop_up:Bool = false;

function onTransitioned()
{
	if (FlxG.save.data.overworldData.contains('ShiftMove')) return;
	control_timer = new FlxTimer().start(1, function(tmr:FlxTimer) {
		if (move_pop_up) return;
		FlxTween.tween(control_ui, {alpha: 1}, 1.7);
	});

	shift_timer = new FlxTimer().start(4, function(tmr:FlxTimer) {
		if (move_pop_up) return;
		FlxTween.tween(control_ui, {alpha: 0}, 1.7);
		if (FlxG.save.data.overworldData.contains('ShiftMove') != true)
		{
			FlxG.save.data.overworldData.push('ShiftMove');
			FlxG.save.flush();
		}
	});
}

var bill_cutscene:Bool;

function loadBillStuff(dialogue_time:Float)
{
	var bill_check:Bool = true;

	for (i in 0...bill_array.length)
	{
		if (FlxG.save.data.songsBeaten.contains(bill_array[i]) != true)
		{
			bill_check = false;
			break;
		}
	}

	if (FlxG.save.data.songsBeaten.contains('bill-cipher')) bill_check = false;

	if (bill_check)
	{
		FlxTween.cancelTweensOf(FlxG.sound.music);
		bill_cutscene = true;

		for (object in objects.members)
		{
			object.dialogue = null;
			object.location = null;
			if (object.name == "glow")
			{
				FlxTween.tween(object, {alpha: 1}, 3,
					{
						ease: FlxEase.sineInOut,
						onComplete: function(twn:FlxTween) {
							FlxTween.tween(object, {alpha: 0.5}, 1.5, {ease: FlxEase.sineInOut, type: 4});
						}
					});
			}
		}

		for (teleporter in teleporters.members)
		{
			if (teleporter.location != 'cipher') teleporter.kill();
		}

		new FlxTimer().start(dialogue_time, function(tmr:FlxTimer) {
			OverworldState.ui.moveItems(false);
			FlxG.sound.play(Paths.sound('201-street/bill_spawn'), 0.75);
			new FlxTimer().start(4, function(tmr:FlxTimer) {
				bill_cutscene = false;
				loadDialogue('bill_spawn');
			});
		});

		pushedNew = true;
		if (FlxG.save.data.notifTypes.contains("checklist") == false) FlxG.save.data.notifTypes.push("checklist");
		FlxG.save.flush();
	}
	else if (!FlxG.save.data.songsBeaten.contains('bill-cipher'))
	{
		for (teleporter in teleporters.members)
		{
			if (teleporter.location == 'cipher') teleporter.kill();
		}
	}
}

function onUpdate(elapsed)
{
	if (bill_cutscene) canMove = false;

	if (FlxG.save.data.overworldData.contains('ShiftMove')) return;

	if (controls.UI_RIGHT
		|| controls.NOTE_RIGHT
		|| controls.UI_LEFT
		|| controls.NOTE_LEFT
		|| FlxG.mouse.wheel < 0
		|| FlxG.mouse.wheel > 0)
	{
		if (FlxG.keys.pressed.SHIFT && !move_pop_up)
		{
			move_pop_up = true;
			FlxTween.cancelTweensOf(control_ui);
			shift_timer.active = false;
			FlxTween.tween(control_ui, {alpha: 0}, 1.7);
			if (FlxG.save.data.overworldData.contains('ShiftMove') != true)
			{
				FlxG.save.data.overworldData.push('ShiftMove');
				FlxG.save.flush();
			}
		}
	}
}

function onOpenPhone()
{
	if (control_timer != null) control_timer.active = false; // shift_timer
	if (shift_timer != null) shift_timer.active = false;
}

function onClosePhone()
{
	if (control_timer != null) control_timer.active = true;
	if (shift_timer != null) shift_timer.active = true;
}

function onDestroy()
{
	if (control_ui != null) control_ui.destroy();
}

function onChangeMap()
{
	if (control_ui != null)
	{
		control_timer.active = false;
		shift_timer.active = false;
		FlxTween.cancelTweensOf(control_ui);
		FlxTween.tween(control_ui, {alpha: 0}, 0.3);
	}
}
