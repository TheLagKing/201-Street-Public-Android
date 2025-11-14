var stage:Int = 0;
final MAX_STAGE:Int = 3;
var path:String = "";

// false is LEFT, true is RIGHT
// if you're peeking here to see the answers i won't judge but also i will frown a little
final CORRECT_PATHS:Map<String, Array<Null<Bool>>> = ["monster" => [null, false, false, true], "scp" => [null, true, false, false]];

final PATH_DECORATIONS:Map<String, Array<Null<String>>> = [
	"" => ["entrance", null, null, null],
	"monster" => [null, "monster1", "monster2", "monster3"],
	"scp" => [null, "scp1", "scp2", "scp3"]
];

var isTransitioning:Bool = false;
final INIT_X:Int = 750;
final INIT_Y:Int = 400;
final TRANS_LEFT_X:Int = 500;
final TRANS_RIGHT_X:Int = 1000;
final TRANS_ZOOM:Float = 0.65;
final TRANS_DURATION:Float = 0.8;
var directionHovered:String = "";
final DIRECTION_LEFT_BOUND:Int = 400;
final DIRECTION_RIGHT_BOUND:Int = 250;
final DIRECTION_MAX_Y:Int = 600;
var canClick:Bool = false;
var hasGoggles:Bool = false;

function onLoad()
{
	loadPathAssets(0, "");
	OverworldState.ui.muteBuzz = true;

	camFollow.x = INIT_X;
	camFollow.y = INIT_Y;
	FlxG.camera.snapToTarget();
	disableWallSnap = true;

	hasGoggles = FlxG.save.data.overworldData.contains('EquipGoggles');

	if (hasGoggles)
	{
		canClick = true;
	}
	else
	{
		dark_overlay = new FlxSprite().makeGraphic(1300, 800, 0xFF3c3886);
		dark_overlay.camera = camHUD;
		dark_overlay.blend = BlendMode.MULTIPLY;
		dark_overlay.alpha = 0.7;
		insert(1, dark_overlay);
	}
}

function onTransitioned()
{
	// OverworldState.ui.moveItems(false);
	loadPathAssets(stage, path);
	OverworldState.ui.muteBuzz = true;

	for (temp_array in OverworldState.ui.object_positions)
	{
		if (temp_array[0] == OverworldState.ui.billie_bg || temp_array[0] == OverworldState.ui.billie)
		{
			FlxTween.cancelTweensOf(temp_array[0]);
			temp_array[0].x = temp_array[2];
		}
	}
	OverworldState.ui.phone.visible = false;

	if (FlxG.save.data.overworldData.contains('EquipGoggles'))
	{
		canClick = true;
	}
	else
	{
		if (FlxG.save.data.overworldData.contains('BoughtHeadset'))
		{
			loadDialogue('goggles');
			canClick = true;
		}
		else
		{
			loadDialogue('no_goggles');
		}
	}
}

function onUpdatePost(elapsed:Float)
{
	updateDirectionHovered();

	if (canMove)
	{
		camFollow.x = INIT_X;
		FlxG.camera.snapToTarget();
		FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursor" + (directionHovered == 'teleporter' ? 'down' : directionHovered)).bitmap, 0.325);
	}

	if (directionHovered != "teleporter" && canMove && canClick)
	{
		if (directionHovered == "left")
		{
			OverworldState.ui.displayObjectText("Go left...");
		}
		else if (directionHovered == "right")
		{
			OverworldState.ui.displayObjectText("Go right...");
		}
		else
		{
			OverworldState.ui.removeObjectText();
		}

		if (FlxG.mouse.justPressed)
		{
			if (directionHovered == "left")
			{
				pickDirection(false);
			}
			else if (directionHovered == "right")
			{
				pickDirection(true);
			}
		}
	}
	else if (!canMove)
	{
		if (isTransitioning) FlxG.camera.followLerp = 1.0;
		FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursor").bitmap, 0.325);
	}
}

function updateDirectionHovered()
{
	directionHovered = "";

	if (hasGoggles)
	{
		if (mouse_object.y < DIRECTION_MAX_Y)
		{
			if (mouse_object.x < DIRECTION_LEFT_BOUND)
			{
				if (!(FlxG.save.data.songsBeaten.contains("scp") && stage == 0)) directionHovered = "left";
			}
			else if (mouse_object.x > (FlxG.width - DIRECTION_RIGHT_BOUND))
			{
				if (!(FlxG.save.data.songsBeaten.contains("monster") && stage == 0)) directionHovered = "right";
			}
		}
	}

	for (teleporter in teleporters.members)
	{
		if (FlxG.overlap(mouse_object, teleporter) && teleporter.location != null)
		{
			directionHovered = "teleporter";
		}
	}
}

