function onLoad(object){
    if(FlxG.save.data.overworldData.contains("BoughtTape") != true || FlxG.save.data.songsBeaten.contains('dhmis')){
        object.visible = false;
        object.dialogue = null;
    }
}