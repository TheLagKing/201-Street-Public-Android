package funkin.objects.overworld;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.sound.FlxSound;
import openfl.Assets;
import flixel.addons.text.FlxTypeText;
import sys.io.File;
import haxe.Json;
import funkin.objects.overworld.OverworldUI;
import funkin.backend.PlayerSettings;

using StringTools;

typedef EventData =
{
	?eventName:String,
	?value1:String,
	?value2:String,
	?startDelay:Float
}

typedef DialogueInfo =
{
	?character:String,
	?expression:String,
	?dialogue:String,
	?events:Array<EventData>
}

typedef DialogueData =
{
	?dialogue_info:Array<DialogueInfo>
}

typedef PortraitInfo =
{
	?expression:String,
	?offsets:Array<Int>
}

typedef PortraitData =
{
	?portrait_info:Array<PortraitInfo>
}

class DialogueBox extends FlxTypedSpriteGroup<FlxSprite>
{
	var dialogueBox:FlxSprite;
	var curDialogue:Dynamic;

	var controls = PlayerSettings.player1.controls;

	var curDialoguePos:Int = 0;

	public static var canProgressDialogue:Bool = false;

	var dialogue_box_array:Array<FlxSprite>;
	var dialogue_portrait:FlxSprite;
	var buttonPrompts:FlxSprite;
	var curCharacterName:FlxText;
	var curNPC:String;
	var curDialogueText:FlxTypeText;

	var character_vocal_expression:String;

	public function new()
	{
		super();

		curDialogue = loadDialogueFromJson('dialogue_test', true);

		dialogue_box_array = [];
		character_vocal_expression = '';

		dialogue_portrait = new FlxSprite(730, 70);
		dialogue_portrait.visible = false;
		dialogue_portrait.antialiasing = true;
		dialogue_box_array.push(dialogue_portrait);

		dialogueBox = new FlxSprite(0, 445).loadGraphic(Paths.image('overworld/ui/txtbox'));
		dialogueBox.visible = false;
		dialogueBox.setGraphicSize(Std.int(dialogueBox.width * 0.66));
		dialogueBox.updateHitbox();
		dialogueBox.screenCenter(X);
		dialogueBox.antialiasing = true;
		dialogue_box_array.push(dialogueBox);

		buttonPrompts = new FlxSprite(735, 645).loadGraphic(Paths.image('overworld/ui/txtbuttonprompts'));
		buttonPrompts.visible = false;
		buttonPrompts.setGraphicSize(Std.int(buttonPrompts.width * 0.4));
		buttonPrompts.updateHitbox();
		buttonPrompts.antialiasing = true;
		dialogue_box_array.push(buttonPrompts);

		curDialogueText = new FlxTypeText(dialogueBox.x + 118, dialogueBox.y + 83, Std.int(dialogueBox.width) - 200, curDialogue[curDialoguePos].dialogue, 34,
			true);
		curDialogueText.delay = 0.03;
		curDialogueText.waitTime = 2.0;
		curDialogueText.color = 0xffFFFFFF;
		curDialogueText.font = Paths.font('yu-gothic-bold.ttf');
		curDialogueText.skipKeys = ["X", 'SHIFT'];
		curDialogueText.visible = false;
		curDialogueText.antialiasing = true;
		dialogue_box_array.push(curDialogueText);

		reloadDialoguePortrait();

		curCharacterName = new FlxText(dialogueBox.x + 35, dialogueBox.y - 5, 293, 'TEST', 32);
		curCharacterName.fieldHeight = 200;
		curCharacterName.color = 0xffFFFFFF;
		curCharacterName.font = Paths.font('Uni Sans Heavy Italic.otf');
		curCharacterName.visible = false;
		curCharacterName.autoSize = false;
		curCharacterName.alignment = CENTER;
		curCharacterName.antialiasing = true;
		dialogue_box_array.push(curCharacterName);

		for (item in dialogue_box_array)
			add(item);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressedRight && curDialogueText != null)
		{
			curDialogueText.skip();
		}
		if ((controls.ACCEPT || FlxG.keys.justPressed.Z || FlxG.mouse.justPressed) && canProgressDialogue)
		{
			if (curDialoguePos != curDialogue.length - 1)
			{
				curDialoguePos += 1;
				nextDialogue();
			}
			else
			{
				endDialogue();
			}
		}

		var new_rect:FlxRect = new FlxRect(0, 0, dialogue_portrait.width, dialogueBox.y - dialogue_portrait.y + 50);
		dialogue_portrait.clipRect = new_rect;

