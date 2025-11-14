function onTransitioned()
{
	if (FlxG.save.data.overworldData.contains("ArrivedAtFestival") != true)
	{
		loadDialogue('arrive');
	}

	if (FlxG.save.data.overworldData.contains("SawBody") != true
		&& FlxG.save.data.songsBeaten.contains('dandadan')) FlxG.save.data.overworldData.push("CanSeeBody");
}
