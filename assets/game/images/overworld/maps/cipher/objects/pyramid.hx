var object_Y:Float;
var total_elapsed:Float;

function onLoad(object){
    object.scrollFactor.set(1, 0.4);

    object.frames = Paths.getSparrowAtlas('overworld/maps/cipher/objects/pyramid');
    object.animation.addByPrefix('spin', 'spin_', 7, true);
    object.animation.play('spin');

    object_Y = object.y;
    total_elapsed = FlxG.random.float(-2, 2);
}

function onUpdate(object, elapsed){
    total_elapsed = total_elapsed + Std.parseFloat(elapsed);
    object.y = object_Y + Math.sin(total_elapsed * 0.1) * 10;
}