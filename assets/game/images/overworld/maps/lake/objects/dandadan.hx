import funkin.states.OverworldState;

function onLoad(object){
    if(FlxG.save.data.songsBeaten.contains('dandadan')){
        object.visible = false;
    }
}