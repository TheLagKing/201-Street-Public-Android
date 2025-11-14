var totalElapsed:Float = 0;
var offset:Float = 1;

function onCountdownStarted()
{
	function numericForInterval(start, end, interval, func)
	{
		var index = start;
		while (index < end)
		{
			func(index);
			index += interval;
		}
	}

	var counter:Int = -1;
	var counter2:Int = -1;
	var counter3:Int = -1;
	var tween:String = 'backOut';
	var distance:Int = 20;
	var time:Int = 2;
	var time2:Int = 5;

	// FIRST FUNKY MODCHART

	numericForInterval(1152, 1280, 4, function(step) {
		counter = counter + 1;
		if (counter > 1) counter = 0;

		if (counter == 0)
		{
			modManager.queueEase(step, step + time, "transform0Y", -distance, tween);
			modManager.queueEase(step, step + time + 1, "transform1Y", distance, tween);
			modManager.queueEase(step, step + time, "transform2Y", -distance, tween);
			modManager.queueEase(step, step + time + 3, "transform3Y", distance, tween);
		}
		else
		{
			modManager.queueEase(step, step + time + 1, "transform0Y", distance, tween);
			modManager.queueEase(step, step + time, "transform1Y", -distance, tween);
			modManager.queueEase(step, step + time + 3, "transform2Y", distance, tween);
			modManager.queueEase(step, step + time, "transform3Y", -distance, tween);
		}
	});

	// SECOND FUNKY MODCHART

	numericForInterval(2592, 2848, 4, function(step) { // 3168
		counter2 = counter2 + 1;
		if (counter2 > 1) counter2 = 0;

		if (counter2 == 0)
		{
			modManager.queueEase(step, step + time, "transform0Y", -distance, tween);
			modManager.queueEase(step, step + time + 1, "transform1Y", distance, tween);
			modManager.queueEase(step, step + time, "transform2Y", -distance, tween);
			modManager.queueEase(step, step + time + 3, "transform3Y", distance, tween);
		}
		else
		{
			modManager.queueEase(step, step + time + 1, "transform0Y", distance, tween);
			modManager.queueEase(step, step + time, "transform1Y", -distance, tween);
			modManager.queueEase(step, step + time + 3, "transform2Y", distance, tween);
			modManager.queueEase(step, step + time, "transform3Y", -distance, tween);
		}
	});

	// THIRD

	numericForInterval(2848, 3168, 4, function(step) { // 3168
		counter2 = counter2 + 1;
		if (counter2 > 1) counter2 = 0;

		if (counter2 == 0)
		{
			modManager.queueEase(step, step + time2, "transform0Y", -distance, tween);
			modManager.queueEase(step, step + time2 + 1, "transform1Y", distance, tween);
			modManager.queueEase(step, step + time2, "transform2Y", -distance, tween);
			modManager.queueEase(step, step + time2 + 3, "transform3Y", distance, tween);
		}
		else
		{
			modManager.queueEase(step, step + time2 + 1, "transform0Y", distance, tween);
			modManager.queueEase(step, step + time2, "transform1Y", -distance, tween);
			modManager.queueEase(step, step + time2 + 3, "transform2Y", distance, tween);
			modManager.queueEase(step, step + time2, "transform3Y", -distance, tween);
		}
	});

	// EASING TO END

	modManager.queueSet(0, "tipsySpeed", 1.25);

	modManager.queueEase(1280, 1281, "transform0Y", 0, 'quadInOut');
	modManager.queueEase(1280, 1281, "transform1Y", 0, 'quadInOut');
	modManager.queueEase(1280, 1281, "transform2Y", 0, 'quadInOut');
	modManager.queueEase(1280, 1281, "transform3Y", 0, 'quadInOut');

	modManager.queueSet(1360, "tipsy", 0.25, 'expoInOut');
	modManager.queueSet(1616, "tipsy", 0, 'expoInOut');

	modManager.queueSet(2336, "tipsy", 0.25, 'expoInOut');
	modManager.queueSet(2592, "tipsy", 0, 'expoInOut');

	modManager.queueEase(3171, 3172, "transform0Y", 0, 'quadInOut');
	modManager.queueEase(3171, 3172, "transform1Y", 0, 'quadInOut');
	modManager.queueEase(3171, 3172, "transform2Y", 0, 'quadInOut');
	modManager.queueEase(3171, 3172, "transform3Y", 0, 'quadInOut');
}

function onStepHit() // too lazy to fix this
{
	if (curStep = 3218) FlxTween.tween(game.camHUD, {alpha: 0}, 0.6, {ease: FlxEase.quadOut});
}
