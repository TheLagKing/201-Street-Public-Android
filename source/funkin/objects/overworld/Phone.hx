package funkin.objects.overworld;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
import funkin.states.substates.*;
import funkin.states.options.*;
import funkin.data.*;
import funkin.game.shaders.Outline;
import funkin.backend.PlayerSettings;
import funkin.objects.overworld.ChecklistEntry;

using StringTools;

class Phone extends FlxTypedSpriteGroup<FlxSprite>
{
	public static var phone_open:Bool;

	var selected_shader:Outline;

	var phone:FlxSprite;
	var phone_screen:FlxSprite;
	var phone_box:FlxSprite;
	var gallery:FlxSprite;
	var checklist:FlxSprite;
	var settings:FlxSprite;
	var contacts:FlxSprite;
	var wordle:FlxSprite;
	var exit:FlxSprite;
	var notifS:FlxSprite;
	var notifCo:FlxSprite;
	var notifCh:FlxSprite;
	var backButton:FlxSprite;

	var notifArray:Array<String> = FlxG.save.data.notifTypes;
	var notifsArray:Array<FlxSprite> = [];

	var baseX:Int = 539;
	var baseY:Int = 166;

	var curSelected:Int = 0;

	var options:Array<String> = ['photos', 'checklist', 'settings', 'contacts', 'wordle', 'return to menu'];
	var apps_array:Array<FlxSprite>;
	var app_text:FlxText;

	public static var curFreeplay:Int = 0;

	var freeplay:Array<FlxSprite>;
	var freeplay_song_name:FlxText;
	var freeplay_song_score:FlxText;
	var freeplay_portrait:FlxSprite;
	var freeplay_left_arrow:FlxSprite;
	var freeplay_right_arrow:FlxSprite;
	var freeplay_songs:Array<Array<Dynamic>> = [
		["Fallen Skies", FlxG.save.data.songsBeaten.contains('dandadan')],
		["Starbound", FlxG.save.data.songsBeaten.contains('dandadan')],
		["Hello, Randy!", FlxG.save.data.songsBeaten.contains('ghostface')],
		["Mauve Macabre", FlxG.save.data.songsBeaten.contains('pokemon')],
		["Headlights", FlxG.save.data.songsBeaten.contains('herobrine')],
		["Music For Your Ears!", FlxG.save.data.songsBeaten.contains('dhmis')],
		["Pink Sea", FlxG.save.data.songsBeaten.contains('pink-sea')],
		["Black Sea", FlxG.save.data.songsBeaten.contains('black-sea')],
		["Fool's Errand", FlxG.save.data.songsBeaten.contains('repo')],
		["Face Of Fury", FlxG.save.data.songsBeaten.contains('scp')],
		["Citrus Sacrament", FlxG.save.data.songsBeaten.contains('monster')],
		["The Crest Of Entropy", FlxG.save.data.songsBeaten.contains('bill-cipher')]
	];

	var checklistEntries:Array<ChecklistEntry> = [];
	var checklist_title:FlxSprite;
	var takeback:FlxSprite;
	var checklist_data:Array<Array<Dynamic>>;

	var curContact:Int = 0;
	var contacts_title:FlxSprite;
	var contacts_list:Array<FlxText> = [];
	var contacts_check:FlxSprite;
	var contacts_data:Array<Array<Dynamic>> = [
		["Letícia", "letícia_contact", true],
		[
			"D. E. Halloway",
			"halloway_contact",
			FlxG.save.data.overworldData.contains('FirstPurchase')
		],
		["Randy", "randy_contact", FlxG.save.data.songsBeaten.contains('ghostface')],
		["Okarun", "okarun_contact", FlxG.save.data.songsBeaten.contains('dandadan')],
		["SCP Soldier", "scp_contact", FlxG.save.data.songsBeaten.contains('scp')],
		[
			"Unknown Number #1",
			"monster_contact",
			FlxG.save.data.songsBeaten.contains('monster') && FlxG.save.data.overworldData.contains('DeletedMonster') != true],
		[
			"Unknown Number #2",
			"bill_contact",
			FlxG.save.data.songsBeaten.contains('bill-cipher') && FlxG.save.data.overworldData.contains('DeletedBill') != true
		]
	];
	private var controls(get, never):Controls;

