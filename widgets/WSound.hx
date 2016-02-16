package widgets;

import enums.Enums.PanelState;
import events.PanelEvents;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;
import sound.Sounds;

/**
 * ...
 * @author GM
 */
class WSound extends EventDispatcher
{
	var oldState:PanelState;
	var timerTimeoutRAAlarm:Timer;
	var timerTimeoutAlarm:Timer;
	var timerWarning:Timer;

	public function new() 
	{
		super();
	
		Main.root1.addEventListener(PanelEvents.EVT_WARNING_ON, onWarningON);
		Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_ON, onPlayRAAlarm);
		Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_OFF, OnStopRAAlarm);
		Main.root1.addEventListener(PanelEvents.EVT_ALARM_ON, onAlarmSet);
		Main.root1.addEventListener(PanelEvents.EVT_ALARM_OFF, onAlarmReset);
		Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_SOUND_ACK, OnStopRAAlarm);

		timerTimeoutRAAlarm = new Timer(DefaultParameters.paramAlarmTimeout * 1000, 1);
		timerTimeoutRAAlarm.addEventListener(TimerEvent.TIMER, OnStopRAAlarm);

		timerTimeoutAlarm = new Timer(DefaultParameters.paramErrorTimeout * 1000, 1);
		timerTimeoutAlarm.addEventListener(TimerEvent.TIMER, onAlarmReset);

		timerWarning = new Timer(2 * 1000, 1);
		timerWarning.addEventListener(TimerEvent.TIMER, stopWarning);
	}

	private function stopWarning(e:TimerEvent):Void 
	{
		Sounds.sndAlarm.stop();
		timerWarning.stop();
	}

	private function onWarningON(e:Event):Void 
	{
		trace("onWarningON");
		Sounds.sndAlarm.loop();
		timerWarning.start();
	}
	
	private function onAlarmReset(e:Event):Void 
	{
		stopAlarm(null);
	}

	private function onAlarmSet(e:Event):Void 
	{
		playAlarm();
	}

	function OnStopRAAlarm(e:Event) 
	{
		trace("stopRAAlarm Sound");
		Sounds.sndRAAlarm.stop();
		timerTimeoutRAAlarm.stop();
	}

	function onPlayRAAlarm(e:Event) 
	{
		trace("playRAAlarm Sound");
		Sounds.sndRAAlarm.loop();
		timerTimeoutRAAlarm.delay = DefaultParameters.paramAlarmTimeout * 1000;
		timerTimeoutRAAlarm.start();
	}

	function playAlarm() 
	{
		Sounds.sndAlarm.loop();
		timerTimeoutAlarm.delay = DefaultParameters.paramErrorTimeout * 1000;
		timerTimeoutAlarm.start();
	}

	function stopAlarm(e:Event) 
	{
		Sounds.sndAlarm.stop();
		timerTimeoutAlarm.stop();
	}

}