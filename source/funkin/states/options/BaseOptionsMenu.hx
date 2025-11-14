package funkin.states.options;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import funkin.objects.*;
import funkin.backend.MusicBeatSubstate;
import funkin.objects.Character;

class BaseOptionsMenu extends MusicBeatSubstate
{
	final FONT:String = Paths.font("ATTFShinGoProBold.ttf");
	var fontSize:Int = 40;

	public var curOption:Option = null;
	public var curSelected:Int = 0;
	public var optionsArray:Array<Option>;

	public var grpOptions:FlxTypedGroup<Dynamic>; // fix this
	public var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	public var grpTexts:FlxTypedGroup<Dynamic>;

	public var bg:FlxSprite;

	public var boyfriend:Character = null;
	public var descBox:FlxSprite;
	public var descText:FlxText;

	public var title:String;
	public var rpcTitle:String;
	public var titleText:FlxText;

	var mouseObject:FlxObject;
	var backButton:FlxSprite;

	public function new()
	{
		super();

		if (title == null) title = 'Options';
		if (rpcTitle == null) rpcTitle = 'Options Menu';

		DiscordClient.changePresence(rpcTitle);

		initStateScript('Options');
		scriptGroup.set('this', this);
		scriptGroup.set('title', title);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<Dynamic>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<Dynamic>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

		titleText = new FlxText(0, 25, 1280, '');
		titleText.setFormat(FONT, fontSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(titleText);

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(FONT, 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		add(descText);

		mouseObject = new FlxObject(0, 0, 5, 5);
		add(mouseObject);

		backButton = new FlxSprite(10, 10).loadGraphic(Paths.image("overworld/ui/phoneui/backminimenu"));
		add(backButton);

		for (i in 0...optionsArray.length)
		{
			var optionText:ControlText = new ControlText(0, 70 * i, optionsArray[i].name);
			optionText.isMenuItem = true;
			optionText.x += 300;
			optionText.xAdd = 200;
			optionText.ID = i;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (optionsArray[i].type == 'bool')
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, optionsArray[i].getValue() == true);
				checkbox.sprTracker = optionText;
				checkbox.offsetY = -38;
				checkbox.offsetX = 45;
				// checkbox.scale.set(0.6, 0.6);
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			}
			else if (optionsArray[i].type != 'button' && optionsArray[i].type != 'label')
			{
				optionText.x -= 80;
				optionText.xAdd -= 80;
				var valueText:AttachedControlText = new AttachedControlText('' + optionsArray[i].getValue(), optionText.width + 80);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].setChild(valueText);
			}

			if (optionsArray[i].showBoyfriend && boyfriend == null)
			{
				reloadBoyfriend();
			}
			updateTextFrom(optionsArray[i]);
		}

		changeSelection();
		reloadCheckboxes();

		scriptGroup.set('grpOptions', grpOptions);
		scriptGroup.set('grpTexts', grpTexts);
		scriptGroup.set('checkboxGroup', checkboxGroup);
		scriptGroup.set('descBox', descBox);
		scriptGroup.set('titleText', titleText);
		scriptGroup.set('descText', descText);
		scriptGroup.call('onCreatePost', []);

