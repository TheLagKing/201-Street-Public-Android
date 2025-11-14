package funkin.game.huds;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxObject;
import flixel.util.FlxStringUtil;
import funkin.objects.Bar;
import funkin.objects.HealthIcon;

@:access(funkin.states.PlayState)
class Two01HUD extends BaseHUD
{
	var ratingGraphic:FlxSprite;
	var ratingNumGroup:FlxTypedGroup<FlxSprite>;
	var ratingLines:FlxSprite;

	var healthBar:Bar;
	var healthBarFG:FlxSprite;
	var iconP1:HealthIcon;
	var iconP2:HealthIcon;
	var scoreTxt:FlxText;

	var textDivider = '|';

	var showRating:Bool = true;
	var showRatingNum:Bool = true;
	var showCombo:Bool = true;

	var updateIconPos:Bool = true;
	var updateIconScale:Bool = true;
	var comboOffsets:Array<Int> = [0, 0]; // bvgcgvfdxdfgvrfgdtvgdf

	// TODO: Make combo shit change for week 6, the ground work is already there so incase someone else wants to come on in and mess w it.
	override function init()
	{
		name = '201';

		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.downScroll ? 0.89 : 0.11), 'healthBar', function() return parent.health, parent.healthBounds.min,
			parent.healthBounds.max);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.bg.visible = false;
		healthBar.barHeight += 1;
		reloadHealthBarColors();
		add(healthBar);

		healthBarFG = new FlxSprite(-77, -88).loadGraphic(Paths.image('ui/global/healthbarFG'));
		healthBarFG.antialiasing = ClientPrefs.globalAntialiasing;
		healthBar.add(healthBarFG);

		iconP1 = new HealthIcon(parent.boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		add(iconP1);

		iconP2 = new HealthIcon(parent.dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		add(iconP2);

		scoreTxt = new FlxText(0, healthBar.y + 40, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("ATTFShinGoProBold.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);

		ratingLines = new FlxSprite(0, ClientPrefs.downScroll ? 578 : 59).loadGraphic(Paths.image('ui/global/ratings/lines'));
		ratingLines.screenCenter(X);
		ratingLines.alpha = 0;
		ratingLines.antialiasing = ClientPrefs.globalAntialiasing;
		add(ratingLines);

		ratingGraphic = new FlxSprite();
		ratingGraphic.alpha = 0;
		add(ratingGraphic);

		ratingNumGroup = new FlxTypedGroup();
		add(ratingNumGroup);

		onUpdateScore(0, 0, 0);

		parent.scripts.set('healthBar', healthBar);
		parent.scripts.set('healthBarFG', healthBarFG);
		parent.scripts.set('iconP1', iconP1);
		parent.scripts.set('iconP2', iconP2);
		parent.scripts.set('scoreTxt', scoreTxt);
		parent.scripts.set('comboOffsets', comboOffsets);
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
		final posX = FlxG.width / 2;
		final posY = FlxG.height * (ClientPrefs.downScroll ? 0.84 : 0.12);

		if (showRating)
		{
			FlxTween.cancelTweensOf(ratingGraphic, ['scale.x', 'scale.y', 'alpha']);
			FlxTween.cancelTweensOf(ratingLines, ['alpha']);
			ratingGraphic.alpha = 1;
			ratingGraphic.loadGraphic(Paths.image('ui/global/ratings/' + ratingImage));
			ratingGraphic.screenCenter();
			ratingGraphic.x = posX - (ratingGraphic.width / 2);
			ratingGraphic.y = posY;
			ratingGraphic.x += comboOffsets[0];
			ratingGraphic.y += comboOffsets[1];
			ratingGraphic.antialiasing = ClientPrefs.globalAntialiasing;
			ratingGraphic.scale.set(1.1, 1.1);
			FlxTween.tween(ratingGraphic.scale, {x: 1, y: 1}, 0.5, {ease: FlxEase.expoOut});
			FlxTween.tween(ratingGraphic, {alpha: 0}, 0.5, {startDelay: Conductor.stepCrotchet * 0.01, ease: FlxEase.expoOut});
			ratingLines.alpha = 1;
			FlxTween.tween(ratingLines, {alpha: 0}, 0.5, {startDelay: Conductor.stepCrotchet * 0.01, ease: FlxEase.expoOut});
		}

		if (showRatingNum)
		{
			ratingNumGroup.clear();

			var seperatedScore:Array<Int> = [];

			if (combo >= 1000)
			{
				seperatedScore.push(Math.floor(combo / 1000) % 10);
			}
			seperatedScore.push(Math.floor(combo / 100) % 10);
			seperatedScore.push(Math.floor(combo / 10) % 10);
			seperatedScore.push(combo % 10);

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = ratingNumGroup.recycle(FlxSprite);
				numScore.loadGraphic(Paths.image('ui/global/ratings/' + Std.int(i)));
				numScore.alpha = 1;
				numScore.screenCenter();
				numScore.x = posX + (25 * daLoop) - 37;
				numScore.y = posY + (ClientPrefs.downScroll ? -70 : 70);
				numScore.x += comboOffsets[0];
				numScore.y += comboOffsets[1];
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.scale.set(0.8, 0.8);
				ratingNumGroup.add(numScore);
				FlxTween.tween(numScore, {alpha: 0}, 0.5, {startDelay: Conductor.stepCrotchet * 0.01, ease: FlxEase.expoOut});

				daLoop++;
			}
		}
	}

	override function cachePopUpScore()
	{
		var ratings = ["sick", "good", "bad", "shit"];
		if (ClientPrefs.useEpicRankings) ratings.push('epic');

		for (rating in ratings)
		{
			ratingGraphic.loadGraphic(Paths.image('ui/global/ratings/$rating'));
		}

		for (i in 0...10)
		{
			Paths.image('ui/global/ratings/$i');
		}
	}
}
