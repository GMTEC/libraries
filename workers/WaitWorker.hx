//package workers;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;
import util.Fading;
import util.Filters;
import util.Images;
import flash.system.Worker;

/**
 * ...
 * @author GM
 */
class WaitWorker extends Sprite
{
	var timerAnim:Timer;
	var bm1:Bitmap;
	var bm2:Bitmap;
	var toggle:Bool;

	public function new() 
	{
		super();

		//var supported:Bool = Worker.isSupported;

		//var worker:Worker = Worker.current;

		bm1 = Images.loadWait();
		bm2 = Images.loadWait();
		bm2.visible = false;

		if (true)
		{
			Images.resize(bm1, 64, 64);
			Images.resize(bm2, 64, 64);
		}

		bm1.filters = Filters.winFilters;
		bm2.filters = Filters.winFilters;
		//bm1.filters = Filters.glowFilters;
		//bm2.filters = Filters.glowFilters;
		addChild(bm1);
		addChild(bm2);

		timerAnim = new Timer(500); // Init Time
		timerAnim.addEventListener(TimerEvent.TIMER, onAnimate);
		timerAnim.start();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onAnimate(e:Event):Void 
	{
		Fading.fadeIn	(toggle ? bm2 : bm1, 1, 0.5);
		Fading.fadeOut	(toggle ? bm1 : bm2, 0, 0.5);
		toggle = !toggle;
		//bm1.visible = !bm1.visible;
		//bm2.visible = !bm2.visible;
	}
}