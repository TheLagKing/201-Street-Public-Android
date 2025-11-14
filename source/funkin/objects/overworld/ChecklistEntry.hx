package funkin.objects.overworld;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;

class ChecklistEntry extends FlxSpriteGroup
{
	// FINALS
	final FILE_PREFIX:String = "overworld/ui/phoneui/checklist_icons/";
	final SIZE:Int = 17;
	final BUFFER:Float = 5;
	final INACCESSIBLE_ALPHA:Float = 0.3;

	// OBJECTS
	var entryText:FlxText;
	var checkbox:FlxSprite;
	var icon:FlxSprite;

	// BOX INFO
	var accessible:Bool;
	var checked:Bool;
	var song:String;
	var text:String;

	public function new(x:Float, y:Float, thisText:String, iconName:String, thisSong:String, isAccessible:Bool)
	{
		super(x, y);

		text = thisText;
		song = thisSong;

		checkbox = new FlxSprite(35, -32).loadGraphic(Paths.image(FILE_PREFIX + "checkbox"));
		checkbox.setGraphicSize(SIZE);
		checkbox.antialiasing = ClientPrefs.globalAntialiasing;
		this.add(checkbox);

		entryText = new FlxText(checkbox.width + BUFFER, 0, 0, text).setFormat(Paths.font('futara-maxi.otf'), SIZE, FlxColor.BLACK, LEFT);
		entryText.antialiasing = ClientPrefs.globalAntialiasing;
		this.add(entryText);

		icon = new FlxSprite(checkbox.width + entryText.width + (BUFFER * 2) - 7, -5).loadGraphic(Paths.image(FILE_PREFIX + iconName));
		icon.setGraphicSize(SIZE);
		icon.antialiasing = ClientPrefs.globalAntialiasing;
		this.add(icon);

		refresh(isAccessible);
	}

	public function refresh(isAccessible:Bool)
	{
		checked = FlxG.save.data.songsBeaten.contains(song);
		accessible = (isAccessible || checked);

		if (accessible)
		{
			checkbox.alpha = 1;
			entryText.text = text;
			entryText.alpha = 1;
			icon.alpha = 1;
		}
		else
		{
			checkbox.alpha = INACCESSIBLE_ALPHA;
			entryText.text = "???";
			entryText.alpha = INACCESSIBLE_ALPHA;
			icon.alpha = 0;
		}

		var checkSprite:String = checked ? "checkbox_tick" : "checkbox";
		checkbox.loadGraphic(Paths.image(FILE_PREFIX + checkSprite));
		checkbox.setGraphicSize(SIZE);
	}

	inline public function getChecked():Bool
	{
		return checked;
	}
}
