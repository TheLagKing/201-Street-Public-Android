package funkin.objects.overworld;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.sound.FlxSound;

import funkin.vis.dsp.SpectralAnalyzer;

using Lambda;

// @:nullSafety
class VisualiserBars extends FlxTypedSpriteGroup<FlxSprite>
{
	// public var vis:VisShit;
	var analyzer:Null<SpectralAnalyzer> = null;
	
	var volumes:Array<Float> = [];
	
	public var snd:Null<FlxSound> = null;
	
	static final BAR_COUNT:Int = 7;

	var posY:Float = 125;
	var posY_array:Array<Float> = [10, 5, 2.5, 0, 1.5, 2.5, 3.5];

	// TODO: Make the sprites easier to soft code.
	public function new(snd:FlxSound, pixel:Bool)
	{
		super();
		
		this.snd = snd;
		
		var visScale = 1;
				
		// these are the differences in X position, from left to right
		
		for (i in 0...BAR_COUNT)
		{
			// pushes initial value
			volumes.push(0.0);
			
			// Sum the offsets up to the current index
			var sum = function(num:Float, total:Float) return total += num;
			var posX:Float = 35 + (i * 20);
			
			var viz:FlxSprite = new FlxSprite(posX, posY).makeGraphic(16, 1, 0xFF3c8282);
			viz.scale.set(visScale, visScale);
			viz.origin.set(Std.int(viz.width / 2), Std.int(viz.height));
			viz.angle = (((BAR_COUNT / 2) * -1) + (BAR_COUNT / BAR_COUNT) * i) * 4.5;
			viz.y += posY_array[i] * 4;
			add(viz);
		}
	}
	
	public function initAnalyzer():Void
	{
		if (snd == null) return;
		
		@:privateAccess
		analyzer = new SpectralAnalyzer(snd._channel.__audioSource, BAR_COUNT, 0.1, 40);
		// A-Bot tuning...
		analyzer.minDb = -65;
		analyzer.maxDb = -25;
		analyzer.maxFreq = 22000;
		// we use a very low minFreq since some songs use low low subbass like a boss
		analyzer.minFreq = 10;
		
		#if sys
		// On native it uses FFT stuff that isn't as optimized as the direct browser stuff we use on HTML5
		// So we want to manually change it!
		analyzer.fftN = 256;
		#end
		
		// analyzer.maxDb = -35;
		// analyzer.fftN = 2048;
	}
	
	public function dumpSound():Void
	{
		snd = null;
		analyzer = null;
	}
	
	var visTimer:Float = -1;
	var visTimeMax:Float = 1 / 30;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	static inline function min(x:Int, y:Int):Int
	{
		return x > y ? y : x;
	}
	
	override function draw()
	{
		super.draw();
		drawFFT();
	}
	
	/**
	 * TJW funkin.vis based visualizer! updateFFT() is the old nasty shit that dont worky!
	 */
	function drawFFT():Void
	{
		var levels = (analyzer != null) ? analyzer.getLevels() : getDefaultLevels();
		
		for (i in 0...min(group.members.length, levels.length))
		{
			group.members[i].scale.y = Std.int((levels[i].value + 0.37) * 90);
			// group.members[i].updateHitbox();
			// group.members[i].y = posY - group.members[i].height;
		}
	}
	
	/**
	 * Explicitly define the default levels to draw when the analyzer is not available.
	 * @return Array<Bar>
	 */
	static function getDefaultLevels():Array<Bar>
	{
		var result:Array<Bar> = [];
		
		for (i in 0...BAR_COUNT)
		{
			result.push({value: 0, peak: 0.0});
		}
		
		return result;
	}
}
