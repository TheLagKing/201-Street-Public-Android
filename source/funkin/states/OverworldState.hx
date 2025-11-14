package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import openfl.filters.ShaderFilter;
import funkin.objects.overworld.*;
import funkin.states.substates.*;
import funkin.game.shaders.Outline;
import funkin.states.editors.OverworldEditorState;
import funkin.data.Chart;
import funkin.data.Chart.ChartFormat;
import funkin.scripts.FunkinScript;
import sys.FileSystem;
import Sys;

typedef ObjectData =
{
	?object_path:String,
	?name:String,
	?dialogue:String,
	?location:String,
	?position:Array<Float>,
	?remove_outline:Bool
}

typedef TeleporterData =
{
	?position:Array<Float>,
	?size:Array<Int>,
	?location:String,
	?location_name:String,
	?direction:String
}

typedef MapData =
{
	?name:String,
	?music:String,
	?music_name:String,
	?bpm:Float,
	?scale:Float,
	?zoom:Float,
	?cam_offsets:Array<Array<Dynamic>>,
	?objects:Array<ObjectData>,
	?screen_warp:Bool,
	?can_run:Bool,
	?teleporter_hitboxes:Array<TeleporterData>
}

class OverworldState extends MusicBeatState
{
	public static var instance:Null<OverworldState> = null;

	public var disableWallSnap:Bool;

	var camFollow:FlxObject;
	var cameraSpeed:Float = 1.15;
	var defaultCamZoom:Float = 1.1;
	var map_zoom:Float = 1;

	public static var map_name:String = 'main_street';

	public var main_background:FlxSprite;
	public var objects:FlxTypedGroup<Object>;

	var teleporters:FlxTypedGroup<Teleporter>;

	public var canMove:Bool = false;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

	public static var camHUDoverlay:FlxSprite;

	var dialogue_box:DialogueBox;

	public static var ui:OverworldUI;

	public var posterize:funkin.backend.FunkinShader.FunkinRuntimeShader;

	public var pov:Dynamic;

	public static var mapData:MapData;

	var filters_array:Array<openfl.filters.BitmapFilter>;

	var mouse_object:FlxSprite;
	var mouse_object_pos:FlxSprite;
	var mouse_offset:Int = 43;

	var foreground:FlxSprite;

	public static var curMusic:String = '';

	public static var curCutscene:String = '';

	var comeFrom:String;

	public var script:FunkinScript;

	override function create()
	{
		instance = this;

		super.create();

		if (FlxG.save.data.overworldData == null)
		{
			FlxG.save.data.overworldData = [];
			FlxG.save.flush();
		}

		if (FlxG.save.data.songsBeaten == null)
		{
			FlxG.save.data.songsBeaten = [];
			FlxG.save.flush();
		}
		if (FlxG.save.data.notifTypes == null)
		{
			FlxG.save.data.notifTypes = [];
			FlxG.save.flush();
		}

		curMusic = '';

		camGame = new FlxCameraEx();
		camHUD = new FlxCameraEx();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(0, 0);
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 0);
		disableWallSnap = false;

		posterize = newShader('posterize');
		posterize.setFloat("color_amt", 0.0);

		pov = newShader('PanoPerspective');

		var fovV = 61.875038;
		pov.setFloat("hr", 0.5);
		pov.setFloat("vr", 1);
		pov.setFloat("hfov", 220);
		pov.setFloat("vfov", fovV * 0.8);
		pov.setFloat("z", 1);
		pov.setFloat("ho", (0.1 - (0 + 640) / 2560) * 0.25 + 0.5);
		pov.setFloat("vo", 0.5);
		pov.setFloat("to", 0);
		pov.setFloat("to2", 0);

		ui = new OverworldUI();
		ui.camera = camHUD;
		add(ui);

		camHUDoverlay = new FlxSprite().makeGraphic(1285, 725, FlxColor.BLACK);
		camHUDoverlay.camera = camHUD;
		add(camHUDoverlay);

		dialogue_box = new DialogueBox();
		dialogue_box.camera = camHUD;
		add(dialogue_box);

		main_background = new FlxSprite();
		add(main_background);

		teleporters = new FlxTypedGroup<Teleporter>();
		add(teleporters);

		objects = new FlxTypedGroup<Object>();
		add(objects);