		camera = CameraUtil.lastCamera;
	}

	public function addOption(option:Option)
	{
		if (optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	override function update(elapsed:Float)
	{
		mouseObject.setPosition(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);
		var accepted:Bool = controls.ACCEPT;
		var isOverlapped:Bool = false;
		for (item in grpOptions.members)
		{
			if (mouseObject.overlaps(item))
			{
				isOverlapped = true;
				if (FlxG.mouse.justPressed)
				{
					if (curSelected == item.ID) accepted = true;
					else
					{
						curSelected = item.ID;
						changeSelection(0);
					}
				}
			}
		}
		if (mouseObject.overlaps(backButton))
		{
			isOverlapped = true;
			if (FlxG.mouse.justPressed)
			{
				close();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
		}
		FlxG.mouse.load(Paths.image('overworld/ui/cursor/${isOverlapped ? 'click' : 'cursor'}').bitmap, 0.325);
		if (controls.UI_UP_P || FlxG.mouse.wheel > 0)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P || FlxG.mouse.wheel < 0)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if (nextAccept <= 0)
		{
			var usesCheckbox = true;
			if (curOption.type != 'bool')
			{
				usesCheckbox = false;
			}

			if (usesCheckbox)
			{
				if (accepted)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					curOption.setValue((curOption.getValue() == true) ? false : true);
					curOption.change();
					reloadCheckboxes();
				}
			}
			else if (curOption.type == 'button')
			{
				if (accepted) curOption.callback();
			}
			else if (curOption.type != 'label')
			{
				if (controls.UI_LEFT || controls.UI_RIGHT)
				{
					var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
					if (holdTime > 0.5 || pressed)
					{
						if (pressed)
						{
							var add:Dynamic = null;
							if (curOption.type != 'string')
							{
								add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;
							}

							switch (curOption.type)
							{
								case 'int' | 'float' | 'percent':
									holdValue = curOption.getValue() + add;
									if (holdValue < curOption.minValue) holdValue = curOption.minValue;
									else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

									switch (curOption.type)
									{
										case 'int':
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);

										case 'float' | 'percent':
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);
									}

								case 'string':
									var num:Int = curOption.curOption; // lol
									if (controls.UI_LEFT_P) --num;
									else num++;

									if (num < 0)
									{
										num = curOption.options.length - 1;
									}
									else if (num >= curOption.options.length)
									{
										num = 0;
									}

									curOption.curOption = num;
									curOption.setValue(curOption.options[num]); // lol
									// trace(curOption.options[num]);
							}
							updateTextFrom(curOption);
							curOption.change();
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
						else if (curOption.type != 'string')
						{
							holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
							if (holdValue < curOption.minValue) holdValue = curOption.minValue;
							else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

							switch (curOption.type)
							{
								case 'int':
									curOption.setValue(Math.round(holdValue));

								case 'float' | 'percent':
									curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));
							}
							updateTextFrom(curOption);
							curOption.change();
						}
					}

					if (curOption.type != 'string')
					{
						holdTime += elapsed;
					}
				}
				else if (controls.UI_LEFT_R || controls.UI_RIGHT_R)
				{
					clearHold();
				}
			}

			if (controls.RESET)
			{
				for (i in 0...optionsArray.length)
				{
					var leOption:Option = optionsArray[i];
					if (leOption.type != 'button' && leOption.type != 'label')
					{
						leOption.setValue(leOption.defaultValue);
						if (leOption.type != 'bool')
						{
							if (leOption.type == 'string')
							{
								leOption.curOption = leOption.options.indexOf(leOption.getValue());
							}
							updateTextFrom(leOption);
						}
						leOption.change();
					}
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if (boyfriend != null && boyfriend.animation.curAnim?.finished)
		{
			boyfriend.dance();
		}

		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function updateTextFrom(option:Option)
	{
		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if (option.type == 'percent') val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function clearHold()
	{
		if (holdTime > 0.5)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		holdTime = 0;
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0) curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length) curSelected = 0;

		descText.text = optionsArray[curSelected].description;
		descText.screenCenter(Y);
		descText.y += 270;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			if (item is ControlText) item.targetY = bullShit - curSelected;
			bullShit++;

			if (item is ControlText)
			{
				item.set_alpha(0.4);
				if (item.targetY == 0)
				{
					item.set_alpha(1);
				}
			}
		}
		for (text in grpTexts)
		{
			text.alpha = 0.6;
			if (text.ID == curSelected)
			{
				text.alpha = 1;
			}
		}

		descBox.setPosition(descText.x - 10, descText.y - 10);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();

		if (boyfriend != null)
		{
			boyfriend.visible = optionsArray[curSelected].showBoyfriend;
		}
		curOption = optionsArray[curSelected]; // shorter lol
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	public function reloadBoyfriend()
	{
		var wasVisible:Bool = false;
		if (boyfriend != null)
		{
			wasVisible = boyfriend.visible;
			boyfriend.kill();
			remove(boyfriend);
			boyfriend.destroy();
		}

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		insert(1, boyfriend);
		boyfriend.visible = wasVisible;
	}

	function reloadCheckboxes()
	{
		for (checkbox in checkboxGroup)
		{
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}
}
