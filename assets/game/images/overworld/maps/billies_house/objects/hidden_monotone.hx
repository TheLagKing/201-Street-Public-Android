function onLoad(object){
    if(FlxG.save.data.overworldData.contains("HouseMonotone")){
        object.visible = false;
    }
}