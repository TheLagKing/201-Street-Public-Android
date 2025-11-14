import funkin.states.OverworldState;

function onLoad(object){
    for(obj in OverworldState.instance.objects.members){
        if(obj.name == '...?' && obj.visible){
            object.loadGraphic(Paths.image('overworld/maps/lake/objects/signBodies'));
            object.dialogue = 'sign_bodies';
        }
    }
}