package funkin.game.huds;

import flixel.FlxObject;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

import funkin.objects.Bar;

@:access(funkin.states.PlayState)
class EBHUD extends BaseHUD
{
	var ratings:FlxSprite;
	var scoreTxt:FlxBitmapText;
	var missTxt:FlxBitmapText;
	var ratingNums:FlxBitmapText;
	var ratingTimer:FlxTimer = null;
	
	override function init()
	{
		name = 'EBHUD';
		
		ratings = new FlxSprite(510, !ClientPrefs.downScroll ? 70 : 600);
		ratings.frames = Paths.getSparrowAtlas('ui/starbound/ratings');
		ratings.animation.addByPrefix('epic', 'epic', 24, false);
		ratings.animation.addByPrefix('sick', 'sick', 24, false);
		ratings.animation.addByPrefix('good', 'good', 24, false);
		ratings.animation.addByPrefix('bad', 'bad', 24, false);
		ratings.animation.addByPrefix('shit', 'shit', 24, false);
		ratings.setGraphicSize(Std.int(ratings.width * 3));
		ratings.updateHitbox();
		ratings.antialiasing = false;
		ratings.visible = false;
		ratings.animation.play('epic');
		add(ratings);
		
		ratingNums = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("ui/starbound/scorenumbers"), '0123456789', new FlxPoint(8, 13), new FlxPoint(1, 0)));
		ratingNums.autoSize = true;
		ratingNums.setGraphicSize(Std.int(ratingNums.width * 2));
		ratingNums.updateHitbox();
		ratingNums.antialiasing = false;
		ratingNums.alignment = LEFT;
		ratingNums.x = 75;
		ratingNums.y = !ClientPrefs.downScroll ? 200 : 530;
		ratingNums.text = "0";
		//add(ratingNums);
		
		scoreTxt = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("ui/starbound/scorenumbers"), '0123456789', new FlxPoint(8, 13), new FlxPoint(1, 0)));
		scoreTxt.autoSize = false;
		scoreTxt.setGraphicSize(Std.int(scoreTxt.width * 2));
		scoreTxt.updateHitbox();
		scoreTxt.antialiasing = false;
		scoreTxt.alignment = LEFT;
		scoreTxt.x = 350;
		scoreTxt.y = !ClientPrefs.downScroll ? 610 : 70;
		scoreTxt.text = "0";
		add(scoreTxt);
		
		missTxt = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("ui/starbound/scorenumbers"), '0123456789', new FlxPoint(8, 13), new FlxPoint(1, 0)));
		missTxt.autoSize = false;
		missTxt.setGraphicSize(Std.int(missTxt.width * 2));
		missTxt.updateHitbox();
		missTxt.antialiasing = false;
		missTxt.alignment = LEFT;
		missTxt.x = scoreTxt.x;
		missTxt.y = !ClientPrefs.downScroll ? 645 : 105;
		missTxt.text = "0";
		add(missTxt);	
		
		onUpdateScore(0, 0, 0);
		parent.scripts.set('scoreTxt', scoreTxt);
		parent.scripts.set('missTxt', missTxt);
	}
	
	override function onUpdateScore(score:Int = 0, accuracy:Float = 0, misses:Int = 0, missed:Bool = false)
	{
		var blankScore:String = '000000';
		var blankMisses:String = '000';
		
		scoreTxt.text = blankScore.substr(0, blankScore.length - ('' + score).length) + ('' + score);
		missTxt.text = blankMisses.substr(0, blankMisses.length - ('' + misses).length) + ('' + misses);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	override function popUpScore(ratingImage:String, combo:Int)
	{
		var blankCombo:String = '000';
		
		if (ratingTimer != null) ratingTimer.cancel();
		
		ratings.animation.play(ratingImage);
		//ratingsBox.visible = true;
		ratings.visible = true;
		//ratingNums.visible = true;
		//ratingNums.text = blankCombo.substr(0, blankCombo.length - ('' + combo).length) + ('' + combo);
		
		ratingTimer = FlxTimer.wait(1.5, () -> {
			//ratingsBox.visible = false;
			ratings.visible = false;
			//ratingNums.visible = false;
		});
	}
}
