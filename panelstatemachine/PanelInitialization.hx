package panelstatemachine;

import error.Errors;
import events.PanelEvents;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;
import sound.Sounds;
import util.DebounceSignal;

/**
 * ...
 * @author GM
 */
class PanelInitialization extends Sprite
{
	static public var bkgRemainingTime:Int;
	var timerBKGTick:Timer;
	var strBKGInfo:String;
	public var autoThresholdComputing:DebounceSignal;

	/**
	 * 
	 */
	public function new() 
	{
		super();

		timerBKGTick = new Timer(1000); // Init Time
		timerBKGTick.addEventListener(TimerEvent.TIMER, onBKBTick);

		autoThresholdComputing = new DebounceSignal((DefaultParameters.BKGReactualizationTime) * 1000, PanelEvents.EVT_PORTAL_BUSY, null, PanelEvents.EVT_COMPUTE_NOISE);

		Main.root1.addEventListener(PanelEvents.EVT_RESET_FIRST_INIT, OnResetBKGCounter);
		Main.root1.addEventListener(PanelEvents.EVT_PORTAL_BUSY, onPortalBusy);
		Main.root1.addEventListener(PanelEvents.EVT_PORTAL_FREE, onPortalFree);		
		Main.root1.addEventListener(PanelEvents.EVT_COMPUTE_NOISE, onComputeNoise);
		Main.root1.addEventListener(PanelEvents.EVT_PARAM_UPDATED, refresh);
	}

	/**
	 * 
	 * @param	e
	 */
	private function refresh(e:Event):Void 
	{
		autoThresholdComputing.setDebounceTime(DefaultParameters.BKGReactualizationTime * 1000);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPortalFree(e:Event):Void 
	{
		onSetDebounce(null);

		if(timerBKGTick.running)
			OnResetBKGCounter(null);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPortalBusy(e:Event):Void 
	{
		onResetDebounce(null);
		stopBKGTime();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onSetDebounce(e:Event):Void 
	{
		autoThresholdComputing.setDebounce();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onResetDebounce(e:Event):Void 
	{
		autoThresholdComputing.resetDebounce();
	}

	/**
	 * 
	 * @param	e
	 */
	public function onComputeNoise(e:Event):Void 
	{
		if(!Session.panelStateMachine.inRAAlarmToAck)
			computeThreshold(DefaultParameters.BKGReactualizationTime);

		autoThresholdComputing.setDebounce();
	}

	/**
	 * 
	 * @return
	 */
	function computeThreshold(time:Int):Void
	{
		strBKGInfo = "";

		for (channel in Session.channelsArray)
		{
			channel.computeThreshold(time);
			strBKGInfo += channel.label + ":" + channel.threshold + ",";
		}
		strBKGInfo = strBKGInfo.substr(0, strBKGInfo.length - 2); 
	}

	/**
	 * 
	 * @return
	 */
	function decrementInitTime():Bool
	{
		if (Session.panelStateMachine.firstBKGInit)
			Sounds.playBKGClic();

		if (--bkgRemainingTime == 0)
		{
			stopBKGTime();

			computeThreshold(DefaultParameters.bkgInitializationTime);
			Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_BKG_ELAPSED, strBKGInfo));
			autoThresholdComputing.setDebounce();
		}

		Main.root1.dispatchEvent(new StateMachineEvent());

		return true;
	}

	/**
	 * 
	 */
	public function stopBKGTime():Void 
	{
		//trace("timerInitTime.stop()");
		timerBKGTick.stop();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onBKBTick(e:Event):Void 
	{
		if (bkgRemainingTime > 0 && !Errors.portalInError)
		{
			if (Session.panelStateMachine.getPortalBusy())
				OnResetBKGCounter(null);
			else
				decrementInitTime();
		}
		else
		{
			stopBKGTime();
		}
	}

	/**
	 * 
	 * @param	e
	 */
	public function OnResetBKGCounter(e:Event):Void 
	{
		bkgRemainingTime = DefaultParameters.bkgInitializationTime; // Looping back the time;
		timerBKGTick.start();

		for (channel in Session.channelsArray)
			channel.startNoiseMeasurement();

		Main.root1.dispatchEvent(new StateMachineEvent());
	}
	
}