	inline function get_controls():Controls return PlayerSettings.player1.controls;

	var contacts_info:Array<Array<String>> = [];

	public var canSelectOnPhone:Bool;
	public var inApp:Bool = false;
	public var exitingPhone:Bool = false;
	public var curApp:String = '';

	var phone_mouse_object:FlxSprite;

	// var doyouwanttoexitphone:FlxSprite;
	// var yes_exit_phone:FlxSprite;
	// var no_exit_phone:FlxSprite;
	var curExit:Int = -1;

	public function new()
	{
		super();

		canSelectOnPhone = false;
		phone_open = false;

		apps_array = [];
		y += 50;

		selected_shader = new Outline(0xFFFFFFFF, 3, 3);

		phone = new FlxSprite().loadGraphic(Paths.image('overworld/ui/phoneui/phone'));
		// phone.y += phone.height;
		phone.ID = -1;
		add(phone);

		phone_screen = new FlxSprite(baseX - 5, baseY - 127).loadGraphic(Paths.image('overworld/ui/phoneui/phone_screen'));
		// phone.y += phone.height;
		phone_screen.ID = -1;
		add(phone_screen);

		gallery = new FlxSprite(baseX, baseY).loadGraphic(Paths.image('overworld/ui/phoneui/gallery'));
		gallery.ID = 0;
		add(gallery);

		checklist = new FlxSprite(baseX + 65, baseY - 5).loadGraphic(Paths.image('overworld/ui/phoneui/checklist'));
		checklist.ID = 1;
		add(checklist);

		settings = new FlxSprite(baseX + 65 + 65, baseY).loadGraphic(Paths.image('overworld/ui/phoneui/settings'));
		settings.ID = 2;
		add(settings);

		contacts = new FlxSprite(baseX, baseY + 60).loadGraphic(Paths.image('overworld/ui/phoneui/contacts'));
		contacts.ID = 3;
		add(contacts);

		wordle = new FlxSprite(baseX + 65, baseY + 60 - 5).loadGraphic(Paths.image('overworld/ui/phoneui/wordle'));
		wordle.ID = 4;
		add(wordle);

		exit = new FlxSprite(baseX + 65 + 65, baseY + 60).loadGraphic(Paths.image('overworld/ui/phoneui/exit'));
		exit.ID = 5;
		add(exit);

		// IM SORRY FOR BEING STRAIGHT IM SORRY FOR BEING STRAIGHT IM SORRY FOR BEING STRAIGHT IM SORRY FOR BEING STRAIGHT

		notifS = new FlxSprite(baseX + 65 + 65, baseY + 60).loadGraphic(Paths.image('overworld/ui/notification'));
		notifS.scale.set(0.5, 0.5);
		notifS.x = gallery.x;
		notifS.y = gallery.y - 50;
		notifS.zIndex = 2;
		notifS.visible = false;
		add(notifS);

		notifCh = new FlxSprite(baseX + 65 + 65, baseY + 60).loadGraphic(Paths.image('overworld/ui/notification'));
		notifCh.scale.set(0.5, 0.5);
		notifCh.x = checklist.x;
		notifCh.y = checklist.y - 50;
		notifCh.zIndex = 2;
		notifCh.visible = false;
		add(notifCh);

		notifCo = new FlxSprite(baseX + 65 + 65, baseY + 60).loadGraphic(Paths.image('overworld/ui/notification'));
		notifCo.scale.set(0.5, 0.5);
		notifCo.x = contacts.x;
		notifCo.y = contacts.y - 50;
		notifCo.zIndex = 2;
		notifCo.visible = false;
		add(notifCo);

		// I could just make an array and have them all be the same FlxSprite but im so lazy rn maybe later

		apps_array = [gallery, checklist, settings, contacts, wordle, exit];

		app_text = new FlxText(0, phone_screen.y + 10, 0, '', 20);
		app_text.color = 0xffFFFFFF;
		app_text.font = Paths.font('Happy School.ttf');
		app_text.borderStyle = FlxTextBorderStyle.OUTLINE;
		app_text.borderColor = 0xFF000000;
		app_text.borderSize = 1.4;
		app_text.antialiasing = true;
		add(app_text);

		phone_box = new FlxSprite(32, -120);
		phone_box.frames = Paths.getSparrowAtlas('overworld/ui/phoneui/phone_box');
		phone_box.animation.addByPrefix('open', 'phone_box open', 24, false);
		phone_box.animation.play('open');
		phone_box.visible = false;

		phone_box.ID = -1;
		phone_box.scale.set(0.78, 0.78);
		add(phone_box);

		for (item in group.members)
		{
			item.antialiasing = false;
		}

		// GALLERY STUFF =================
		freeplay_portrait = new FlxSprite(phone_box.x + 226, phone_box.y + 140);
		for (i in 0...freeplay_songs.length)
		{
			trace('albums/' + Paths.formatToSongPath(freeplay_songs[i][0]));
			freeplay_portrait.loadGraphic(Paths.image('albums/' + Paths.formatToSongPath(freeplay_songs[i][0])));
		}
		freeplay_portrait.visible = false;
		freeplay_portrait.antialiasing = true;
		freeplay_portrait.setGraphicSize(Std.int(freeplay_portrait.width * 0.265));
		freeplay_portrait.updateHitbox();
		add(freeplay_portrait);

		freeplay_song_name = new FlxText(0, freeplay_portrait.y - 110, 0, '', 26);
		freeplay_song_name.color = 0xff000000;
		freeplay_song_name.font = Paths.font('futara-maxi.otf');
		freeplay_song_name.visible = false;
		freeplay_song_name.antialiasing = true;
		add(freeplay_song_name);

		freeplay_song_score = new FlxText(0, freeplay_song_name.y - 20, 0, '', 18);
		freeplay_song_score.color = 0xff505853;
		freeplay_song_score.font = Paths.font('futara-maxi.otf');
		freeplay_song_score.visible = false;
		freeplay_song_score.antialiasing = true;
		add(freeplay_song_score);

		freeplay_left_arrow = new FlxSprite(freeplay_portrait.x - 40, freeplay_portrait.y - 40).loadGraphic(Paths.image('overworld/ui/phoneui/arrow'));
		freeplay_left_arrow.visible = false;
		freeplay_left_arrow.antialiasing = true;
		freeplay_left_arrow.scale.set(0.3, 0.8);
		freeplay_left_arrow.updateHitbox();
		add(freeplay_left_arrow);

		freeplay_right_arrow = new FlxSprite(freeplay_portrait.x + 200, freeplay_portrait.y - 40).loadGraphic(Paths.image('overworld/ui/phoneui/arrow'));
		freeplay_right_arrow.visible = false;
		freeplay_right_arrow.antialiasing = true;
		freeplay_right_arrow.flipX = true;
		freeplay_right_arrow.scale.set(0.3, 0.8);
		freeplay_right_arrow.updateHitbox();
		add(freeplay_right_arrow);

		freeplay = [
			freeplay_portrait,
			freeplay_song_name,
			freeplay_song_score,
			freeplay_left_arrow,
			freeplay_right_arrow
		];

		// CHECKLIST STUFF ===============
		checklist_title = new FlxSprite(phone_box.x + 195, phone_box.y + 75).loadGraphic(Paths.image('overworld/ui/phoneui/checklist_name'));
		checklist_title.visible = false;
		checklist_title.antialiasing = true;
		checklist_title.setGraphicSize(Std.int(checklist_title.width * 0.25));
		checklist_title.updateHitbox();
		add(checklist_title);

		refreshChecklistData();

		for (i in 0...checklist_data.length)
		{
			var thisEntry:ChecklistEntry = new ChecklistEntry((phone_box.x + 115), phone_box.y + 107 + (i * 23), checklist_data[i][0], checklist_data[i][1],
				checklist_data[i][2], checklist_data[i][3]);
			thisEntry.visible = false;
			add(thisEntry);
			checklistEntries.push(thisEntry);
		}

		takeback = new FlxSprite(phone_box.x + 183, phone_box.y + 105).loadGraphic(Paths.image('overworld/ui/phoneui/takeback'));
		takeback.visible = false;
		takeback.antialiasing = true;
		takeback.updateHitbox();
		add(takeback);

		// CONTACTS STUFF =================
		// contacts_list = new FlxText(phone_box.x + 215, phone_box.y + 110, 500, '', 18);
		// contacts_list.color = 0xff000000;
		// contacts_list.font = Paths.font('futara-maxi.otf');
		// contacts_list.visible = false;
		// contacts_list.antialiasing = true;
		// add(contacts_list);

		contacts_title = new FlxSprite(checklist_title.x - 2, checklist_title.y - 55).loadGraphic(Paths.image('overworld/ui/phoneui/whotocall'));
		contacts_title.visible = false;
		contacts_title.antialiasing = true;
		contacts_title.setGraphicSize(Std.int(contacts_title.width * 0.18));
		contacts_title.updateHitbox();
		add(contacts_title);

		contacts_check = new FlxSprite(phone_box.x + 195, phone_box.y + 110).loadGraphic(Paths.image('overworld/ui/phoneui/arrow'));
		contacts_check.visible = false;
		contacts_check.antialiasing = true;
		contacts_check.flipX = true;
		contacts_check.scale.set(0.1, 0.079);
		contacts_check.updateHitbox();
		add(contacts_check);

		backButton = new FlxSprite(780, 10).loadGraphic(Paths.image("overworld/ui/phoneui/backminimenu"));
		// backButton.scale.set(0.15, 0.15);
		backButton.antialiasing = ClientPrefs.globalAntialiasing;
		backButton.updateHitbox();
		backButton.visible = false;
		add(backButton);

		phone_mouse_object = new FlxSprite().makeGraphic(5, 5, FlxColor.RED);
		phone_mouse_object.visible = false;
		add(phone_mouse_object);
	}

