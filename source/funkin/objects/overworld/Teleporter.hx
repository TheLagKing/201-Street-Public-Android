package funkin.objects.overworld;

import flixel.FlxSprite;
import funkin.scripts.FunkinScript;

class Teleporter extends FlxSprite
{
	public var name:String = '';
	public var location:String = '';
	public var location_name:String = '';
	public var direction:String = '';
	public var script:FunkinScript;

	public function new(x:Float = 0, y:Float = 0, new_width:Int, new_height:Int, ?location:String, ?location_name:String, ?direction:String)
	{
		super(x, y);
		
		makeGraphic(new_width, new_height, FlxColor.RED);

		this.location = location;
		this.location_name = location_name;
		this.direction = direction;
		visible = false;
		// final filePath = FunkinScript.getPath('images/$image');
		
		// if (FunkinAssets.exists(filePath, TEXT)){
		// 	script = FunkinScript.fromFile(filePath, name);
		// 	if (script.__garbage)
		// 	{
		// 		script = FlxDestroyUtil.destroy(script);
		// 		return;
		// 	}
		// 	if (script.exists('onLoad')) 
		// 		script.call('onLoad', [this]);
		// }
	}
}
