function onLoad(object){
    if(FlxG.save.data.overworldData.contains("ShopMonotone")){
        object.visible = false;
    }
}