	var freeplay_text_offset:Int = 92;

	function changeSel(by:Int, ?set:Bool = false)
	{
		if (set) curSelected = by;
		else curSelected += by;

		if (curSelected > 5) curSelected -= 6;
		if (0 > curSelected) curSelected += 6;

		for (item in group.members)
		{
			if (item.ID == curSelected) item.shader = selected_shader;
			else item.shader = null;
		}
	}

	function refreshChecklistData():Void
	{
		checklist_data = [
			["Run From The Curse", "lake", 'dandadan', true],
			["Travel The Stars", "lake", 'dandadan', true],
			["Your Favourite Movie?", "randy", 'ghostface', true],
			[
				"Summon The Spirit",
				"house",
				'pokemon',
				FlxG.save.data.overworldData.contains("BoughtGameboy")
			],
			[
				"Disturb The Myth",
				"house",
				'herobrine',
				FlxG.save.data.overworldData.contains("BoughtPendrive")
			],
			[
				"Learn Your Lesson",
				"house",
				'dhmis',
				FlxG.save.data.overworldData.contains("BoughtTape")
			],
			["Remember The Dream", "dream", 'pink-sea', FlxG.save.data.songsBeaten.length > 2],
			[
				"Forget The Nightmare",
				"dream",
				'black-sea',
				FlxG.save.data.songsBeaten.length > 2
			],
			[
				"Pay Your Debts",
				"house",
				'repo',
				FlxG.save.data.overworldData.contains("BoughtTablet")
			],
			[
				"Avert Your Gaze",
				"forest",
				'scp',
				FlxG.save.data.overworldData.contains('BoughtHeadset')
			],
			[
				"Challenge The Crooner",
				"forest",
				'monster',
				FlxG.save.data.overworldData.contains('BoughtHeadset')
			]
		];
	}

