function onLoad(object){
    if(FlxG.save.data.overworldData.contains("StreetMonotone")){
        object.visible = false;
    }
}