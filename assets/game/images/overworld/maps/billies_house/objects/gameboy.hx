function onLoad(object){
    if(FlxG.save.data.overworldData.contains("BoughtGameboy") != true || FlxG.save.data.songsBeaten.contains('pokemon')){
        object.visible = false;
        object.dialogue = null;
    }
}