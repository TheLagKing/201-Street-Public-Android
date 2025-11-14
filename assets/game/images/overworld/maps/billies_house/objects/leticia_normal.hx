function onLoad(object)
{
	object.loadGraphic(Paths.image('overworld/maps/billies_house/objects/leticia_thinking'));
	if (!FlxG.save.data.overworldData.contains("GotEarbuds"))
	{
		object.visible = false;
		return;
	}
	if (FlxG.save.data.songsBeaten.contains('black-sea'))
	{
		object.loadGraphic(Paths.image('overworld/maps/billies_house/objects/leticia_normal'));
		object.dialogue = null;
		return;
	}
	if (FlxG.save.data.songsBeaten.length > 2)
	{
		object.loadGraphic(Paths.image('overworld/maps/billies_house/objects/leticia_normal'));
		if (FlxG.save.data.songsBeaten.contains('pink-sea'))
		{
			object.dialogue = 'dream_enter_again';
		}
		else object.dialogue = 'dream_enter';
	}
}
