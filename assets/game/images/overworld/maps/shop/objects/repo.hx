function onLoad(object){
    if(FlxG.save.data.overworldData.contains("BoughtTablet")){
        object.visible = false;
    }
    if(FlxG.save.data.overworldData.contains("MustReturn") != true){
        object.dialogue = null;
    }
}