function pickDirection(right:Bool)
{
	if (!canMove) return;
	canMove = false;

	var correct:Bool = false;
	var toPath:String;
	var toStage:Int;

	if (stage == 0)
	{
		toPath = right ? "monster" : "scp";
		correct = true;
	}
	else
	{
		toPath = path;
		if (CORRECT_PATHS[path][stage] == null)
		{
			trace("Path direction was null");
			return;
		}

		correct = (CORRECT_PATHS[path][stage] == right);
	}

	toStage = correct ? stage + 1 : 0;
	if (!correct) toPath = "";

	isTransitioning = true;

	FunkinSound.play(Paths.sound("201-street/ForestRunning"));

	FlxTween.tween(camFollow, {x: (right ? TRANS_RIGHT_X : TRANS_LEFT_X), y: INIT_Y - 50}, TRANS_DURATION, {ease: FlxEase.quadIn});
	FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + TRANS_ZOOM}, TRANS_DURATION, {ease: FlxEase.quadIn});
	FlxTween.tween(OverworldState.camHUDoverlay, {alpha: 1}, TRANS_DURATION, {ease: FlxEase.quadIn});

	new FlxTimer().start(TRANS_DURATION + 0.3, function(tmr:FlxTimer) {
		if (toStage > MAX_STAGE && correct)
		{
			loadForestDialogue(path);
		}
		else
		{
			if (!correct) FunkinSound.play(Paths.sound("201-street/ForestWrongWay"));
			continueToPath(toStage, toPath);
		}
	});
}

function continueToPath(thisStage:Int, thisPath:String)
{
	canMove = false;

	stage = thisStage;
	path = thisPath;

	loadPathAssets(stage, path);

	OverworldState.camHUDoverlay.alpha = 1;
	camGame.zoom = map_zoom;
	camFollow.x = INIT_X;
	camFollow.y = INIT_Y;
	FlxG.camera.snapToTarget();

	FlxTween.tween(OverworldState.camHUDoverlay, {alpha: 0}, TRANS_DURATION, {ease: FlxEase.quadOut});

	new FlxTimer().start(TRANS_DURATION + 0.1, function(tmr:FlxTimer) {
		canMove = true;
		isTransitioning = false;
	});
}

function loadPathAssets(thisStage:Int, thisPath:String)
{
	for (obj in objects.members)
	{
		switch (obj.name)
		{
			case "decoration":
				var decoration:Null<String> = PATH_DECORATIONS[thisPath][thisStage];

				if (decoration == null)
				{
					obj.visible = false;
				}
				else
				{
					obj.visible = true;
					obj.loadGraphic(Paths.image("overworld/maps/forest/objects/" + decoration));
					obj.setGraphicSize(Std.int(obj.width * obj.scale));
					obj.updateHitbox();
				}

			case "sign":
				obj.loadGraphic(Paths.image("overworld/maps/forest/objects/sign" + (thisStage + 1)));
				obj.setGraphicSize(Std.int(obj.width * obj.scale));
				obj.updateHitbox();

			case "left_tape":
				obj.visible = FlxG.save.data.songsBeaten.contains("scp") && (thisStage == 0);

			case "right_tape":
				obj.visible = FlxG.save.data.songsBeaten.contains("monster") && (thisStage == 0);
		}
	}
}

function loadForestDialogue(dia_path:String)
{
	camGame.zoom = map_zoom;
	camFollow.x = INIT_X;
	camFollow.y = INIT_Y;
	FlxG.camera.snapToTarget();

	stage = 0;
	path = '';
	loadPathAssets(stage, path);

	if (FlxG.save.data.songsBeaten.contains(dia_path)) dia_path += '_dead_end';
	loadDialogue(dia_path);
}

function onEvent(eventName, value1, value2)
{
	switch (eventName)
	{
		case 'Equip Goggles':
			hasGoggles = true;
			canClick = true;
			FunkinSound.play(Paths.sound("201-street/GogglesEquip"), 0.8);
			OverworldState.camHUDoverlay.alpha = 1;
			FlxTween.tween(OverworldState.camHUDoverlay, {alpha: 0}, 0.5, {startDelay: 0.3, ease: FlxEase.quadOut});
			FlxTween.tween(dark_overlay, {alpha: 0}, 0.5, {startDelay: 0.3, ease: FlxEase.quadOut});

		case 'Hide UI':
			for (temp_array in OverworldState.ui.object_positions)
			{
				if (temp_array[0] == OverworldState.ui.billie_bg || temp_array[0] == OverworldState.ui.billie)
				{
					FlxTween.cancelTweensOf(temp_array[0]);
					temp_array[0].x = temp_array[2];
				}
			}
			OverworldState.ui.phone.visible = false;

		case 'Force Tape':
			// bandage fix but whatever
			for (obj in objects.members)
			{
				switch (obj.name)
				{
					case "left_tape":
						if (value1 == "scp") obj.visible = true;
					case "right_tape":
						if (value1 == "monster") obj.visible = true;
				}
			}
	}
}

function onStartDialogue()
{
	trace("lol");
	loadPathAssets(stage, path);
}

function onDestroy()
{
	OverworldState.ui.phone.visible = true;
	OverworldState.ui.muteBuzz = false;

	if (FlxG.save.data.overworldData.contains('EquipGoggles')) return;
	dark_overlay.destroy();
}
