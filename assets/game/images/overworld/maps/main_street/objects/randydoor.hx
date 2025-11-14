function onLoad(object){
    if(FlxG.save.data.songsBeaten.contains('ghostface'))
        object.dialogue = null;
}