		// if(FlxG.keys.justPressed.SPACE && !canProgressDialogue){
		//     loadDialogue();
		// }
	}

	public function loadDialogue(?custom_dialogue:String = null, ?preload_shit:Bool = false)
	{
		curDialogue = loadDialogueFromJson(custom_dialogue, preload_shit);
		curDialoguePos = 0;

		character_vocal_expression = '';

		for (item in dialogue_box_array)
			item.visible = true;
		canProgressDialogue = true;
		nextDialogue();
	}

	public function nextDialogue(?skipEvents:Bool = false)
	{
		curCharacterName.text = "";
		if (!skipEvents) loadEvents();
		if (OverworldState.instance != null)
		{
			OverworldState.instance.callScriptFunc('onDialogue', [
				curDialogue[curDialoguePos].character,
				curDialogue[curDialoguePos].expression,
				curDialogue[curDialoguePos].dialogue
			]);
		}

		if (canProgressDialogue && curDialogue[curDialoguePos].dialogue != null)
		{
			canProgressDialogue = false;

			if (curNPC != curDialogue[curDialoguePos].character.toUpperCase()) reloadDialoguePortrait(true);
			else reloadDialoguePortrait();
			curNPC = curDialogue[curDialoguePos].character.toUpperCase();
			if (curCharacterName.text == "") curCharacterName.text = "\n" + curNPC;
			curDialogueText.resetText(curDialogue[curDialoguePos].dialogue);
			curDialogueText.start(0.03, false, false, null, finishDia.bind());
		}
		else if (curDialogue[curDialoguePos].dialogue == null)
		{
			endDialogue();
		}
	}

	function reloadDialoguePortrait(?change_char:Bool = false)
	{
		FlxTween.cancelTweensOf(dialogue_portrait);
		if (sys.FileSystem.exists('assets/images/overworld/portraits/'
			+ curDialogue[curDialoguePos].character.toLowerCase() + '/' + curDialogue[curDialoguePos].expression.toLowerCase() + '.png'))
		{
			dialogue_portrait.alpha = 1;

			var portraitOffset:Array<Int> = [0, 0];

			var path = Paths.getPath('data/overworld/portraits/' + curDialogue[curDialoguePos].character + '.json', TEXT, null, true);
			var json_portrait:PortraitData = FunkinAssets.exists(path, TEXT) ? cast FunkinAssets.parseJson(FunkinAssets.getContent(path)) : null;

			if (json_portrait != null)
			{
				for (item in json_portrait.portrait_info)
				{
					if (item.expression.toLowerCase() == curDialogue[curDialoguePos].expression.toLowerCase())
					{
						portraitOffset = item.offsets;
						break;
					}
				}
			}

			if (dialogue_portrait != null)
			{
				dialogue_portrait.loadGraphic(Paths.image('overworld/portraits/'
					+ curDialogue[curDialoguePos].character.toLowerCase() + '/' + curDialogue[curDialoguePos].expression.toLowerCase()));
			}

			dialogue_portrait.setPosition(890 - dialogue_portrait.width / 2 + portraitOffset[0], 70 + portraitOffset[1]);

			var char_offset:Int = 10;
			var tween_time:Float = 0.35;

			if (change_char)
			{
				for (item in group.members)
				{
					item.y += char_offset;
					item.alpha = 0;
					FlxTween.tween(item, {y: item.y - char_offset, alpha: 1}, tween_time, {ease: FlxEase.quartOut});
				}
			}
			else
			{
				char_offset = 5;
				dialogue_portrait.y += char_offset;
				FlxTween.tween(dialogue_portrait, {y: dialogue_portrait.y - char_offset}, tween_time, {ease: FlxEase.quartOut});
			}
		}
		else dialogue_portrait.alpha = 0;

		var talk_sound_directory:String = '201-street/talk_sounds/' + curDialogue[curDialoguePos].character.toLowerCase();
		talk_sound_directory = talk_sound_directory.replace(' ', '-');
		if (sys.FileSystem.exists('assets/sounds/$talk_sound_directory.ogg'))
		{
			if (sys.FileSystem.exists('assets/sounds/$talk_sound_directory' + '-$character_vocal_expression' + '.ogg'))
			{
				talk_sound_directory += '-$character_vocal_expression';
			}

			if (character_vocal_expression == "none") curDialogueText.sounds = null;
			else curDialogueText.sounds = [FlxG.sound.load(Paths.sound(talk_sound_directory))];
		}
		else
		{
			trace("yo");
			curDialogueText.sounds = null;
		}
	}

	public static function finishDia():Void
	{
		canProgressDialogue = true;
	}

	function loadDialogueFromJson(dialogue_path:String, ?preload_shit:Bool = false):Null<DialogueInfo>
	{
		var path = preload_shit ? Paths.getPath('data/overworld/dialogue/$dialogue_path.json', TEXT, null,
			true) : Paths.getPath('data/overworld/dialogue/' + OverworldState.map_name + '/$dialogue_path.json', TEXT, null, true);
		var json_dialogue = FunkinAssets.exists(path, TEXT) ? cast FunkinAssets.parseJson(FunkinAssets.getContent(path)) : null;

		if (json_dialogue != null) return json_dialogue.dialogue_info;
		return null;
	}

	function loadEvents()
	{
		if (curDialogue[curDialoguePos].events != null)
		{
			for (i in 0...curDialogue[curDialoguePos].events.length)
			{
				runEvent(curDialogue[curDialoguePos].events[i].eventName, curDialogue[curDialoguePos].events[i].value1,
					curDialogue[curDialoguePos].events[i].value2, curDialogue[curDialoguePos].events[i].startDelay);
			}
		}
	}

	function runEvent(eventName:String, value1:String, value2:String, ?startDelay:Float)
	{
		if (startDelay == null)
		{
			eventFunctions(eventName, value1, value2);
			return;
		}

		new FlxTimer().start(startDelay, function(tmr:FlxTimer) {
			eventFunctions(eventName, value1, value2);
		});
	}

	function eventFunctions(eventName:String, value1:String, value2:String)
	{
		switch (eventName)
		{
			case 'Play Sound':
				var sound_vol:Float = value2 == '' ? 0.7 : Std.parseFloat(value2);
				FunkinSound.play(Paths.sound('201-street/$value1'), sound_vol);

			case 'Can Move':
				var canMove:Bool = false;
				if (value1.toLowerCase() == 'true') canMove = true;
				OverworldState.instance.canMove = canMove;

			case 'Pause Dialogue':
				for (item in dialogue_box_array)
					item.visible = false;
				canProgressDialogue = false;
				var pause_time:Float = 2.5;
				if (value1 != '' && value1 != null) pause_time = Std.parseFloat(value1);

				if (pause_time != 0)
				{
					new FlxTimer().start(pause_time, function(tmr:FlxTimer) {
						for (item in dialogue_box_array)
							item.visible = true;
						canProgressDialogue = true;
						nextDialogue(true);
					});
				}

			case 'Load Dialogue':
				trace('EVENT LOAD DIALOGUE');
				loadDialogue(value1);

			case 'End Dialogue':
				endDialogue();

			case 'Mouse Visibility':
				var vis_bool:Bool = false;
				if (value1.toLowerCase() == 'true') vis_bool = true;
				FlxG.mouse.visible = vis_bool;

			case 'Change Background':
				var vis_bool:Bool = false;
				if (value2.toLowerCase() == 'true') vis_bool = true;
				OverworldState.ui.change_background(value1, vis_bool);

			case 'Hide UI':
				var vis_bool:Bool = false;
				var temp_time:Float = 2.5;
				if (value1.toLowerCase() == 'true') vis_bool = true;
				if (value2 != '' && value2 != null) temp_time = Std.parseFloat(value2);
				OverworldState.ui.moveItems(vis_bool, temp_time);

			case 'Change Map':
				OverworldState.instance.swap_map(value1);

			case 'Transition Map':
				OverworldState.instance.transition_maps(value1);

			case 'Fade Music':
				FlxTween.cancelTweensOf(FlxG.sound.music);
				var fade_in:Bool = false;
				if (value1.toLowerCase() == 'in') fade_in = true;
				var temp_time:Float = 1.2;
				if (value2 != '' && value2 != null) temp_time = Std.parseFloat(value2);

				FlxTween.tween(FlxG.sound.music, {pitch: fade_in ? 1 : 0, volume: fade_in ? 1 : 0}, temp_time);

			case 'Fade Music Normally':
				FlxTween.cancelTweensOf(FlxG.sound.music);
				var fade_in:Bool = false;
				if (value1.toLowerCase() == 'in') fade_in = true;
				var temp_time:Float = 1.2;
				if (value2 != '' && value2 != null) temp_time = Std.parseFloat(value2);

				FlxG.sound.music.pitch = 1;
				FlxTween.tween(FlxG.sound.music, {volume: fade_in ? 1 : 0}, temp_time);

			case 'Reload Music':
				FlxTween.cancelTweensOf(FlxG.sound.music);
				OverworldState.instance.reloadMusic(value1);

			case 'Fade Camera':
				var fade_in:Bool = false;
				if (value1.toLowerCase() == 'in') fade_in = true;
				var temp_time:Float = 1;
				if (value2 != '' && value2 != null) temp_time = Std.parseFloat(value2);

				var col_amt:Float = 6.0;
				if (fade_in) col_amt = 0.0;

				OverworldState.instance.posterize.setFloat("color_amt", col_amt);
				for (i in 0...4)
				{
					new FlxTimer().start(i * (temp_time / 4), function(tmr:FlxTimer) {
						if (fade_in)
						{
							col_amt += 2;
							OverworldState.camHUDoverlay.alpha -= 0.25;
						}
						else
						{
							col_amt -= 2;
							OverworldState.camHUDoverlay.alpha += 0.25;
						}

						if (OverworldState.camHUDoverlay.alpha == 0)
						{
							var filters_array:Array<openfl.filters.BitmapFilter>;
							if (OverworldState.mapData.screen_warp) filters_array = [new openfl.filters.ShaderFilter(OverworldState.instance.pov)];
							else filters_array = [];
							OverworldState.instance.camGame.filters = filters_array;
						}

						OverworldState.instance.posterize.setFloat("color_amt", col_amt);
					});
				}

			case 'Fade Camera Normally':
				var fade_in:Bool = false;
				if (value1.toLowerCase() == 'in') fade_in = true;
				var temp_time:Float = 1;
				if (value2 != '' && value2 != null) temp_time = Std.parseFloat(value2);

				FlxTween.tween(OverworldState.camHUDoverlay, {alpha: fade_in ? 0 : 1});

				var filters_array:Array<openfl.filters.BitmapFilter>;
				if (OverworldState.mapData.screen_warp) filters_array = [new openfl.filters.ShaderFilter(OverworldState.instance.pov)];
				else filters_array = [];
				OverworldState.instance.camGame.filters = filters_array;

			case 'Load Song':
				var songs:Array<String> = value1.split(', ');
				trace(songs);
				OverworldState.instance.loadSong(songs);

			// Event for entering overworld after finishing dialogue in main menu
			case 'Load Overworld':
				TitleState201.instance.loadOverworld();

			case 'Save Data':
				if (FlxG.save.data.overworldData != null)
				{
					if (FlxG.save.data.overworldData.contains(value1) != true)
					{
						FlxG.save.data.overworldData.push(value1);
						FlxG.save.flush();
					}
				}
			case 'Save Beaten Song Data':
				if (FlxG.save.data.notifTypes != null && FlxG.save.data.songsBeaten.contains(value1.toLowerCase()) != true)
				{
					if (FlxG.save.data.notifTypes.contains("song") == false) FlxG.save.data.notifTypes.push("song");
					trace("PUSHED SONG");
					if (FlxG.save.data.notifTypes.contains("checklist") == false) FlxG.save.data.notifTypes.push("checklist");
					trace("PUSHED CHECKLIST");
					if (value1.toLowerCase() == 'ghostface' || value1.toLowerCase() == 'dandadan' || value1.toLowerCase() == 'scp'
						|| value1.toLowerCase() == 'monster' || value1.toLowerCase() == 'bill-cipher')
					{
						if (FlxG.save.data.notifTypes.contains("contact") == false) FlxG.save.data.notifTypes.push("contact");
						trace("PUSHED CONTACT");
					}
					OverworldUI.pushedNew = true;
					trace('Dialog is is true ' + OverworldUI.pushedNew);
					FlxG.save.flush();
					trace(FlxG.save.data.notifTypes);
				}
				if (FlxG.save.data.songsBeaten != null)
				{
					if (FlxG.save.data.songsBeaten.contains(value1.toLowerCase()) != true)
					{
						FlxG.save.data.songsBeaten.push(value1.toLowerCase());
						FlxG.save.flush();
					}
				}

			case 'Add Checklist Notif':
				if (FlxG.save.data.notifTypes != null) if (!FlxG.save.data.notifTypes.contains("checklist")) FlxG.save.data.notifTypes.push("checklist");

			case 'Clear Data':
				if (FlxG.save.data.overworldData != null)
				{
					FlxG.save.data.overworldData = [];
					FlxG.save.flush();
				}
				if (FlxG.save.data.songsBeaten != null)
				{
					FlxG.save.data.songsBeaten = [];
					FlxG.save.flush();
				}
				if (FlxG.save.data.notifTypes != null)
				{
					FlxG.save.data.notifTypes = [];
					FlxG.save.flush();
				}

			case 'Reload Objects':
				OverworldState.instance.reloadObjects();

			case 'Vocal Blip Expression':
				character_vocal_expression = value1;

			case 'Change Dialogue Name':
				curCharacterName.text = '\n' + value1;

			case 'Title Screen Events':
				if (TitleState201.instance != null)
				{
					TitleState201.instance.runEvent(value1);
				}
		}

		if (OverworldState.instance == null) return;
		OverworldState.instance.callScriptFunc('onEvent', [eventName, value1, value2]);
	}

	function endDialogue()
	{
		for (item in dialogue_box_array)
			item.visible = false;
		canProgressDialogue = false;
		if (OverworldState.instance == null) return;
		OverworldState.instance.canMove = true;
		OverworldState.instance.callScriptFunc('onEndDialogue');
	}
}
