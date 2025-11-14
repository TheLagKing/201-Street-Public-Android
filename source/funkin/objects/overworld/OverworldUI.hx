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
import funkin.game.shaders.Outline;
import openfl.Assets;
import flixel.addons.text.FlxTypeText;
import sys.io.File;
import haxe.Json;

using StringTools;

class OverworldUI extends FlxTypedSpriteGroup<FlxSprite>
{
	var dialogue_background:FlxSprite;

	var visualiser_bars:VisualiserBars;
	var music_bg:FlxSprite;
	var music_box:FlxSprite;
	var music_txt:FlxText;
	var music_note:FlxSprite;

	var location_name:FlxText;
	var location_circle:FlxSprite;
	var location_box:FlxSprite;

	var billie_bg:FlxSprite;
	var billie:FlxSprite;

	var object_name:FlxText;

	public var phone:FlxSprite;

	var notif:FlxSprite;

	public static var black_bg:FlxSprite;

	public var phone_group:Phone;

	public static var pushedNew:Bool;

	static var OBJECT_NAME_Y:Int = 20;

	var object_is_displaying:Bool = false;
	var object_visibility:Float = 0;
	var object_sine:Float = 0;

	var ui_mouse_object:FlxSprite;

	var tween_objects:Array<Dynamic>;

	public var object_positions:Array<Dynamic>;

	var tween_offset:Int = 450;

	var totalElapsed:Float = 0;

	public var muteBuzz:Bool = false;

