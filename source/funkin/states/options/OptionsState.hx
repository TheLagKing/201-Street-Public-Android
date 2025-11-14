package funkin.states.options;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import funkin.data.*;
import funkin.states.*;
import funkin.objects.*;
import flash.display.BlendMode;
import funkin.backend.FunkinShader.FunkinRuntimeShader;

class OptionsState extends MusicBeatState
{
	final FONT:String = Paths.font("ATTFShinGoProBold.ttf");
	var fontSize:Int = 40;

	public static var onPlayState:Bool = false;
	public static var onPhone:Bool = false;

	var options:Array<String> = ['Controls', 'Adjust Delay', 'Graphics and Visuals', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<FlxText>;

	var sky:FlxSprite;
	var clouds:FlxSprite;
	var cloudShaderObj:FlxSprite;
	var cloudShader:FunkinRuntimeShader;
	var mouseObject:FlxObject;

	var backButton:FlxSprite;

	private static var curSelected:Int = 0;

	public function openSelectedSubstate(label:String)
	{
		for (item in grpOptions.members)
		{
			item.alpha = 0;
		}
        backButton.alpha = 0;
		switch (label)
		{
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
				NoteOffsetState.onPhone = onPhone;
		}
	}

	override function create()
	{
		DiscordClient.changePresence("Options Menu");

		initStateScript('OptionsState');
		scriptGroup.set('this', this);

		if (isHardcodedState())
		{
			sky = new FlxSprite(0, -758).loadGraphic(Paths.image('title/bg/BG1'));
			sky.antialiasing = ClientPrefs.globalAntialiasing;
			add(sky);

			clouds = new FlxSprite(0, -610).loadGraphic(Paths.image('title/bg/BG2'));
			clouds.antialiasing = ClientPrefs.globalAntialiasing;
			add(clouds);

			cloudShader = newShader('cloud');
			cloudShader.setFloat('red_amt', 0.4);
			cloudShader.setFloat('green_amt', 0.5);
			cloudShader.setFloat('blue_amt', 0.3);

			cloudShaderObj = new FlxSprite(0, 0 - FlxG.height).makeGraphic(1280, 720 * 3, FlxColor.WHITE);
			cloudShaderObj.blend = ADD;
			cloudShaderObj.shader = cloudShader;
			add(cloudShaderObj);

			var black:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
			black.alpha = 0.4;
			add(black);

			grpOptions = new FlxTypedGroup<FlxText>();
			add(grpOptions);

			mouseObject = new FlxObject(0, 0, 5, 5);
			add(mouseObject);

			for (i in 0...options.length)
			{
				var optionText:FlxText = new FlxText(0, 0, 1280, options[i]);
				optionText.setFormat(FONT, fontSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				optionText.screenCenter();
				optionText.ID = i;
				optionText.y += (100 * (i - (options.length / 2))) + 50;
				optionText.borderSize = 2;
				grpOptions.add(optionText);
			}

			changeSelection();
			backButton = new FlxSprite(10, 10).loadGraphic(Paths.image("overworld/ui/phoneui/backminimenu"));
			add(backButton);
		}
		ClientPrefs.flush();

		super.create();
	}

	function newShader(?fragFile:String, ?vertFile:String)
	{ // Surely this should just be in a util or something right
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

	// there's just gotta be a better way to do this ^^^

	override function closeSubState()
	{
		backButton.alpha = 1;
		for (item in grpOptions.members)
		{
			item.alpha = (curSelected == item.ID ? 1 : 0.4);
		}
		scriptGroup.call('onCloseSubState', []);
		super.closeSubState();
		ClientPrefs.flush();
	}

	var totalElapsed:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isHardcodedState())
		{
			totalElapsed += elapsed;
			cloudShader.setFloat('iTime', totalElapsed);

			mouseObject.setPosition(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);

			var isOverlapped:Bool = false;
			if (mouseObject.overlaps(backButton))
			{
				isOverlapped = true;
				if (FlxG.mouse.justPressed)
				{
					letsGoBack();
				}
			}
			for (item in grpOptions.members)
			{
				if (mouseObject.overlaps(item))
				{
					isOverlapped = true;
					if (FlxG.mouse.justPressed)
					{
						openSelectedSubstate(options[item.ID]);
						return;
					}
				}
			}
			FlxG.mouse.load(Paths.image('overworld/ui/cursor/${isOverlapped ? 'click' : 'cursor'}').bitmap, 0.325);
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
				letsGoBack();
			}

			if (controls.ACCEPT)
			{
				openSelectedSubstate(options[curSelected]);
			}
		}
	}

	function letsGoBack()
	{
		FlxG.sound.play(Paths.sound('cancelMenu'));
		if (onPlayState)
		{
			FlxG.switchState(PlayState.new);
			FlxG.sound.music.volume = 0;
		}
		else if (onPhone) FlxG.switchState(OverworldState.new);
		else FlxG.switchState(TitleState201.new);
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
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
