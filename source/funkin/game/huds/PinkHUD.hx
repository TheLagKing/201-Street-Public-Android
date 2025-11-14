package funkin.game.huds;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxObject;
import flixel.util.FlxStringUtil;
import funkin.objects.Bar;
import funkin.objects.HealthIcon;

@:access(funkin.states.PlayState)
class PinkHUD extends BaseHUD
{
	var healthBar:Bar;
	var healthBarFG:FlxSprite;
	var iconP1:HealthIcon;
	var iconP2:HealthIcon;
	var scoreTxt:FlxText;

	var ratingsTxt:FlxText;
	var ratingTimer:FlxTimer = null;

	var textDivider = '|';

	var updateIconPos:Bool = true;
	var updateIconScale:Bool = true;

	// TODO: Make combo shit change for week 6, the ground work is already there so incase someone else wants to come on in and mess w it.
	override function init()
	{
		name = 'Pink';

		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.downScroll ? 0.89 : 0.11), 'healthBar', function() return parent.health, parent.healthBounds.min,
			parent.healthBounds.max);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		reloadHealthBarColors();
		add(healthBar);

		iconP1 = new HealthIcon(parent.boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		add(iconP1);

		iconP2 = new HealthIcon(parent.dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		add(iconP2);

		scoreTxt = new FlxText(0, healthBar.y + 40, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("rpg-maker-2k.otf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.antialiasing = false;
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);

		ratingsTxt = new FlxText(0, !ClientPrefs.downScroll ? healthBar.y - 125 : healthBar.y + 75, FlxG.width, "", 20);
		ratingsTxt.setFormat(Paths.font("rpg-maker-2k.otf"), 32, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ratingsTxt.scrollFactor.set();
		ratingsTxt.borderSize = 1;
		ratingsTxt.antialiasing = false;
		add(ratingsTxt);

		onUpdateScore(0, 0, 0);

		parent.scripts.set('healthBar', healthBar);
		parent.scripts.set('ratingsTxt', ratingsTxt);
		parent.scripts.set('iconP1', iconP1);
		parent.scripts.set('iconP2', iconP2);
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

	public function updateIconsPosition()
	{
		if (!updateIconPos) return;

		final iconOffset:Int = 26;
		if (!healthBar.leftToRight)
		{
			iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		}
		else
		{
			iconP1.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
			iconP2.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		}
	}

	public function updateIconsScale(elapsed:Float)
	{
		if (!updateIconScale) return;

		final mult:Float = MathUtil.decayLerp(iconP1.scale.x, 1, 9, elapsed);
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		final mult:Float = MathUtil.decayLerp(iconP2.scale.x, 1, 9, elapsed);
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();
	}

	public function reloadHealthBarColors()
	{
		var dad = parent.dad;
		var boyfriend = parent.boyfriend;
		if (!healthBar.leftToRight)
		{
			healthBar.setColors(dad.healthColour, boyfriend.healthColour);
		}
		else
		{
			healthBar.setColors(boyfriend.healthColour, dad.healthColour);
		}
	}

	public function flipBar()
	{
		healthBar.leftToRight = !healthBar.leftToRight;
		iconP1.flipX = !iconP1.flipX;
		iconP2.flipX = !iconP2.flipX;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		updateIconsPosition();
		updateIconsScale(elapsed);
	}

	override function beatHit()
	{
		if (!updateIconScale) return;

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();
	}

	override function onCharacterChange()
	{
		reloadHealthBarColors();
		iconP1.changeIcon(parent.boyfriend.healthIcon);
		iconP2.changeIcon(parent.dad.healthIcon);
	}

	override function onHealthChange(health:Float)
	{
		final newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max),
			healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0; // If health is under 20%, change player icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0; // If health is over 80%, change opponent icon to frame 1 (losing icon), otherwise, frame 0 (normal)
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