		foreground = new FlxSprite();
		add(foreground);

		filters_array = [];

		swap_map(map_name);
		ui.moveItems(false);

		mouse_object = new FlxSprite().makeGraphic(30, 30, FlxColor.BLACK);
		mouse_object.alpha = 0.00001;
		add(mouse_object);

		canMove = false;
		FlxG.mouse.visible = true;
		FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursor").bitmap, 0.325);

		camGame.filters = [new ShaderFilter(posterize)];
		if (mapData.screen_warp) for (filter in filters_array)
			camGame.filters.push(filter);

		if (curCutscene == '')
		{
			reloadMusic(mapData.music);

			new FlxTimer().start(1.2, function(tmr:FlxTimer) {
				FlxG.sound.music.time = 0;
				FlxTween.tween(FlxG.sound.music, {pitch: 1, volume: 1}, 4);

				for (i in 0...3)
				{
					new FlxTimer().start(i + 1, function(tmr:FlxTimer) {
						posterize.setFloat("color_amt", (i + 1) * 2);
						camHUDoverlay.alpha -= 0.35;
					});
				}

				new FlxTimer().start(4, function(tmr:FlxTimer) {
					camGame.filters = filters_array;
					canMove = true;
					ui.moveItems(true);
					callScriptFunc('onTransitioned');
				});
			});
		}
		else
		{
			loadDialogue(curCutscene);
			curCutscene = '';
		}

		var appDataPath = Sys.getEnv("AppData");
		if (FlxG.save.data.overworldData != null)
		{
			if (!FlxG.save.data.overworldData.contains('PlayedWeekly') && FileSystem.isDirectory('$appDataPath/FNFWeekly'))
			{
				trace('this fella has played weekly.');
				FlxG.save.data.overworldData.push('PlayedWeekly');
				FlxG.save.flush();
			}
		}

