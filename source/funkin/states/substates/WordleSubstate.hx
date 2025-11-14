package funkin.states.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import funkin.data.*;
import funkin.states.*;
import funkin.objects.*;
import funkin.backend.MusicBeatSubstate;

using StringTools;

class WordleSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;
	final FONT:String = Paths.font("ATTFShinGoProBold.ttf");
	var canInput:Bool = false;
	var canBack:Bool = false;
	var wordleDay:Array<String> = [
		// FUUUCK YOUUUUU FUCKK YOUUUUUUUUUUUUUUUUUU FUUUCKK YOUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
		'SCARY',
		'TWEAK',
		'smile',
		'LUCKY',
		'creep',
		'Three',
		'GHOST',
		'RANDY',
		'SPEED',
		'TREAT',
		'DEMON',
		'SYBAU',
		'vouch',
		'chart',
		'SKULL',
		'witch',
		'apple',
		'craft',
		'earth',
		'party',
		'SPICE',
		'mario',
		'zelda',
		'CLOWN',
		'BOOOO',
		'hello',
		'bello',
		'wenda',
		'MUMMY',
		'jolly',
		'LOGGO',
		'jason',
		'BASIL',
		'ORBYY',
		'bound',
		'CHLOE',
		'porns',
		'SPORE',
		'death',
		'jammy',
		'humby',
		'looey',
		'ditch',
		'wedge',
		'mello',
		'alpha',
		'candy',
		'gummy',
		'sorry',
		'tummy',
		'yummy',
		'dummy',
		'bunny',
		'yummy',
		'aaaaa',
		'titty',
		'comet',
		'porny',
		'sfgip',
		'sxsvn',
		'gifts',
		'elves',
		'santa'
	];

	var howDoIfeel:Array<String> = [
		'This is about to happen...:',
		'I have Cheated. But is is: okay',
		'Let us go bro. We win.',
		'Three memes. Like the comets "flamer" classic.',
		'It is okay',
		'Phew Woo mama that was a close one',
		'Ohhhhhhhhhhh my goodly two shoes am i a lucky shoelace'
	];
	var cols:Array<FlxColor> = [0xFF1F1F1F, 0xFFB59F3a, 0xFF528D4D];
	var infoText:String = 'i\'m not sure how well this code will run past january 1st 2026 so watch out !';
	// Letters!
	var letters:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var word:String;
	var brText:FlxText;
	var guess:String = '';

	public var wdyg:Array<String> = [];

	public var ttxt:FlxTypedGroup<FlxText>;
	public var btt:FlxSpriteGroup;
	public var manfuckyou:Array<Dynamic> = [[], []];

	var sofar:Int = 0;
	var canGuess = true;

	public function new()
	{
		super();

		FlxTimer.wait(0.2, onBack);
	}

	function weirdDateThing(dd, dm)
	{
		// I'm sorry for using gay it just is
		var gayMath = (dd + ((dm % 2) * 31)) % wordleDay.length;
		return gayMath;
	}

	override function create()
	{
		var date = Date.now();
		var gd = date.getDate();
		var gm = date.getMonth();
		wdyg = [];

		/*
			if (FlxG.save.data.did_wordle == null)
			{
				FlxG.save.data.did_wordle = false;
				FlxG.save.flush();
			}
			if (FlxG.save.data.wordle_day == null)
			{
				FlxG.save.data.wordle_day = gd;
				FlxG.save.flush();
			}

			if (FlxG.save.data.wordle_day != gd)
			{
				FlxG.save.data.wordle_day = gd;
				FlxG.save.flush();
				FlxG.save.data.did_wordle = false;
				FlxG.save.flush();
			}

			if (FlxG.save.data.did_wordle && FlxG.save.data.wordle_day == gd)
			{
				trace('BOY YOU ALREADY DID WORDLE');
			}
			FlxG.save.data.wordle_day = gd;
		 */
		/*
			if (FlxG.save.data.wordle_day != null)
			{
				if (FlxG.save.data.did_wordle)
				{
					trace('BOY YOU ALREADY DID WORDLE')
				}
			}
			else
			{
				FlxG.save.data.wordle_day = gd;
			}
		 */
		// trace('today is ' + date.getDate());
		word = wordleDay[weirdDateThing(gd, gm)].toUpperCase();
		// trace(word);

		var ggb:FlxSprite = new FlxSprite(0, 0).makeGraphic(1280, 720, 0xFF0A0A0A);
		ggb.alpha = 0.7;
		add(ggb);

		brText = new FlxText(0, 50, 1280, '');
		brText.setFormat(FONT, 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(brText);

		var petlText:FlxText = new FlxText(0, 50, 1280, '(Press ESCAPE to close)');
		petlText.setFormat(FONT, 25, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		petlText.y = 720 - petlText.height;
		add(petlText);

		/*
			var looey:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/repo/chickenboy'), true, 161, 203);
			looey.animation.add('yy', [
				0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
				39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49
			], 24, true);
			looey.animation.play('yy');
			add(looey); */ // does he really have to go

		var p = [0, 0];
		btt = new FlxSpriteGroup(0, 0);
		add(btt);
		ttxt = new FlxTypedGroup();
		add(ttxt);
		for (i in 0...30)
		{
			var bbt:FlxSprite = new FlxSprite(0 + (p[0] * 50), 0 + (p[1] * 50)).makeGraphic(50, 50, FlxColor.WHITE);
			bbt.color = 0x1f1f1f;
			bbt.ID = i;
			var txt:FlxText = new FlxText(532 + (p[0] * 50), (255 - 33) + (p[1] * 50), -1, '');
			txt.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, FlxTextAlign.CENTER);
			txt.ID = i;
			p[0] += 1;
			if (p[0] > 4)
			{
				p[0] = 0;
				p[1] += 1;
			}
			btt.add(bbt);
			ttxt.add(txt);
			manfuckyou[0].push(txt);
			manfuckyou[1].push(bbt);
		}
		// ttxt.screenCenter();
		btt.screenCenter();
		btt.forEach(function(spr:FlxSprite) {
			spr.centerOrigin();
			spr.setGraphicSize(spr.width * 0.95);
		});
		camera = CameraUtil.lastCamera;
		super.create();
	}

	function flipObj(obj:Int, ?col:FlxColor = FlxColor.WHITE, delay:Float = 0)
	{
		// WHY DOESN'T THIS WORK
		trace(obj, col, delay);
		FlxTween.tween(manfuckyou[1][obj].scale, {y: 0}, 0.3,
			{
				startDelay: delay,
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween) {
					// I DONT WANNA DO IT LIKE THIS
					btt.forEach(function(spr:FlxSprite) {
						if (obj == spr.ID)
						{
							spr.color = col;
						}
					});
					trace(manfuckyou[1][obj].color);
					FlxTween.tween(manfuckyou[1][obj].scale, {y: 0.95}, 0.3, {ease: FlxEase.quadOut});
				}
			});

		FlxTween.tween(manfuckyou[0][obj].scale, {y: 0}, 0.3,
			{
				startDelay: delay,
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween) {
					FlxTween.tween(manfuckyou[0][obj].scale, {y: 0.95}, 0.3, {ease: FlxEase.quadOut});
				}
			});
	}

	function onComp()
	{
		canInput = true;
	}

	function onBack()
	{
		canInput = true;
		canBack = true;
	}

	function gameEnd(didYouWin:Bool)
	{
		FlxG.save.data.did_wordle = true;
		trace(didYouWin ? 'YES I DID! I AM A GOOD BOY!' : 'I failed the wordle. This is my last post.');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE && canBack) close();

		if (canInput)
		{
			for (i in 65...91)
			{
				if (FlxG.keys.anyJustPressed([i]))
				{
					if (guess.length < 5)
					{
						var letter = letters.charAt(i - 65);
						guess += letter;
						updateThisStuff();
					}
				}
			}
			if (FlxG.keys.justPressed.BACKSPACE)
			{
				guess = guess.substring(0, guess.length - 1);
				updateThisStuff();
			}
			if (FlxG.keys.justPressed.ENTER)
			{
				if (guess.length > 4)
				{
					guessWord();
					sofar += 1;
					// updateThisStuff();
				}
			}
		}
		super.update(elapsed);
	}

	function gayReplace(phrase:String, find:String, replace:String)
	{
		// this is probably a bad idea but like whoooo literally gives a fukc
		var index = phrase.indexOf(find);

		if (index != -1)
		{
			var start = phrase.substr(0, index);
			var end = phrase.substr(index + find.length);

			// Combine the parts to create the new string
			var newString = start + replace + end;
			trace(': ' + newString);
			return newString;
		}
		else
		{
			// trace(phrase);
			return phrase;
		}
	}

	function gayerReplace(phrase:String, find:Int, replace:String)
	{
		var start = phrase.substr(0, find);
		var end = phrase.substr(find + 1, phrase.length);
		var newString = start + replace + end;
		return newString;
	}

	function guessWord()
	{
		var fakeguess:String = guess;
		var fakeword:String = word;
		var yaaay:Array<Int> = [0, 0, 0, 0, 0];
		trace(guess); // Guessed word
		trace(sofar); // How many guesses have you done?

		// This is really really really bad but this detects for green, or correct letters.
		for (i in sofar * 5...(sofar * 5) + 5)
		{
			// uhh
			var or = fakeword.charAt(i - (sofar * 5));
			var tr = fakeguess.charAt(i - (sofar * 5));
			if (or == tr)
			{
				yaaay[i - (sofar * 5)] = 2; // Sets yaaay to 2, or flagged as green.
				fakeword = gayerReplace(fakeword, i - (sofar * 5), '_');
			}
		}
		// This gets worse. Let's detect yellow, or "it's in there" letters.
		for (i in sofar * 5...(sofar * 5) + 5)
		{
			if (yaaay[i - (sofar * 5)] != 2) // If this letter is already correct, skip it
			{
				var or = fakeword.charAt(i - (sofar * 5));
				var tr = fakeguess.charAt(i - (sofar * 5));
				if (StringTools.contains(fakeword, tr))
				{
					// i - (sofar*5)
					yaaay[i - (sofar * 5)] = 1;
					fakeword = gayReplace(fakeword, tr, '_');
				}
			}
			// Well with that out of the way, let us flip it.
			flipObj(i, cols[yaaay[i - (sofar * 5)]], (i - (sofar * 5)) / 5);
		}
		canInput = false;
		trace(yaaay);
		new FlxTimer().start(1, function(tmr:FlxTimer) {
			if (guess.toUpperCase() == word.toUpperCase())
			{
				trace('win');
				gameEnd(true);
				brText.text = howDoIfeel[sofar];
			}
			else
			{
				if (sofar > 5)
				{
					gameEnd(false);
					brText.text = word;
				}
				else
				{
					onComp();
					guess = '';
				}
			}
		});
		// trace(fakeword);
	}

	function updateThisStuff()
	{
		// WHY DOESN'T THIS WORK
		manfuckyou[0][1].text = 'WAWAWAWA';
		for (i in sofar * 5...(sofar * 5) + 5)
		{
			var leta:String = guess.charAt(i - (sofar * 5));
			if (leta == null) leta = '';
			ttxt.forEach(function(spr:FlxText) {
				if (i == spr.ID)
				{
					spr.text = Std.string(leta);
				}
			});
		}
	}
}
