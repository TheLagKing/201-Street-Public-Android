function onLoad(object){
    if(FlxG.save.data.overworldData.contains("BoughtPendrive") != true || FlxG.save.data.songsBeaten.contains('herobrine')){
        object.visible = false;
        object.dialogue = null;
    }
}