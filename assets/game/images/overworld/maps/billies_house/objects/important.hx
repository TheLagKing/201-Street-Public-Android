function onLoad(object){
    object.frames = Paths.getSparrowAtlas('overworld/maps/billies_house/objects/important');
    object.animation.addByPrefix('mark', 'mark', 4, true);
    object.animation.play('mark');

    object.visible = false;
    if(FlxG.save.data.songsBeaten.length > 2 && FlxG.save.data.songsBeaten.contains('black-sea') != true){
        object.visible = true;
    }
}