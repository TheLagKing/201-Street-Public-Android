function onLoad(object){
    object.scrollFactor.set(1, 0.3);
}

function onUpdate(object, elapsed){
    object.angle += 0.1 * (60 * elapsed);
}