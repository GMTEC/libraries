package util;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

/**
 * ...
 * @author GM
 */
class DebounceSignal extends EventDispatcher
{
	var signalEvent:String;
	var signalEventEnd:String;
	var timerDebounce:Timer;
	var timerCounter:Timer;
	public var debounced:Bool = true;
	var toShort:Bool = false;

	/**
	 * 
	 * @param	?debounceTime
	 */
	public function new(debounceTime:Int, signalResetEventIn:String,  signalEventIn:String, signalEndIn:String) 
	{
		super();

		signalEvent		 = signalEventIn;
		signalEventEnd	 = signalEndIn;

		if (debounceTime == 0)
			debounceTime = 1000;

		timerDebounce	= new Timer(debounceTime, 1); // Init Time
		timerCounter 	= new Timer(debounceTime, 1); // Init Time
		timerDebounce.addEventListener(TimerEvent.TIMER, onDebounceTimer);		
	}

	/**
	 * 
	 * @param	time
	 */
	public function setDebounceTime(delay:Int):Void 
	{
		timerDebounce.delay = delay;
		timerDebounce.reset();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onDebounceTimer(e:Event):Void 
	{
		//trace("onDebounceTimer, to Short : " + toShort);

		if (signalEvent != null)
			Main.root1.dispatchEvent(new Event(signalEvent));

		if (!toShort && (signalEventEnd != null))
		{
			Main.root1.dispatchEvent(new Event(signalEventEnd));
		}

		debounced = true;
	}

	/**
	 * Free Detected returns true if free without report to be created (time to short).
	 */
	public function setDebounce():Bool 
	{
		//trace("setDebounce()");
		toShort = false;

		if (timerCounter.running)
		{
			//trace("To Short!");
			timerDebounce.reset();
			toShort = true;
		}

		if (timerDebounce.running)
		{
			timerDebounce.reset();
		}

		timerDebounce.start();
		debounced = false;

		return toShort;
	}

	public function startDebounce():Void 
	{
		setDebounce();
	}

	public function stopDebounce():Void 
	{
		timerCounter.stop();
		timerDebounce.stop();
		debounced = false;
	}

	/**
	 * Busy Detected
	 */
	public function resetDebounce():Bool 
	{
		//trace("resetDebounce()");
		var ret:Bool = toShort;
		toShort = true;
		timerDebounce.reset();
		timerCounter.reset();
		timerCounter.start();

		return ret;
	}
}