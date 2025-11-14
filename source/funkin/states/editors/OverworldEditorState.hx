package funkin.states.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import openfl.filters.ShaderFilter;

import funkin.objects.overworld.DialogueBox;
import funkin.game.shaders.Outline;

import funkin.states.OverworldState.MapData;
import funkin.states.OverworldState.ObjectData;

import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;

import haxe.Json;

class OverworldEditorState extends MusicBeatState
{
	var camFollow:FlxObject;
	var cameraSpeed:Float = 1.15;
	var defaultCamZoom:Float = 1.1;

	var map_name:String;
	
	var main_background:FlxSprite;
	var main_background_OBJECTS:FlxSprite;
	var objects:FlxTypedGroup<FlxSprite>;

	public static var canMove:Bool = true;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var camHUDoverlay:FlxSprite;
	var dialogue_box:DialogueBox;

	var posterize:Dynamic;
	var pov:Dynamic;

	var mapData:MapData = null;

	override function create()
	{		
		super.create();

		map_name = OverworldState.map_name;

		camGame = new FlxCameraEx();
		camHUD = new FlxCameraEx();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(0, 0);		
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 0);

		main_background = new FlxSprite();
		add(main_background);

		main_background_OBJECTS = new FlxSprite();
		add(main_background_OBJECTS);

		objects = new FlxTypedGroup<FlxSprite>();
		add(objects);

		swap_map(map_name);

		FlxG.mouse.visible = true;
	}
	
	var camera_movement_amt:Float = 6;

	var outlineWidth:Float;
	var outlineHeight:Float;

	var objectLockedToHand:FlxSprite;

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;

		final lerpRate = 0.04 * cameraSpeed;
		FlxG.camera.followLerp = canMove ? lerpRate : 0;

		handle_movement();

		if(FlxG.keys.justPressed.BACKSPACE) FlxG.switchState(()->{new OverworldState();});
		if(FlxG.keys.justPressed.F5) FlxG.switchState(()->{new OverworldEditorState();});
	
		if(controls.ACCEPT){
			saveMap();
		}

		if(objectLockedToHand != null){
			objectLockedToHand.setPosition(FlxG.mouse.x - (objectLockedToHand.width / 2), FlxG.mouse.y - (objectLockedToHand.height / 2));
			if(FlxG.mouse.justPressedRight){
				trace(objectLockedToHand.x, objectLockedToHand.y);
				for(i in 0...mapData.objects.length){
					if(objectLockedToHand.ID == i){
						mapData.objects[i].position = [Std.int(objectLockedToHand.x), Std.int(objectLockedToHand.y)];
					}
				}
				objectLockedToHand = null;
			}
		}

		super.update(elapsed);

		for(object in objects.members){
			if((FlxG.mouse.x > object.x) && (object.x + object.width) > FlxG.mouse.x && (FlxG.mouse.y > object.y && FlxG.mouse.y < (object.y + object.height))){
				if(FlxG.mouse.justPressed && objectLockedToHand != object){
					objectLockedToHand = object;
				}
			} 
		}
	}

	function handle_movement(){
		if(!canMove) return;

		if(FlxG.keys.pressed.SHIFT){
			defaultCamZoom = 1.1;
			camera_movement_amt = 11;
		}
		else{
			defaultCamZoom = 1;
			camera_movement_amt = 5;
		}

		if(FlxG.keys.pressed.LEFT){
			camFollow.x -= camera_movement_amt;
		}

		if(FlxG.keys.pressed.RIGHT){
			camFollow.x += camera_movement_amt;
		}

		if(FlxG.keys.justPressed.E){
			FlxG.camera.zoom += 0.1;
		}

		if(FlxG.keys.justPressed.Q){
			FlxG.camera.zoom -= 0.1;
		}

		if(camFollow.x < FlxG.width / 2) camFollow.x = FlxG.width / 2;
		if(camFollow.x > main_background.width - (FlxG.width / 2)) camFollow.x = main_background.width - (FlxG.width / 2);

		// if(FlxG.keys.pressed.SPACE){
		// 	trace(camFollow.x, main_background.width);
		// }		
	}

	function newShader(?fragFile:String, ?vertFile:String){
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

	function swap_map(new_map:String){
		map_name = new_map;

		for(object in objects.members){
			object.destroy();
		}

		mapData = loadMapData(map_name);

		main_background.loadGraphic(Paths.image('overworld/maps/$map_name/map'));
		main_background.setGraphicSize(Std.int(main_background.width * mapData.scale));
		main_background.updateHitbox();

		main_background_OBJECTS.loadGraphic(Paths.image('overworld/maps/$map_name/map_objects'));
		main_background_OBJECTS.setGraphicSize(Std.int(main_background_OBJECTS.width * mapData.scale));
		main_background_OBJECTS.updateHitbox();
		main_background_OBJECTS.alpha = 0.5;

		for(i in 0...mapData.objects.length){
			var new_object:FlxSprite = new FlxSprite(mapData.objects[i].position[0], mapData.objects[i].position[1]).loadGraphic(Paths.image('overworld/maps/$map_name/objects/' + mapData.objects[i].object_path));
			new_object.ID = i;
			new_object.setGraphicSize(Std.int(new_object.width * mapData.scale));
			new_object.updateHitbox();
			objects.add(new_object);
		}

		FlxG.worldBounds.set(0, 0, main_background.width, main_background.height);
		camFollow.setPosition(FlxG.width / 2, main_background.height / 2);	
		FlxG.camera.snapToTarget();	
	}

	function loadMapData(map:String):Null<MapData>
	{
		var path = Paths.getPath('data/overworld/maps/$map.json', TEXT, null, true);
		return FunkinAssets.exists(path, TEXT) ? cast FunkinAssets.parseJson(FunkinAssets.getContent(path)) : null;
	}

	var _file:FileReference = null;
	
	function saveMap()
	{
		var data:String = Json.stringify(mapData, "\t");
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, '$map_name.json');
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}
	
	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}
	
	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}
}
