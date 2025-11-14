package funkin.game.huds;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxObject;
import flixel.util.FlxStringUtil;

// if the hud resembles psych u can just extend this instead of base
@:access(funkin.states.PlayState)
class ILOVEHUD extends BaseHUD
{
	var ratingGraphic:FlxSprite;
	var ratingNumGroup:FlxTypedGroup<FlxSprite>;
	var ratingLines:FlxSprite;

	// var among:FlxSprite;
	var hpText:FlxText;
	var wychText:FlxText;
	var miText:FlxText;
	var wychText2:FlxText;
	var acText:FlxText;
	var wychText3:FlxText;

	var showRating:Bool = true;
	var showRatingNum:Bool = true;
	var showCombo:Bool = true;

	override function init()
	{
		name = 'ILOVE';

		// r.e.p.o boy
		for (i in 0...3)
		{
			var plus:FlxSprite = new FlxSprite(15, 25 + (i * 75)).loadFromSheet('ui/repo/ui_sheet', 'Symbol 3', 0);
			plus.animation.curAnim.curFrame = i;
			plus.x += 25;
			plus.y += 17;
			add(plus);
		}

		// HEALTH
		hpText = new FlxText(90, -3, -1, '50');
		hpText.setFormat(Paths.font("repo.ttf"), 90, 0x66FF7C);
		wychText = new FlxText(160, 15, -1, '/100');
		wychText.setFormat(Paths.font("repo.ttf"), 45, 0x26CF3F);

		// ACCURACY
		acText = new FlxText(90, -3 + 75, -1, '0');
		acText.setFormat(Paths.font("repo.ttf"), 90, 0xFFF066);
		wychText2 = new FlxText(160, 15 + 75, -1, '/100');
		wychText2.setFormat(Paths.font("repo.ttf"), 45, 0xDCDCDC);

		// MISSES
		miText = new FlxText(90, -3 + 150, -1, '0');
		miText.setFormat(Paths.font("repo.ttf"), 90, 0xFF4A6E);

		for (i in [hpText, wychText, miText, wychText2, acText])
		{
			i.x += 25;
			i.y += 17;
			add(i);
		}

		// mandatory 201 street
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

		parent.scripts.set('hpText', hpText);
		parent.scripts.set('acText', acText);
		parent.scripts.set('miText', miText);
	}

	override function onUpdateScore(score:Int = 0, accuracy:Float = 0, misses:Int = 0, missed:Bool = false)
	{
		acText.text = parent.totalPlayed != 0 ? '${accuracy}%' : '?';
		wychText2.x = acText.x + acText.width;
		wychText2.text = '(' + FlxStringUtil.formatMoney(score, false) + ')';
		miText.text = '${misses}';
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function onHealthChange(health:Float)
	{
		hpText.text = '' + Std.int(health * 50);
		wychText.x = hpText.x + hpText.width;
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
