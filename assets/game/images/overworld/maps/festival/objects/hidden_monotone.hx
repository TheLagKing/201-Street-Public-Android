function onLoad(object){
    if(FlxG.save.data.overworldData.contains("TownMonotone")){
        object.visible = false;
    }
}