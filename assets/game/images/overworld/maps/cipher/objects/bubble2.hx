function onLoad(object){
    object.scrollFactor.set(1, 0.7);
}

function onUpdate(object, elapsed){
    object.angle += 0.13 * (60 * elapsed);
}