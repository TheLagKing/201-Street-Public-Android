package funkin.states.options;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import funkin.backend.DebugDisplay;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Graphics and Visuals';
		rpcTitle = 'Graphics Settings Menu'; // for Discord Rich Presence

		var option:Option = new Option('Flashing Lights', 'Hides flashy visuals when disabled', 'flashing', 'bool', true);
		addOption(option);

		var option:Option = new Option('Subtitles', "Shows subtitles in gameplay", 'subtitles', 'bool', true);
		addOption(option);

		var option:Option = new Option('GPU Caching', 'Enables GPU caching', 'gpuCaching', 'bool', false);
		addOption(option);

		var option:Option = new Option('Shaders', 'If disabled, most shaders will not appear', 'shaders', 'bool', true);
		addOption(option);

		var option:Option = new Option('Anti-Aliasing', 'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing', 'bool', true);
		// option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; // Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		#if !mobile
		var option:Option = new Option('FPS Counter', 'Shows FPS counter', 'showFPS', 'bool', true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		var option:Option = new Option('Framerate', "Framerate", 'framerate', 'int', 60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;

		super();
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText))
			{
				(cast sprite : FlxSprite).antialiasing = ClientPrefs.globalAntialiasing;
			}
		}

		FlxSprite.defaultAntialiasing = ClientPrefs.globalAntialiasing;
	}

	function onChangeFramerate()
	{
		if (ClientPrefs.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if (DebugDisplay.instance != null) DebugDisplay.instance.visible = ClientPrefs.showFPS;
	}
	#end
}
