function onLoad(object){
    object.scrollFactor.set(1, 0.38);
}

function onUpdate(object, elapsed){
    object.angle -= 0.05 * (60 * elapsed);
}