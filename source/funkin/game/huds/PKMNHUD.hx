package funkin.game.huds;

import flixel.FlxObject;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxBitmapText;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import funkin.objects.Bar;

@:access(funkin.states.PlayState)
class PKMNHUD extends BaseHUD
{
	var healthBar:Bar;
	var bigBar:FlxSprite;
	var smallBar:FlxSprite;
	var ratingsBox:FlxSprite;
	var ratings:FlxSprite;
	var scoreTxt:FlxBitmapText;
	var missTxt:FlxBitmapText;
	var ratingNums:FlxBitmapText;
	var ratingTimer:FlxTimer = null;

	override function init()
	{
		name = 'PKMN';

		bigBar = new FlxSprite(5, !ClientPrefs.downScroll ? 5 : 570).loadGraphic(Paths.image('ui/pkmn/bigbar'));
		bigBar.setGraphicSize(Std.int(bigBar.width * 5));
		bigBar.updateHitbox();
		bigBar.antialiasing = false;
		add(bigBar);

		smallBar = new FlxSprite(20, !ClientPrefs.downScroll ? 625 : 5).loadGraphic(Paths.image('ui/pkmn/smallbar'));
		smallBar.setGraphicSize(Std.int(smallBar.width * 5));
		smallBar.updateHitbox();
		smallBar.antialiasing = false;
		add(smallBar);

		ratingsBox = new FlxSprite(5, !ClientPrefs.downScroll ? 120 : 450).loadGraphic(Paths.image('ui/pkmn/ratingsbox'));
		ratingsBox.setGraphicSize(Std.int(ratingsBox.width * 5));
		ratingsBox.updateHitbox();
		ratingsBox.antialiasing = false;
		ratingsBox.visible = false;
		add(ratingsBox);

		ratings = new FlxSprite(35, !ClientPrefs.downScroll ? 160 : 490);
		ratings.frames = Paths.getSparrowAtlas('ui/pkmn/ratings');
		ratings.animation.addByPrefix('epic', 'epic', 24, false);
		ratings.animation.addByPrefix('sick', 'sick', 24, false);
		ratings.animation.addByPrefix('good', 'good', 24, false);
		ratings.animation.addByPrefix('bad', 'bad', 24, false);
		ratings.animation.addByPrefix('shit', 'shit', 24, false);
		ratings.setGraphicSize(Std.int(ratings.width * 5));
		ratings.updateHitbox();
		ratings.antialiasing = false;
		ratings.visible = false;
		ratings.animation.play('idle');
		add(ratings);

		ratingNums = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("ui/pkmn/numbers"), '0123456789', new FlxPoint(8, 8), new FlxPoint(0, 0)));
		ratingNums.autoSize = false;
		ratingNums.setGraphicSize(Std.int(ratingNums.width * 5));
		ratingNums.updateHitbox();
		ratingNums.antialiasing = false;
		ratingNums.alignment = LEFT;
		ratingNums.x = 75;
		ratingNums.y = !ClientPrefs.downScroll ? 200 : 530;
		ratingNums.text = "0";
		ratingNums.visible = false;
		add(ratingNums);

		healthBar = new Bar(120, !ClientPrefs.downScroll ? 660 : 40, 'ui/pkmn/healthbar', function() return parent.health, parent.healthBounds.min,
			parent.healthBounds.max);
		healthBar.barOffset.set(1, 1);
		healthBar.barWidth = 124;
		healthBar.barHeight = 2;

		for (obj in [healthBar.bg, healthBar.rightBar, healthBar.leftBar])
		{
			obj.scale.set(5, 5);
			obj.updateHitbox();
			obj.antialiasing = false;
		}

		healthBar.setColors(FlxColor.fromRGB(72, 160, 88), FlxColor.fromRGB(208, 80, 48));
		add(healthBar);

		scoreTxt = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("ui/pkmn/numbers"), '0123456789', new FlxPoint(8, 8), new FlxPoint(1, 0)));
		scoreTxt.autoSize = false;
		scoreTxt.setGraphicSize(Std.int(scoreTxt.width * 5));
		scoreTxt.updateHitbox();
		scoreTxt.antialiasing = false;
		scoreTxt.alignment = LEFT;
		scoreTxt.x = 130;
		scoreTxt.y = !ClientPrefs.downScroll ? 35 : 600;
		scoreTxt.text = "0";
		add(scoreTxt);

		missTxt = new FlxBitmapText(FlxBitmapFont.fromMonospace(Paths.image("ui/pkmn/numbers"), '0123456789', new FlxPoint(8, 8), new FlxPoint(1, 0)));
		missTxt.autoSize = false;
		missTxt.setGraphicSize(Std.int(missTxt.width * 5));
		missTxt.updateHitbox();
		missTxt.antialiasing = false;
		missTxt.alignment = LEFT;
		missTxt.x = scoreTxt.x;
		missTxt.y = !ClientPrefs.downScroll ? 80 : 645;
		missTxt.text = "0";
		add(missTxt);

		onUpdateScore(0, 0, 0);

		parent.scripts.set('healthBar', healthBar);
		parent.scripts.set('bigBar', bigBar);
		parent.scripts.set('smallBar', smallBar);
		parent.scripts.set('ratingsBox', ratingsBox);
		parent.scripts.set('scoreTxt', scoreTxt);
		parent.scripts.set('missTxt', missTxt);
	}

	override function onUpdateScore(score:Int = 0, accuracy:Float = 0, misses:Int = 0, missed:Bool = false)
	{
		var blankScore:String = '000000';
		var blankMisses:String = '000';

		if (score >= 0) // just making it so it doesn't display a negative score, if you get a negative score it just displays as 0
		{
			scoreTxt.text = blankScore.substr(0, blankScore.length - ('' + score).length) + ('' + score);
		}
		missTxt.text = blankMisses.substr(0, blankMisses.length - ('' + misses).length) + ('' + misses);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function onHealthChange(health:Float)
	{
		final newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max),
			healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);
	}

	override function popUpScore(ratingImage:String, combo:Int)
	{
		var blankCombo:String = '000';

		if (ratingTimer != null) ratingTimer.cancel();

		ratings.animation.play(ratingImage);
		ratingsBox.visible = true;
		ratings.visible = true;
		ratingNums.visible = true;
		ratingNums.text = blankCombo.substr(0, blankCombo.length - ('' + combo).length) + ('' + combo);

		ratingTimer = FlxTimer.wait(1.5, () -> {
			ratingsBox.visible = false;
			ratings.visible = false;
			ratingNums.visible = false;
		});
	}
}
