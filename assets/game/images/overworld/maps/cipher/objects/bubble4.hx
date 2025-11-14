function onLoad(object){
    object.scrollFactor.set(1, 0.57);
}

function onUpdate(object, elapsed){
    object.angle += 0.08 * (60 * elapsed);
}