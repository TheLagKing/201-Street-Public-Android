function onLoad(object){
    if(FlxG.save.data.overworldData.contains("OogaBooga")){
        object.dialogue = 'ooga_booga_alt';
    }
}