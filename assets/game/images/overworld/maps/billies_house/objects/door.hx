function onLoad(object){
    if(FlxG.save.data.overworldData.contains("GotEarbuds") == false){
        object.location = null;
    }    
}