	var hoveringOnApp:Bool;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.save.data.notifTypes.contains('song')
			&& notifArray == []
			|| FlxG.save.data.notifTypes.contains('checklist')
			&& notifArray == []
			|| FlxG.save.data.notifTypes.contains('contact')
			&& notifArray == []) notifArray = FlxG.save.data.notifTypes; // I need to rip my head off i hate haxeflixel i hate jeffrey epstein
		{
			notifArray = FlxG.save.data.notifTypes;
		}

		if (FlxG.save.data.notifTypes.contains('song') != true) notifS.visible = false;
		if (FlxG.save.data.notifTypes.contains('checklist') != true) notifCh.visible = false;
		if (FlxG.save.data.notifTypes.contains('contact') != true) notifCo.visible = false;

		phone_mouse_object.setPosition(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);

		backButton.visible = phone_open;

		if (!phone_open) return;

		// yummay
		backButton.alpha = canSelectOnPhone ? 1 : 0.5;
		if (FlxG.mouse.overlaps(backButton, OverworldState.instance.camHUD) && canSelectOnPhone)
		{
			backButton.shader = selected_shader;
			if (FlxG.mouse.justPressed)
			{
				inApp ? closeApp() : closePhone();
				return;
			}
		}
		else
		{
			backButton.shader = null;
		}

		if (!inApp && (controls.BACK || FlxG.mouse.justPressedRight))
		{
			inApp = true;
			exitingPhone = true;
			canSelectOnPhone = false;
			curExit = 0;

			closePhone();
		}

		if (!inApp)
		{
			if (controls.UI_RIGHT_P) changeSel(1);
			if (controls.UI_DOWN_P) changeSel(3);
			if (controls.UI_LEFT_P) changeSel(-1);
			if (controls.UI_UP_P) changeSel(-3);

			hoveringOnApp = false;
			for (app in apps_array)
			{
				if (FlxG.mouse.overlaps(app, OverworldState.instance.camHUD))
				{
					hoveringOnApp = true;
					if (curSelected != app.ID) changeSel(app.ID, true);
				}
			}

			app_text.text = options[curSelected].toUpperCase();
			app_text.x = phone_screen.x + (phone_screen.width / 2) - (app_text.width / 2);

			if (controls.ACCEPT || FlxG.mouse.justPressed && hoveringOnApp)
			{
				curApp = options[curSelected];
				switch (curApp)
				{
					case 'photos':
						openApp();

						freeplay_songs = [
							["Fallen Skies", FlxG.save.data.songsBeaten.contains('dandadan')],
							["Starbound", FlxG.save.data.songsBeaten.contains('dandadan')],
							["Hello, Randy!", FlxG.save.data.songsBeaten.contains('ghostface')],
							["Mauve Macabre", FlxG.save.data.songsBeaten.contains('pokemon')],
							["Headlights", FlxG.save.data.songsBeaten.contains('herobrine')],
							["Music For Your Ears!", FlxG.save.data.songsBeaten.contains('dhmis')],
							["Pink Sea", FlxG.save.data.songsBeaten.contains('pink-sea')],
							["Black Sea", FlxG.save.data.songsBeaten.contains('black-sea')],
							["Fool's Errand", FlxG.save.data.songsBeaten.contains('repo')],
							["Face Of Fury", FlxG.save.data.songsBeaten.contains('scp')],
							["Citrus Sacrament", FlxG.save.data.songsBeaten.contains('monster')],
							["The Crest Of Entropy", FlxG.save.data.songsBeaten.contains('bill-cipher')]
						];

						new FlxTimer().start(0.23, function(tmr:FlxTimer) {
							for (item in freeplay)
								item.visible = true;

							changeFreeplay();
						});

						if (FlxG.save.data.notifTypes.contains('song'))
						{
							notifS.visible = false;
							notifsArray.remove(notifS);
							FlxG.save.data.notifTypes.remove('song');
							FlxG.save.flush();
						}

					case 'checklist':
						openApp();

						refreshChecklistData();

						if (FlxG.save.data.songsBeaten.contains("bill-cipher"))
						{
							takeback.loadGraphic(Paths.image('overworld/ui/phoneui/takebackdone'));
						}
						else
						{
							takeback.loadGraphic(Paths.image('overworld/ui/phoneui/takeback'));
						}

						new FlxTimer().start(0.23, function(tmr:FlxTimer) {
							checklist_title.visible = true;

							var bill_check:Bool = true;

							for (i in 0...checklistEntries.length)
							{
								checklistEntries[i].visible = true;
								checklistEntries[i].refresh(checklist_data[i][3]);
								if (!checklistEntries[i].getChecked()) bill_check = false;
							}

							takeback.visible = bill_check;
						});

						if (FlxG.save.data.notifTypes.contains('checklist'))
						{
							notifCh.visible = false;
							notifsArray.remove(notifCh);
							FlxG.save.data.notifTypes.remove('checklist');
							FlxG.save.flush();
						}

					case 'settings':
						OverworldState.instance.openSub(new OptionsSubstate());

					case 'contacts':
						openApp();
						contacts_data = [
							["Letícia", "letícia_contact", true],
							[
								"D. E. Halloway",
								"halloway_contact",
								FlxG.save.data.overworldData.contains('FirstPurchase')
							],
							["Randy", "randy_contact", FlxG.save.data.songsBeaten.contains('ghostface')],
							["Okarun", "okarun_contact", FlxG.save.data.songsBeaten.contains('dandadan')],
							["Sam's Coffee Place", "scp_contact", FlxG.save.data.songsBeaten.contains('scp')],
							[
								"Unknown Number #1",
								"monster_contact",
								FlxG.save.data.songsBeaten.contains('monster') && FlxG.save.data.overworldData.contains('DeletedMonster') != true],
							[
								"Unknown Number #2",
								"bill_contact",
								FlxG.save.data.songsBeaten.contains('bill-cipher') && FlxG.save.data.overworldData.contains('DeletedBill') != true
							]
						];

						contacts_info = [];
						contacts_list = [];
						new FlxTimer().start(0.23, function(tmr:FlxTimer) {
							var unlockedContacts:Int = 0;
							for (i in 0...contacts_data.length)
							{
								if (contacts_data[i][2])
								{
									contacts_info.push([contacts_data[i][0], contacts_data[i][1]]);

									var newText:FlxText = new FlxText(phone_box.x + 215, phone_box.y + 110 + (unlockedContacts * 25), 500,
										contacts_data[i][0], 18);
									newText.color = 0xff000000;
									newText.font = Paths.font('futara-maxi.otf');
									newText.antialiasing = ClientPrefs.globalAntialiasing;
									contacts_list.push(newText);
									add(newText);

									unlockedContacts++;
								}
							}
							contacts_title.visible = true;
							contacts_check.visible = true;

							contacts_check.y = contacts_list[0].y + ((curContact * 2) * contacts_list[0].size);
						});

						if (FlxG.save.data.notifTypes.contains('contact'))
						{
							notifCo.visible = false;
							notifsArray.remove(notifCo);
							FlxG.save.data.notifTypes.remove('contact');
							FlxG.save.flush();
						}
					case 'wordle':
						OverworldState.instance.openSub(new WordleSubstate());
					case 'return to menu':
						OverworldState.instance.openSub(new ExitToMenuSubstate());
				}
			}
		}
		else // If you are in app vvv
		{
			if (canSelectOnPhone)
			{
				switch (curApp)
				{
					case 'photos':
						if (controls.UI_LEFT_P
							|| FlxG.mouse.overlaps(freeplay_left_arrow, OverworldState.instance.camHUD)
							&& FlxG.mouse.justPressed)
						{
							curFreeplay--;
							FlxTween.cancelTweensOf(freeplay_left_arrow);
							freeplay_left_arrow.scale.set(0.25, 0.75);
							FlxTween.tween(freeplay_left_arrow.scale, {x: 0.3, y: 0.8}, 0.1, {ease: FlxEase.quadInOut});
						}
						if (controls.UI_RIGHT_P
							|| FlxG.mouse.overlaps(freeplay_right_arrow, OverworldState.instance.camHUD)
							&& FlxG.mouse.justPressed)
						{
							curFreeplay++;
							FlxTween.cancelTweensOf(freeplay_right_arrow);
							freeplay_right_arrow.scale.set(0.25, 0.75);
							FlxTween.tween(freeplay_right_arrow.scale, {x: 0.3, y: 0.8}, 0.1, {ease: FlxEase.quadInOut});
						}
						if (curFreeplay > freeplay_songs.length - 1) curFreeplay = 0;
						if (0 > curFreeplay) curFreeplay = freeplay_songs.length - 1;

						if ((controls.ACCEPT
							|| FlxG.mouse.overlaps(freeplay_portrait, OverworldState.instance.camHUD)
							&& FlxG.mouse.justPressed)
							&& freeplay_songs[curFreeplay][1] == true)
						{
							canSelectOnPhone = false;
							FlxTween.tween(OverworldUI.black_bg, {alpha: 1}, 0.75, {ease: FlxEase.quartOut});
							FlxTween.tween(this, {y: FlxG.height + 50}, 0.75,
								{
									ease: FlxEase.quartOut,
									onComplete: function(t:FlxTween) {
										OverworldState.instance.loadSong([freeplay_songs[curFreeplay][0].toLowerCase()], false);
									}
								});
							FlxTween.tween(FlxG.sound.music, {volume: 0, pitch: 0}, 0.75);
						}

						if (controls.UI_RIGHT_P
							|| controls.UI_LEFT_P
							|| (FlxG.mouse.overlaps(freeplay_right_arrow, OverworldState.instance.camHUD)
								|| FlxG.mouse.overlaps(freeplay_left_arrow, OverworldState.instance.camHUD))
							&& FlxG.mouse.justPressed)
						{
							changeFreeplay();
						}
					case 'contacts':
						if (controls.UI_UP_P) curContact--;
						if (controls.UI_DOWN_P) curContact++;
						if (curContact > contacts_info.length - 1) curContact = 0;
						if (0 > curContact) curContact = contacts_info.length - 1;

						// if (FlxG.mouse.getScreenPosition().x > contacts_list.x
						//	&& contacts_list.x + contacts_list.width > phone_mouse_object.x
						//	&& FlxG.mouse.getScreenPosition().y > contacts_list.y)
						// {
						//	mouseposselection = Std.int((FlxG.mouse.getScreenPosition().y - contacts_list.y + 9) / (contacts_list.size * 2));
						//	if (mouseposselection > contacts_info.length - 1) mouseposselection = contacts_info.length - 1;
						//	if (0 > mouseposselection) mouseposselection = 0;
						//	curContact = mouseposselection;
						// }

						for (i in 0...contacts_list.length)
						{
							if (FlxG.mouse.overlaps(contacts_list[i], OverworldState.instance.camHUD))
							{
								curContact = i;
							}
						}

						contacts_check.y = contacts_list[curContact].y;
						if (controls.ACCEPT || FlxG.mouse.justPressed)
						{
							closeApp();
							closePhone(false);
							trace('LOADING DIALOGUE WHYYYY???');
							phone_open = false;
							OverworldState.instance.loadDialogue(contacts_info[curContact][1], true);
						}
				}
				if (controls.BACK || FlxG.mouse.justPressedRight)
				{
					closeApp();
				}
			}

			if (exitingPhone)
			{
				if (controls.UI_RIGHT_P || controls.UI_LEFT_P) curExit = curExit == 0 ? 1 : 0;

				var mouse_overlapping:Bool = false;

				if (controls.ACCEPT || (FlxG.mouse.justPressed && mouse_overlapping))
				{
					switch (curExit)
					{
						case 0:
							OverworldState.instance.camHUD.fade(FlxColor.BLACK, 0.4, false, function() {
								FlxG.switchState(() -> {
									new TitleState201();
								});
							});
						case 1:
							inApp = false;
							exitingPhone = false;
							canSelectOnPhone = true;
					}
				}
				else if (controls.BACK || FlxG.mouse.justPressedRight)
				{
					inApp = false;
					exitingPhone = false;
					canSelectOnPhone = true;
				}
			}
		}
	}

	public function openPhone()
	{
		app_text.text = '';
		FlxG.sound.play(Paths.sound('201-street/phone_open'));
		canSelectOnPhone = false;
		changeSel(0);
		FlxTween.tween(this, {y: 50}, 0.75,
			{
				ease: FlxEase.quartOut,
				onComplete: function(t:FlxTween) {
					phone_open = true;
					canSelectOnPhone = true;
				}
			});

		if (OverworldState.instance == null) return;
		OverworldState.instance.callScriptFunc('onOpenPhone', []);

		if (notifArray != [])
		{
			for (i in notifArray)
			{
				if (i == 'song')
				{
					notifS.visible = true;
				}
				else if (i == 'checklist')
				{
					notifCh.visible = true;
				}
				else if (i == 'contact')
				{
					notifCo.visible = true;
				}
			}
		}
		for (i in [notifS, notifCh, notifCo])
		{
			if (i.visible = true) notifsArray.push(i);
		}
	}

	public function closePhone(?allow_can_move:Bool = true)
	{
		if (allow_can_move) FlxG.sound.play(Paths.sound('201-street/phone_close'));
		canSelectOnPhone = false;
		phone_open = !allow_can_move;

		FlxTween.cancelTweensOf(OverworldUI.black_bg);
		for (item in group.members)
		{
			FlxTween.cancelTweensOf(item);
		}
		FlxTween.tween(OverworldUI.black_bg, {alpha: 0}, 0.5, {ease: FlxEase.quartOut});
		FlxTween.tween(this, {y: FlxG.height + 50}, 0.5, {ease: FlxEase.quartOut});
		OverworldState.instance.canMove = allow_can_move;

		if (OverworldState.instance == null) return;
		OverworldState.instance.callScriptFunc('onClosePhone', []);

		notifsArray = [];
	}

	function openApp()
	{
		FlxG.sound.play(Paths.sound('201-street/phone_button_press'));
		canSelectOnPhone = false;

		new FlxTimer().start(0.23, function(tmr:FlxTimer) {
			canSelectOnPhone = true;
		});
		inApp = true;
		phone_screen.loadGraphic(Paths.image('overworld/ui/phoneui/phone_screen_white'));
		phone_box.animation.play('open', true);
		phone_box.visible = true;
		app_text.visible = false;
		for (app in apps_array)
			app.visible = false;
		for (i in notifsArray)
			i.visible = false;
	}

	function closeApp()
	{
		inApp = false;
		contacts_title.visible = false;
		for (txt in contacts_list)
		{
			txt.kill();
			txt.destroy();
		}
		contacts_list = [];
		contacts_check.visible = false;
		for (item in freeplay)
			item.visible = false;

		for (entry in checklistEntries)
		{
			entry.visible = false;
		}
		checklist_title.visible = false;
		takeback.visible = false;

		canSelectOnPhone = true;
		phone_screen.loadGraphic(Paths.image('overworld/ui/phoneui/phone_screen'));
		phone_box.visible = false;
		app_text.visible = true;
		for (app in apps_array)
			app.visible = true;

		for (i in notifsArray)
			i.visible = true;
	}

	function changeFreeplay()
	{
		// HELLO BRO
		if (freeplay_songs[curFreeplay][1] == true) freeplay_portrait.loadGraphic(Paths.image('albums/'
			+ Paths.formatToSongPath(freeplay_songs[curFreeplay][0])));
		else freeplay_portrait.loadGraphic(Paths.image('albums/locked'));
		freeplay_portrait.updateHitbox();

		freeplay_song_name.y = freeplay_portrait.y - 60;
		freeplay_song_name.size = 26;
		freeplay_song_name.text = Std.int(curFreeplay + 1)
			+ '. '
			+ (freeplay_songs[curFreeplay][1] == true ? freeplay_songs[curFreeplay][0].toUpperCase() : '???');
		if (freeplay_song_name.width > 280)
		{
			while (freeplay_song_name.width > 280)
			{
				freeplay_song_name.size -= 1;
				freeplay_song_name.y += 0.5;
			}
		}
		freeplay_song_name.updateHitbox();
		freeplay_song_name.x = freeplay_portrait.x + freeplay_text_offset - (freeplay_song_name.width / 2);
		freeplay_song_score.text = FlxStringUtil.formatMoney(Highscore.getScore(freeplay_songs[curFreeplay][0].toUpperCase(),
			FlxG.save.data.story_difficulty), false);
		freeplay_song_score.visible = freeplay_songs[curFreeplay][1] == true;
		freeplay_song_score.x = freeplay_portrait.x + freeplay_text_offset - (freeplay_song_score.width / 2);
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
