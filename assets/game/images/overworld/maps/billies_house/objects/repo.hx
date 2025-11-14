function onLoad(object){
    if(FlxG.save.data.overworldData.contains("BoughtTablet") != true || FlxG.save.data.songsBeaten.contains('repo')){
        object.visible = false;
        object.dialogue = null;
    }
}