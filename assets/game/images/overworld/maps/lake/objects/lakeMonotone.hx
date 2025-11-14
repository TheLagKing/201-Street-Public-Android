function onLoad(object){
    if(FlxG.save.data.overworldData.contains("LakeMonotone")){
        object.visible = false;
    }
}