function onLoad(object){
    if(FlxG.save.data.overworldData.contains("GotEarbuds") == false){
        object.dialogue = null;
    }    
    if(FlxG.save.data.overworldData.contains("BoughtTape") && FlxG.save.data.songsBeaten.contains('dhmis') != true){
        object.dialogue = 'dhmis_enter';
    }
}