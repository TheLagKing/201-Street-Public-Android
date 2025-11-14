package funkin.states.options;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxObject;
import funkin.data.*;
import funkin.states.*;
import funkin.objects.*;
import funkin.backend.Difficulty;
import funkin.backend.MusicBeatSubstate;

/*
	I turned myself into a substate morty! i'M OPTIONS SUB STATE!!!!!!

	Used for the phone and the phone only.
 */
class OptionsSubstate extends MusicBeatSubstate
{
	final FONT:String = Paths.font("ATTFShinGoProBold.ttf");
	var fontSize:Int = 40;

	public var canInput = false;

	var backButton:FlxSprite;

	public static var onPlayState:Bool = false;

	var options:Array<String> = [
		'Controls',
		'Adjust Delay',
		'Difficulty',
		'Graphics and Visuals',
		'Gameplay',
		"Close"
	];
	private var grpOptions:FlxTypedGroup<FlxText>;

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	var mouseObject:FlxObject;

	public function openSelectedSubstate(label:String)
	{
		if (label != 'Difficulty')
		{
			backButton.alpha = 0;
			for (item in grpOptions.members)
			{
				item.alpha = 0;
			}
		}
		switch (label)
		{
			case 'Difficulty':
				// Why do we use this system
				FlxG.save.data.story_difficulty = FlxG.save.data.story_difficulty == 1 ? 0 : 1;
				FlxG.save.flush();
				for (item in grpOptions.members)
				{
					if (item.ID == 2) item.text = 'Difficulty: ${Difficulty.defaultDifficulties[FlxG.save.data.story_difficulty]}';
					item.screenCenter(X);
				}
			case 'Controls':
				openSubState(new funkin.states.options.ControlsSubState());
			case 'Graphics and Visuals':
				openSubState(new funkin.states.options.GraphicsSettingsSubState());
			case 'Gameplay':
				openSubState(new funkin.states.options.GameplaySettingsSubState());
			case 'Misc':
				openSubState(new funkin.states.options.MiscSubState());
			case 'Adjust Delay':
				FlxG.switchState(funkin.states.options.NoteOffsetState.new);
				NoteOffsetState.onPhone = true;
			case 'Close':
				FlxG.sound.play(Paths.sound('cancelMenu'));
				close();
		}
	}

	function onBack()
	{
		canInput = true;
	}

	public function new()
	{
		super();
		FlxTimer.wait(0.2, onBack);
		DiscordClient.changePresence("Options Menu");

		mouseObject = new FlxObject(0, 0, 5, 5);
		add(mouseObject);

		var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		bg.alpha = 0.7;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:FlxText = new FlxText(0, 0, -1, options[i]);
			optionText.setFormat(FONT, fontSize, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if (i == 2) optionText.text = 'Difficulty: ${Difficulty.defaultDifficulties[FlxG.save.data.story_difficulty]}';
			optionText.screenCenter();
			optionText.ID = i;
			optionText.y += (80 * (i - (options.length / 2))) + 50;
			optionText.borderSize = 2;
			grpOptions.add(optionText);
		}

		backButton = new FlxSprite(10, 10).loadGraphic(Paths.image("overworld/ui/phoneui/backminimenu"));
		add(backButton);

		changeSelection();
		ClientPrefs.flush();
		camera = CameraUtil.lastCamera;
	}

	override function closeSubState()
	{
		backButton.alpha = 1;
		for (item in grpOptions.members)
		{
			item.alpha = (curSelected == item.ID ? 1 : 0.4);
		}
		trace('plap plap plap!');
		super.closeSubState();
		ClientPrefs.flush();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!canInput) return;

		mouseObject.setPosition(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);

		var isOverlapped:Bool = false;

		if (FlxG.mouse.overlaps(backButton, OverworldState.instance.camHUD))
		{
			isOverlapped = true;
			if (FlxG.mouse.justPressed)
			{
				close();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
		}

		for (item in grpOptions.members)
		{
			if (FlxG.mouse.overlaps(item, OverworldState.instance.camHUD))
			{
				isOverlapped = true;
				if (FlxG.mouse.justPressed)
				{
					openSelectedSubstate(options[item.ID]);
					return;
				}
			}
		}
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			close();
		}

		if (controls.ACCEPT)
		{
			openSelectedSubstate(options[curSelected]);
		}

		FlxG.mouse.load(Paths.image('overworld/ui/cursor/${isOverlapped ? 'click' : 'cursor'}').bitmap, 0.325);
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0) curSelected = options.length - 1;
		if (curSelected >= options.length) curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.alpha = (curSelected == item.ID ? 1 : 0.4);
		}
		if (change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
