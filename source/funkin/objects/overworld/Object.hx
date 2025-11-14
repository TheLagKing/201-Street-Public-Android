package funkin.objects.overworld;

import flixel.FlxSprite;
import funkin.scripts.FunkinScript;

class Object extends FlxSprite
{
	public var name:String = '';
	public var dialogue:String = '';
	public var location:String = '';
	public var remove_outline:Bool = false;	
	public var script:FunkinScript;

	public function new(?name:String, x:Float = 0, y:Float = 0, image:String, scale:Float, ?dialogue:String, ?location:String, ?remove_outline:Bool)
	{
		super(x, y);
		
		final imageFilePath = FunkinScript.getPath('images/$image');
		
		loadGraphic(Paths.image(image));
		setGraphicSize(Std.int(width * scale));
		updateHitbox();
		antialiasing = false;

		this.name = name;
		this.dialogue = dialogue;
		this.location = location;
		this.remove_outline = remove_outline;

		final filePath = FunkinScript.getPath('images/$image');
		
		if (FunkinAssets.exists(filePath, TEXT)){
			script = FunkinScript.fromFile(filePath, name);
			if (script.__garbage)
			{
				script = FlxDestroyUtil.destroy(script);
				return;
			}
			callScriptFunc('onLoad', [this]);
		}
	}

	override function update(elapsed:Float){
		callScriptFunc('onUpdate', [this, elapsed]);
		super.update(elapsed);
	}

	public function callScriptFunc(func:String, ?params:Array<Dynamic>){
		if(script == null) return;
		if (script.exists(func)) script.call(func, params);
	}
}
