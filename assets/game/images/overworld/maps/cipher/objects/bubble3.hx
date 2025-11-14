function onLoad(object){
    object.scrollFactor.set(1, 0.9);
}

function onUpdate(object, elapsed){
    object.angle -= 0.25 * (60 * elapsed);
}