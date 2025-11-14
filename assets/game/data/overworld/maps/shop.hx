var halloway_y:Float;
var current_expression:String = 'neutral';
var sign_y:Int = -60;

function onLoad()
{
	halloway_y = 0;
	for (obj in objects.members)
	{
		if (obj.name == 'Halloway')
		{
			halloway_y = obj.y;
		}
	}

	exit_sign = new FlxSprite(40, sign_y).loadGraphic(Paths.image('overworld/maps/shop/objects/exit_sign'));
	exit_sign.y -= exit_sign.height;
	add(exit_sign);
}

function onTransitioned()
{
	FlxTween.tween(exit_sign, {y: sign_y}, 1, {ease: FlxEase.quadOut});

	if (FlxG.save.data.overworldData.contains("FirstPurchase") != true)
	{
		loadDialogue('first_entrance');
	}
	else if (FlxG.save.data.overworldData.contains("MustReturn") && FlxG.save.data.overworldData.contains("ReturnedToShop") != true)
	{
		if (FlxG.save.data.songsBeaten.contains("dhmis")) loadDialogue('return_dhmis');
		else if (FlxG.save.data.songsBeaten.contains("herobrine")) loadDialogue('return_herobrine');
		else loadDialogue('return_gameboy');
	}
	else loadDialogue('normal_entrance');
}

function onDialogue(char, expression, dia)
{
	if (char == 'D. E. Halloway')
	{
		for (obj in objects.members)
		{
			if (obj.name == 'Halloway')
			{
				try
				{
					if (expression == current_expression) return;
					current_expression = expression;
					obj.loadGraphic(Paths.image('overworld/maps/shop/objects/halloway-' + expression));
					obj.y = halloway_y + 10;
					FlxTween.tween(obj, {y: halloway_y}, 0.3, {ease: FlxEase.quartOut});
				}
				catch (e:Exception)
				{
					trace('catch');
				}
			}
		}
	}
}

function onEndDialogue()
{
	for (obj in objects.members)
	{
		if (obj.name == 'Halloway')
		{
			try
			{
				if (current_expression == 'neutral') return;
				current_expression = 'neutral';
				obj.loadGraphic(Paths.image('overworld/maps/shop/objects/halloway-' + current_expression));
				obj.y = halloway_y + 10;
				FlxTween.tween(obj, {y: halloway_y}, 0.3, {ease: FlxEase.quartOut});
			}
			catch (e:Exception)
			{
				trace('catch');
			}
		}
	}
}

function onChangeMap(map_name)
{
	FlxTween.tween(exit_sign, {y: sign_y - exit_sign.height}, 0.5);

	for (tpr in teleporters.members)
	{
		tpr.kill();
	}

	loadDialogue('exit_shop');
}

function onDestroy()
{
	exit_sign.destroy();
}
