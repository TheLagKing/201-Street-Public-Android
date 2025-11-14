import funkin.states.OverworldState;

function onLoad(object){
    object.visible = false;
    
    var playedWeekly = FlxG.save.data.overworldData.contains('PlayedWeekly');
    if(playedWeekly){
        for(obj in OverworldState.instance.objects.members){
            if(obj.name == '...?' && obj.visible){
                obj.visible = false;
                object.visible = true;
            }
        }
    }
}