		callScriptFunc('onCreatePost');
	}

	var camera_movement_amt:Float = 6;

	var outlineWidth:Float;
	var outlineHeight:Float;
	var mouse_mult_offset:Float = 90;

	override function update(elapsed:Float)
	{
		callScriptFunc('onUpdate', [elapsed]);

		Conductor.songPosition = FlxG.sound.music.time;

		final lerpRate = 0.04 * cameraSpeed;
		FlxG.camera.followLerp = canMove ? lerpRate : 0;

		handle_movement(elapsed);
		snapToWalls();

		FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, FlxMath.bound(elapsed * 12, 0, 1));

		if (FlxG.keys.justPressed.F8) FlxG.switchState(() -> {
			new OverworldEditorState();
		});

		// trace(mouse_mult_offset);

		// if(FlxG.keys.justPressed.SPACE) loadDialogue('intro_dialogue');

		if (mapData.screen_warp)
		{
			var relative_screen_x:Float = FlxG.mouse.getScreenPosition().x;
			if (223 > relative_screen_x)
			{
				mouse_mult_offset = (127 > relative_screen_x ? 139 : 115);
			}
			else if (relative_screen_x > 983)
			{
				mouse_mult_offset = (relative_screen_x > 1124 ? 158 : 120);
			}
			else mouse_mult_offset = 90;

			var sin_mouse_offset:Float = Math.sin(((FlxG.width / 2 - FlxG.width) + FlxG.mouse.getScreenPosition().x) / (FlxG.width / 3));
			mouse_object.setPosition(FlxG.mouse.x - (sin_mouse_offset * mouse_mult_offset), FlxG.mouse.y - mouse_object.height / 3);
			mouse_object.x += (mouse_offset - mouse_object.width / 2);
			if (mouse_mult_offset > 90) mouse_object.y += (FlxG.mouse.getScreenPosition().y - FlxG.height / 2) * -1 * (mouse_mult_offset != 90 ? 0.15 : 0);
		}
		else
		{
			mouse_object.setPosition(FlxG.mouse.x - mouse_object.width / 2, FlxG.mouse.y - mouse_object.height / 3);
		}

		var objectToTarget:Null<Object> = null;

		FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursor").bitmap, 0.325);
		for (object in objects.members)
		{
			if (FlxG.overlap(mouse_object, object)
				&& canMove
				&& object.visible
				&& (object.dialogue != null || object.location != null)
				&& ui.phone.shader == null)
			{
				// FlxG.mouse.load(Paths.image("overworld/ui/cursor/click").bitmap, 0.325);
				// if (FlxG.mouse.justPressed)
				// {
				//	object.dialogue != null ? loadDialogue(object.dialogue) : click_to_change_maps(object.location, map_name);
				// }
				// if (object.remove_outline != true) object.shader = new Outline(0xFFFFFFFF, outlineWidth, outlineHeight);
				// nameToDisplay = object.name;

				objectToTarget = object;
			}

			object.shader = null;
		}

		var nameToDisplay:Null<String> = null;

		if (objectToTarget != null)
		{
			FlxG.mouse.load(Paths.image("overworld/ui/cursor/click").bitmap, 0.325);
			if (FlxG.mouse.justPressed)
			{
				objectToTarget.dialogue != null ? loadDialogue(objectToTarget.dialogue) : click_to_change_maps(objectToTarget.location, map_name);
			}
			if (objectToTarget.remove_outline != true) objectToTarget.shader = new Outline(0xFFFFFFFF, outlineWidth, outlineHeight);
			nameToDisplay = objectToTarget.name;
		}

		for (teleporter in teleporters.members)
		{
			if (FlxG.overlap(mouse_object, teleporter) && canMove && teleporter.location != null)
			{
				if (teleporter.direction != null) FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursor" + teleporter.direction).bitmap, 0.325);
				else FlxG.mouse.load(Paths.image("overworld/ui/cursor/cursorup").bitmap, 0.325);

				if (FlxG.mouse.justPressed)
				{
					click_to_change_maps(teleporter.location.toLowerCase(), map_name);
				}
				nameToDisplay = 'To ' + teleporter.location_name;
			}
		}

		super.update(elapsed);

		nameToDisplay != null ? ui.displayObjectText(nameToDisplay) : ui.removeObjectText();

		callScriptFunc('onUpdatePost', [elapsed]);
	}

	function handle_movement(elapsed:Float)
	{
		if (!canMove) return;

		if (FlxG.keys.pressed.SHIFT && mapData.can_run)
		{
			defaultCamZoom = map_zoom + 0.1;
			camera_movement_amt = 11;
		}
		else
		{
			defaultCamZoom = map_zoom;
			camera_movement_amt = 5;
		}

		camera_movement_amt *= (60 * elapsed);

		if (controls.UI_RIGHT || controls.NOTE_RIGHT)
		{
			camFollow.x += camera_movement_amt;
		}
		else if (FlxG.mouse.wheel > 0)
		{
			camFollow.x += camera_movement_amt * 15;
		}
		else if (controls.UI_LEFT || controls.NOTE_LEFT)
		{
			camFollow.x -= camera_movement_amt;
		}
		else if (FlxG.mouse.wheel < 0)
		{
			camFollow.x -= camera_movement_amt * 15;
		}

		// if(FlxG.keys.pressed.SPACE){
		// 	trace(camFollow.x, main_background.width);
		// }
	}

	public function newShader(?fragFile:String, ?vertFile:String)
	{
		var fragPath = fragFile != null ? Paths.fragment(fragFile) : null;
		var vertPath = vertFile != null ? Paths.vertex(vertFile) : null;

		if (fragPath != null)
		{
			if (FunkinAssets.exists(fragPath)) fragPath = FunkinAssets.getContent(fragPath);
		}

		if (vertPath != null)
		{
			if (FunkinAssets.exists(vertPath)) vertPath = FunkinAssets.getContent(vertPath);
		}

		return new funkin.backend.FunkinShader.FunkinRuntimeShader(fragPath, vertPath);
	}

	public function loadDialogue(dialogue:String, ?preload_shit:Bool = false)
	{
		canMove = false;
		dialogue_box.loadDialogue(dialogue, preload_shit);
	}

	override function stepHit()
	{
		callScriptFunc('onStepHit');
		super.stepHit();

		// outlineWidth = FlxG.random.float(3.5, 6.5);
		// outlineHeight = FlxG.random.float(3.5, 6.5);
	}

	override function beatHit()
	{
		callScriptFunc('onBeatHit');
		super.beatHit();

		outlineWidth = 5;
		outlineHeight = 5;
		FlxTween.tween(this, {outlineWidth: 3, outlineHeight: 3}, (Conductor.crotchet / 1000) * 0.8, {ease: FlxEase.quadOut});

		ui.beatHit();
	}

	function click_to_change_maps(new_map:String, cameFrom:String)
	{
		comeFrom = cameFrom;
		callScriptFunc('onChangeMap', [new_map]);
		if (canMove) transition_maps(new_map);
	}

	public function transition_maps(new_map:String)
	{
		var temp_mapData:MapData = loadMapData(new_map);
		if (curMusic != temp_mapData.music_name)
		{
			FlxTween.tween(FlxG.sound.music, {pitch: 0, volume: 0}, 1.4);
		}

		canMove = false;
		camGame.filters.push(new ShaderFilter(posterize));

		var col_amt:Float = 6;
		posterize.setFloat("color_amt", col_amt);
		for (i in 0...4)
		{
			new FlxTimer().start(i * 0.2, function(tmr:FlxTimer) {
				col_amt -= (i - 1) * 2;
				posterize.setFloat("color_amt", col_amt);
				camHUDoverlay.alpha += 0.25;
			});
		}

		new FlxTimer().start(3, function(tmr:FlxTimer) {
			callScriptFunc('onDestroy');
			var reloading_music:Bool = false;
			mapData = temp_mapData;
			if (curMusic != temp_mapData.music_name)
			{
				reloading_music = true;
				reloadMusic(temp_mapData.music);
				FlxTween.tween(FlxG.sound.music, {pitch: 1, volume: 1}, 1.2);

				if (ui.items_on_screen) ui.moveItems(false);
			}
			swap_map(new_map);
			camGame.filters.push(new ShaderFilter(posterize));
			posterize.setFloat("color_amt", 0);
			for (i in 0...4)
			{
				new FlxTimer().start(i * 0.25, function(tmr:FlxTimer) {
					posterize.setFloat("color_amt", (i + 1) * 2);
					camHUDoverlay.alpha -= 0.25;
					if (camHUDoverlay.alpha == 0)
					{
						if (mapData.screen_warp) filters_array = [new ShaderFilter(pov)];
						else filters_array = [];
						camGame.filters = filters_array;

						if (reloading_music) ui.moveItems(true);

						canMove = true;
						callScriptFunc('onTransitioned');
					}
				});
			}
		});
	}

	public function reloadMusic(?songName:String = '')
	{
		if (songName == '') songName = mapData.music;
		FunkinSound.playMusic(Paths.music('201-street/overworld/' + songName.toLowerCase()), 0);
		if (songName == mapData.music)
		{
			curMusic = mapData.music_name;
			Conductor.bpm = mapData.bpm;
			Conductor.bpmChangeMap = [];
			ui.updateMusic(mapData.music_name);
			FlxG.sound.music.pitch = 0;
		}
		else
		{
			curMusic = songName;
			FlxG.sound.music.pitch = 0;
			ui.updateMusic();
		}
	}

	public function openSub(sub:FlxSubState):Void
	{
		openSubState(sub);
	}

	public function swap_map(new_map:String)
	{
		map_name = new_map;

		mapData = loadMapData(map_name);

		ui.changeLocationName(mapData.name);

		map_zoom = mapData.zoom != null ? mapData.zoom : 1;
		defaultCamZoom = map_zoom;
		camGame.zoom = map_zoom + 0.1;

		remove(main_background);
		main_background.loadGraphic(Paths.image('overworld/maps/$map_name/map'));
		main_background.setGraphicSize(Std.int(main_background.width * mapData.scale));
		main_background.updateHitbox();
		main_background.antialiasing = false;

		foreground.alpha = 1;
		if (sys.FileSystem.exists('assets/images/overworld/maps/$map_name/foreground.png'))
		{
			foreground.loadGraphic(Paths.image('overworld/maps/$map_name/foreground'));
			foreground.setGraphicSize(Std.int(foreground.width * mapData.scale));
			foreground.updateHitbox();
		}
		else foreground.alpha = 0;
		foreground.antialiasing = false;

		reloadObjects();
		reloadTeleporters();

		remove(objects);
		remove(teleporters);

		add(main_background);
		add(objects);
		add(teleporters);

		if (mapData.screen_warp) filters_array = [new ShaderFilter(pov)];
		else filters_array = [];
		camGame.filters = filters_array;

		var border_offset:Int = 200;
		FlxG.worldBounds.set(0 - border_offset, 0, main_background.width + border_offset, main_background.height);
		camFollow.setPosition(FlxG.width / 2, main_background.height / 2);
		if (mapData.cam_offsets != null)
		{
			var found_location:Bool = false;
			for (i in 0...mapData.cam_offsets.length)
			{
				if (mapData.cam_offsets[i][0] == comeFrom)
				{
					found_location = true;
					camFollow.x += mapData.cam_offsets[i][1];
					camFollow.y += mapData.cam_offsets[i][2];
				}
			}

			if (!found_location)
			{
				camFollow.x += mapData.cam_offsets[0][1];
				camFollow.y += mapData.cam_offsets[0][2];
			}

			snapToWalls();
			FlxG.camera.snapToTarget();
		}
		FlxG.camera.snapToTarget();
		disableWallSnap = false;

		if (script != null) script = null;

		var filePath = FunkinScript.getPath('data/overworld/maps/$map_name');
		if (FunkinAssets.exists(filePath, TEXT))
		{
			script = FunkinScript.fromFile(filePath, map_name);
			if (script.__garbage)
			{
				script = FlxDestroyUtil.destroy(script);
				return;
			}

			callScriptFunc('onLoad');
		}
	}

	public function reloadObjects()
	{
		for (object in objects.members)
		{
			object.destroy();
		}
		objects.clear();

		if (mapData.objects == null) return;

		for (i in 0...mapData.objects.length)
		{
			var new_object:Object = new Object(mapData.objects[i].name, mapData.objects[i].position[0], mapData.objects[i].position[1],
				'overworld/maps/$map_name/objects/' + mapData.objects[i].object_path, mapData.scale, mapData.objects[i].dialogue, mapData.objects[i].location,
				mapData.objects[i].remove_outline);
			new_object.ID = i;
			objects.add(new_object);
		}
	}

	public function reloadTeleporters()
	{
		for (teleporter in teleporters.members)
		{
			teleporter.destroy();
		}

		if (mapData.teleporter_hitboxes == null) return;

		for (i in 0...mapData.teleporter_hitboxes.length)
		{
			var teleporter:Teleporter = new Teleporter(mapData.teleporter_hitboxes[i].position[0], mapData.teleporter_hitboxes[i].position[1],
				mapData.teleporter_hitboxes[i].size[0], mapData.teleporter_hitboxes[i].size[1], mapData.teleporter_hitboxes[i].location,
				mapData.teleporter_hitboxes[i].location_name, mapData.teleporter_hitboxes[i].direction);
			teleporter.ID = i;
			teleporters.add(teleporter);
		}
	}

	function snapToWalls()
	{
		if (disableWallSnap) return;
		if (camFollow.x < FlxG.width / 2) camFollow.x = FlxG.width / 2;
		if (camFollow.x > main_background.width - ((FlxG.width / 2) / map_zoom)) camFollow.x = main_background.width - ((FlxG.width / 2) / map_zoom);
	}

	function loadMapData(map:String):Null<MapData>
	{
		var path = Paths.getPath('data/overworld/maps/$map.json', TEXT, null, true);
		return FunkinAssets.exists(path, TEXT) ? cast FunkinAssets.parseJson(FunkinAssets.getContent(path)) : null;
	}

	public function loadSong(songs:Array<String>, ?storyMode:Bool = true)
	{
		canMove = false;
		curMusic = '';

		PlayState.storyMeta.difficulty = FlxG.save.data.story_difficulty;

		if (storyMode)
		{
			PlayState.isStoryMode = true;
			PlayState.storyMeta.playlist = songs;
			PlayState.storyMeta.score = 0;
			PlayState.storyMeta.misses = 0;
		}
		else
		{
			PlayState.isStoryMode = false;
		}
		PlayState.SONG = Chart.fromSong(songs[0], FlxG.save.data.story_difficulty);

		FlxG.switchState(PlayState.new);
	}

	public function reloadState(?loadCutscene:String = '')
	{
		curCutscene = loadCutscene;
		FlxG.switchState(() -> {
			new OverworldState();
		});
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}

	public function callScriptFunc(func:String, ?params:Array<Dynamic>)
	{
		if (script == null) return;
		if (script.exists(func))
		{
			if (params != null) script.call(func, params);
			else script.call(func);
		}
	}
}
