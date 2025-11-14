function onLoad(object){
    if(FlxG.save.data.overworldData.contains("BoughtGameboy")){
        object.visible = false;
    }
    if(FlxG.save.data.overworldData.contains("FirstPurchase") && FlxG.save.data.overworldData.contains("MustReturn") != true){
        object.dialogue = null;
    }
}