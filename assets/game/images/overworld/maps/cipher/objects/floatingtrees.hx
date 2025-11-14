var object_Y:Float;
var total_elapsed:Float;
function onLoad(object){
    object.scrollFactor.set(1, 0.4);

    object_Y = object.y;

    total_elapsed = FlxG.random.float(-2, 2);
}

function onUpdate(object, elapsed){
    total_elapsed = total_elapsed + Std.parseFloat(elapsed);
    object.y = object_Y + Math.sin(total_elapsed * 0.2) * 20;
}