	public function new()
	{
		super();

		dialogue_background = new FlxSprite();
		change_background('placeholder_background', false);
		dialogue_background.antialiasing = true;
		add(dialogue_background);

		visualiser_bars = new VisualiserBars(FlxG.sound.music, false);
		visualiser_bars.ID = 0;
		add(visualiser_bars);

		music_bg = new FlxSprite(32, -5).loadGraphic(Paths.image('overworld/ui/music_bg'));
		music_bg.setGraphicSize(Std.int(music_bg.width * 0.6666666667));
		music_bg.updateHitbox();
		music_bg.ID = 0;
		add(music_bg);

		trace(music_bg.x, music_bg.y);

		music_box = new FlxSprite().loadGraphic(Paths.image('overworld/ui/music_box'));
		music_box.setGraphicSize(Std.int(music_box.width * 0.6666666667));
		music_box.updateHitbox();
		music_box.x = music_bg.x - music_bg.width + music_box.width;
		music_box.y = music_bg.y + music_bg.height - 2;
		music_box.ID = 0;
		add(music_box);

		music_txt = new FlxText(music_box.x + 10, music_box.y + 10, 0, '', 26);
		music_txt.color = 0xff000000;
		music_txt.font = Paths.font('ATTFShinGoProBold.ttf');
		music_txt.antialiasing = true;
		music_txt.ID = 0;
		add(music_txt);

		music_note = new FlxSprite().loadGraphic(Paths.image('overworld/ui/music_note'));
		music_note.antialiasing = true;
		add(music_note);

		location_box = new FlxSprite().loadGraphic(Paths.image('overworld/ui/location_box'));
		location_box.setGraphicSize(Std.int(location_box.width * 0.6666666667));
		location_box.updateHitbox();
		location_box.x = FlxG.width - location_box.width - 20;
		location_box.y = 65;
		location_box.ID = 1;
		add(location_box);

		location_circle = new FlxSprite().loadGraphic(Paths.image('overworld/ui/location_circle'));
		location_circle.setGraphicSize(Std.int(location_circle.width * 0.6666666667));
		location_circle.updateHitbox();
		location_circle.x = FlxG.width - location_circle.width - 20;
		location_circle.y = 25;
		location_circle.ID = 1;
		add(location_circle);

		location_box.x -= location_circle.width / 2;

		location_name = new FlxText(location_box.x, location_box.y + 22, 0,
			'LOCATION').setFormat(Paths.font('ATTFShinGoProBold.ttf'), 32, 0xffFFFFFF, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, 0xFF28774c);
		location_name.antialiasing = true;
		location_name.borderSize = 2.5;
		location_name.ID = 1;
		add(location_name);

		var skew_shader = OverworldState.instance.newShader('skew');
		skew_shader.setFloat('curveX', -0.04);
		skew_shader.setFloat('curveY', 0.0);
		location_name.shader = skew_shader;

		billie_bg = new FlxSprite().loadGraphic(Paths.image('overworld/ui/corner_billie_bg'));
		billie_bg.setGraphicSize(Std.int(billie_bg.width * 0.6666666667));
		billie_bg.updateHitbox();
		billie_bg.y = FlxG.height - billie_bg.height;
		billie_bg.ID = 0;
		add(billie_bg);

		billie = new FlxSprite().loadGraphic(Paths.image('overworld/ui/corner_billie'));
		billie.setGraphicSize(Std.int(billie.width * 0.6666666667));
		billie.updateHitbox();
		billie.x = billie_bg.width / 2 - billie.width / 2;
		billie.y = FlxG.height - billie.height;
		billie.ID = 0;
		add(billie);

		object_name = new FlxText(0,
			OBJECT_NAME_Y + 5).setFormat(Paths.font('Happy School.ttf'), 26, FlxColor.BLACK, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		object_name.antialiasing = ClientPrefs.globalAntialiasing;
		object_name.alpha = 0;
		object_name.borderSize = 2;
		object_name.ID = 2;
		add(object_name);

		phone = new FlxSprite(950, 518).loadGraphic(Paths.image('overworld/ui/phone_ui_asset'));
		phone.setGraphicSize(Std.int(phone.width * 0.6666666667));
		phone.updateHitbox();
		phone.ID = 2;
		phone.y += phone.height;
		add(phone);

		notif = new FlxSprite(950, 518).loadGraphic(Paths.image('overworld/ui/phonenotif'));
		notif.setGraphicSize(Std.int(notif.width * 0.6666666667));
		notif.updateHitbox();
		notif.ID = 2;
		notif.x = phone.x;
		notif.y = phone.y;
		notif.visible = false;
		notif.zIndex = 2;
		add(notif);

		trace("YOOOO THIS SHIT LACED " + FlxG.save.data.notifTypes);

		black_bg = new FlxSprite().makeGraphic(1300, 800, FlxColor.BLACK);
		black_bg.alpha = 0;
		add(black_bg);

		phone_group = new Phone();
		phone_group.y = 1280 + 50;
		add(phone_group);

		tween_objects = [music_bg, music_box, music_txt, location_box, location_circle, billie_bg, billie];
		object_positions = [];

		for (item in tween_objects)
		{
			object_positions.push([item, item.x, item.ID == 0 ? item.x - tween_offset : item.x + tween_offset]);
		}

		scroll_text();
		moveItems();
	}

	var text_offset:Float = 0;
	var scrolling_text:Bool = false;

	var outlineBorderSize:Float;

	override function update(elapsed:Float)
	{
		location_circle.angle += 0.1 * (60 * elapsed);

		totalElapsed += elapsed;

		if (FlxG.save.data.notifTypes.contains('song')
			|| FlxG.save.data.notifTypes.contains('contact')
			|| FlxG.save.data.notifTypes.contains('checklist'))
		{
			if (phone.visible)
			{
				notif.visible = true;
			}
			else
			{
				notif.visible = false;
			}
		}
		else
		{
			notif.visible = false;
		}

		if (notif.visible) notif.alpha = (Math.sin(totalElapsed * 5) > 0) ? 1 : 0;

		if (scrolling_text && music_txt.width > 200)
		{
			if (text_offset > music_txt.width - 200)
			{
				wait_to_scroll();
			}
			else
			{
				text_offset += 1 * (60 * elapsed);
			}

			scroll_text();
		}
		else text_offset = 0;

		music_note.x = music_txt.x;

		super.update(elapsed);

		object_visibility += (object_is_displaying ? (elapsed * 5) : (elapsed * -4));
		object_visibility = FlxMath.bound(object_visibility, 0, 1);
		object_sine = FlxMath.fastSin(object_visibility * (Math.PI / 2));

		object_name.y = FlxMath.lerp(OBJECT_NAME_Y + 2, OBJECT_NAME_Y, object_sine);
		object_name.alpha = object_sine;

		var phone_x_offset:Int = -100;
		if ((FlxG.mouse.getScreenPosition().x + phone_x_offset >= phone.x
			&& phone.x + phone.width - phone_x_offset > FlxG.mouse.getScreenPosition().x)
			&& (FlxG.mouse.getScreenPosition().y >= phone.y + 100)
			&& OverworldState.instance.canMove
			&& phone.visible)
		{
			phone.shader = new Outline(0xFFFFFFFF, outlineBorderSize, outlineBorderSize);
			phone.y = FlxMath.lerp(phone.y, 250, FlxMath.bound(elapsed * 6, 0, 1));
			notif.y = phone.y;

			if (FlxG.mouse.justPressed)
			{
				OverworldState.instance.canMove = false;
				FlxTween.tween(black_bg, {alpha: 0.5}, 0.75, {ease: FlxEase.quartOut});
				phone_group.openPhone();
			}
		}
		else if (items_on_screen)
		{
			phone.shader = null;
			phone.y = FlxMath.lerp(phone.y, 510, FlxMath.bound(elapsed * 6, 0, 1));
			notif.y = phone.y;
		}

		visualiser_bars.setPosition(music_bg.x + 8, music_bg.y - 35);
		location_name.x = location_box.x + location_box.width / 2 - location_name.width / 2 - 34;
	}

	var scroll_timer:FlxTimer;

	public function wait_to_scroll()
	{
		scrolling_text = false;
		scroll_timer = new FlxTimer().start(2, function(tmr:FlxTimer) {
			FlxTween.tween(music_note, {alpha: 0}, 0.75);
			FlxTween.tween(music_txt, {alpha: 0}, 0.75,
				{
					onComplete: function(t:FlxTween) {
						text_offset = 0;
						scroll_text();

						FlxTween.tween(music_note, {alpha: 1}, 0.75);
						FlxTween.tween(music_txt, {alpha: 1}, 0.75,
							{
								onComplete: function(t:FlxTween) {
									scroll_timer = new FlxTimer().start(2, function(tmr:FlxTimer) {
										scrolling_text = true;
									});
								}
							});
					}
				});
		});
	}

	public function displayObjectText(newText:String)
	{
		object_is_displaying = true;

		object_name.text = newText;
		object_name.screenCenter(X);
	}

	public function removeObjectText()
	{
		object_is_displaying = false;
	}

	public function change_background(background_name:String, ?temp_visible:Bool = true)
	{
		dialogue_background.loadGraphic(Paths.image('overworld/ui/backgrounds/$background_name'));
		dialogue_background.visible = temp_visible;
	}

	function scroll_text()
	{
		var new_rect:FlxRect = new FlxRect(text_offset, 0, music_box.width - 11, music_box.height);
		music_txt.clipRect = new_rect;
		music_txt.x = music_box.x + 6 - text_offset;

		var new_rect2:FlxRect = new FlxRect(text_offset, 0, music_note.width, music_box.height);
		music_note.clipRect = new_rect2;
		music_note.y = music_txt.y + 3;
	}

	public function updateMusic(?songName:String = '')
	{
		visualiser_bars.snd = FlxG.sound.music;
		visualiser_bars.initAnalyzer();

		if (songName != '') music_txt.text = '    - ' + songName;

		scrolling_text = false;
		text_offset = 0;
		if (scroll_timer != null)
		{
			scroll_timer.active = false;
		}

		scroll_text();

		FlxTween.cancelTweensOf(music_txt);
		FlxTween.cancelTweensOf(music_note);
		music_note.alpha = music_txt.alpha = 1;
	}

	var billie_offset:Int = 8;

	public function beatHit()
	{
		billie.y = FlxG.height - billie.height + billie_offset;
		FlxTween.tween(billie, {y: billie.y - billie_offset}, 0.5, {ease: FlxEase.quartOut});

		object_name.borderSize = 3;
		FlxTween.tween(object_name, {borderSize: 2}, (Conductor.crotchet / 1000) * 0.8, {ease: FlxEase.quadOut});

		outlineBorderSize = 11;
		FlxTween.tween(this, {outlineBorderSize: 8}, (Conductor.crotchet / 1000) * 0.8, {ease: FlxEase.quadOut});
	}

	var item_offset:Int = 400;

	public var items_on_screen:Bool;

	public function moveItems(move_in:Bool = false, ?time:Float = 2.5)
	{
		if (move_in)
		{
			trace('IN');
			items_on_screen = true;
			new FlxTimer().start(time + 1, function(tmr:FlxTimer) {
				scrolling_text = true;
			});
			for (item in tween_objects)
			{
				item.visible = true;
				FlxTween.cancelTweensOf(item);
				var pos_array:Array<Dynamic> = [];
				for (temp_pos_array in object_positions)
					if (temp_pos_array[0] == item)
					{
						pos_array = temp_pos_array;
						break;
					}

				FlxTween.tween(item, {x: pos_array[1]}, time, {ease: FlxEase.quartOut});
			}

			trace('OverworldUI is is true ' + pushedNew);
			if (pushedNew)
			{
				if (!muteBuzz) FlxG.sound.play(Paths.sound('201-street/buzz'), 0.7);
				pushedNew = false;
			}
		}
		else
		{
			trace('FAR OUT');
			phone.y = 720;
			notif.y = phone.y;
			items_on_screen = false;

			for (item in tween_objects)
			{
				FlxTween.cancelTweensOf(item);
				var pos_array:Array<Dynamic> = [];
				for (temp_pos_array in object_positions)
					if (temp_pos_array[0] == item)
					{
						pos_array = temp_pos_array;
						break;
					}
				item.x = pos_array[2];
			}
		}
	}

	public function changeLocationName(locname:String)
	{
		location_name.text = locname.toUpperCase();
		location_name.size = 32;
		location_name.updateHitbox();
		while (location_name.width > 200)
			location_name.size -= 1;
		location_name.y = location_box.y + location_box.height / 2 - location_name.height / 2 - 10;
	}
}
