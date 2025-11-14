package funkin.game.huds;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxObject;
import flixel.util.FlxStringUtil;
import funkin.objects.Bar;
import funkin.objects.HealthIcon;
import flash.display.BlendMode;

@:access(funkin.states.PlayState)
class MCHUD extends BaseHUD
{
	var healthBar:Bar;
	var iconP1:HealthIcon;
	var iconP2:HealthIcon;
	var scoreTxt:FlxText;
	var ratingsTxt:FlxText;
	var ratingTimer:FlxTimer = null;
	var textDivider = '|';

	override function init()
	{
		name = 'Minecraft';

		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.downScroll ? 0.89 : 0.11), 'ui/headlights/healthbar', function() return parent.health,
			parent.healthBounds.min, parent.healthBounds.max);
		healthBar.bg.blend = BlendMode.MULTIPLY;
		healthBar.leftBar.loadGraphic(Paths.image('ui/headlights/healthbar_inside'));
		healthBar.rightBar.loadGraphic(Paths.image('ui/headlights/healthbar_inside'));
		healthBar.leftToRight = true;
		healthBar.forEachAlive(obj -> {
			obj.scale.set(4, 4);
			obj.updateHitbox();
			obj.antialiasing = false;
		});

		healthBar.barOffset.set(0, 0);
		healthBar.barWidth = 182;
		healthBar.barHeight = 5;
		healthBar.screenCenter(X);
		healthBar.setColors(FlxColor.fromRGB(143, 209, 85), FlxColor.fromRGB(255, 19, 19));
		add(healthBar);

		scoreTxt = new FlxText(0, healthBar.y + 30, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("Minecraftia-Regular.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.antialiasing = false;
		scoreTxt.borderSize = 1;
		add(scoreTxt);

		ratingsTxt = new FlxText(0, FlxG.height * (!ClientPrefs.downScroll ? 0.09 : 0.81), FlxG.width, "", 20);
		ratingsTxt.setFormat(Paths.font("Minecraftia-Regular.ttf"), 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ratingsTxt.scrollFactor.set();
		ratingsTxt.borderSize = 1;
		ratingsTxt.antialiasing = false;
		add(ratingsTxt);

		onUpdateScore(0, 0, 0);

		parent.scripts.set('healthBar', healthBar);
		parent.scripts.set('ratingsTxt', ratingsTxt);
		parent.scripts.set('scoreTxt', scoreTxt);
	}

	override function onUpdateScore(score:Int = 0, accuracy:Float = 0, misses:Int = 0, missed:Bool = false)
	{
		var str:String = 'N/A';
		if (parent.totalPlayed != 0)
		{
			str = '${accuracy}% - ${parent.ratingFC}';
		}

		final tempScore:String = 'Score: ${FlxStringUtil.formatMoney(score, false)}'
			+ (!parent.instakillOnMiss ? ' $textDivider Misses: ${misses}' : "")
			+ ' $textDivider Accuracy: ${str}';

		scoreTxt.text = '${tempScore}\n';
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
		if (ratingTimer != null) ratingTimer.cancel();

		ratingsTxt.text = CoolUtil.capitalize(ratingImage) + '\n' + combo;

		ratingTimer = FlxTimer.wait(1.5, () -> {
			ratingsTxt.text = '';
		});
	}
}
