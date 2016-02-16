package widgets;

import events.PanelEvents;
import flash.display.JointStyle;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.BitmapFilter;
import org.aswing.ASColor;

/**
 * ...
 * @author GM
 */
class WAnalogClock extends WBase
{
	var wises		:Sprite;
	var clock		:Sprite;
	var center		:Sprite;
	var dX			:Int = 48;
	var radius1		:Int = 20;
	var radius2		:Int = 23;
	var radius3		:Int = 14;
	var centX		:Int;
	var centY		:Int;

	/**
	 * 
	 * @param	nameIn
	 * @param	filtersIn
	 */
	public function new(nameIn:String, filtersIn:Array<BitmapFilter>=null, ?dup = false) 
	{
		super(nameIn, filtersIn, dup);

		centX = centY = cast dX / 2;

		clock 			= new Sprite();
		wises 			= new Sprite();
		center 			= new Sprite();

		addChild(clock);
		addChild(wises);
		drawCenter();

		drawClock();

		Main.root1.addEventListener(PanelEvents.EVT_CLOCK, _drawWises);
		_drawWises();
	}

	/**
	 * 
	 * @param	name
	 */	
	public override function duplicate(name:String):WAnalogClock
	{
		trace("duplicateAnalogClock()");
		return new WAnalogClock(name, true);
	}

	/**
	 * 
	 */
	function drawCenter() 
	{
		addChild(center);
		var gfx = center.graphics;
		gfx.beginFill(ASColor.ALIZARIN.getRGB(), 1);
		gfx.drawCircle(centX, centY, 2);
	}
	/**
	 * 
	 */
	function drawClock()
	{
		var secAngle:Float;
		var minAngle:Float;
		var hourAngle:Float;
		var radians:Float;

		//just a movieClip that will hold the 3 arrows.
		var arrows:Sprite = new Sprite();

		//draws the basic chape of the clock. i chose the most borring colors for this -.-'
		var gfx = clock.graphics;
		//gfx.lineStyle(1, ASColor.CLOUDS.getRGB());
		//gfx.beginFill(ASColor.CLOUDS.getRGB(), 1);
		//gfx.drawCircle(centX, centY, centX);

		//puts a little line for every 6 degrees on the circle, which will add up to 60.
		//for(i in 0 ... 60){
			////this converts degrees to radians.
			//radians = i*6 * Math.PI/180;
//
			////draws a 10 pixel line, using sine, and cosine.
			//gfx.moveTo(Math.cos(radians) * radius1 + centX, Math.sin(radians) * radius1 + centY);
			//gfx.lineTo(Math.cos(radians) * radius2 + centX, Math.sin(radians) * radius2 + centY);
		//}

		//basicly the same, but for every 30 degrees, which ads up 12.
		gfx.lineStyle(3, ASColor.CLOUDS.getRGB());
		for(j in 0 ... 12){
			radians = j * 30 * Math.PI / 180;

			//make a thicker line to indicate hours.
			gfx.moveTo(Math.cos(radians) * radius1 + centX, Math.sin(radians) * radius1 + centY);
			gfx.lineTo(Math.cos(radians) * radius2 + centX, Math.sin(radians) * radius2 + centY);
		}
	}

	/**
	 * 
	 */
	function _drawWises(e:Event = null):Void 
	{
		var gfx = wises.graphics;
		gfx.clear();
		gfx.lineStyle(4, ASColor.CLOUDS.getRGB(), 1, false, JointStyle.ROUND);
		gfx.moveTo(centX, centX);

		var time:Date = Date.now();

		//Handle the hour arrow.
		var hours:Float = time.getHours() + time.getMinutes() / 60;
		var angle = (30*(hours - 15)) * Math.PI / 180; // Hour Angle
		gfx.lineTo(Math.cos(angle) * radius3 + centX, Math.sin(angle) * radius3 + centY);

		//Handle the min. arrow.
		angle = (6 *(time.getMinutes() - 15)) * Math.PI / 180; // Minutes Angle
		gfx.moveTo(centX, centX);
		gfx.lineTo(Math.cos(angle) * radius2 + centX, Math.sin(angle) * radius2 + centY);

		//Handle the sec. arrow.
		angle = (6 * (time.getSeconds() - 15)) * Math.PI / 180;
		gfx.lineStyle(1, ASColor.ALIZARIN.getRGB());
		gfx.moveTo(centX, centY);
		gfx.lineTo(Math.cos(angle) * radius2 + centX, Math.sin(angle) * radius2 + centY);
	}
}