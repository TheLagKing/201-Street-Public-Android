function onLoad(object){
    if(FlxG.save.data.overworldData.contains("GotEarbuds")){
        object.visible = false;
        object.dialogue = null;
    }    
}