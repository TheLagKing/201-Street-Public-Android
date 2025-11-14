function onLoad(object)
{
	if (FlxG.save.data.overworldData.contains("GotEarbuds") == false)
	{
		object.dialogue = null;
	}
	else
	{
		if (FlxG.save.data.overworldData.contains("BoughtPendrive") == true && FlxG.save.data.songsBeaten.contains('herobrine') != true)
		{
			object.dialogue = 'herobrine_enter';
		}
		else
		{
			object.dialogue = 'pc';
		}
	}
}
