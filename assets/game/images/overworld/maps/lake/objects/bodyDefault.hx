import funkin.states.OverworldState;

function onLoad(object)
{
	object.visible = false;
	if (FlxG.save.data.overworldData.contains("SawBody") != true
		&& FlxG.save.data.songsBeaten.contains('dandadan')
		&& FlxG.save.data.overworldData.contains("CanSeeBody"))
	{
		object.visible = true;
	}
}
