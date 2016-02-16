package widgets;

import Date;
import DateTools;
import events.PanelEvents;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;
import org.aswing.geom.IntRectangle;
import org.aswing.JLabel;
import util.DateFormat;

/**
 * ...
 * @author GM
 */
class WTime extends WBase
{
	var dateText		:JLabel;
	var timeText		:JLabel;
	var timerSeconds	:Timer;

	public function new(name:String, wIn:Float, hin:Float) 
	{
		super(name);

		dateText 	= new JLabel();
		timeText 	= new JLabel();

		dateText.setBounds(new IntRectangle(10, 22, 140, 24));
		dateText.setAlignmentX(0.5);
		dateText.setFont(timeText.getFont().changeSize(12));
		addChild(dateText);

		timeText.setBounds(new IntRectangle(0, 0, 140, 32));
		dateText.setAlignmentX(0.5);
		timeText.setFont(timeText.getFont().changeSize(20));
		addChild(timeText);

		timerSeconds = new Timer(1000);
		timerSeconds.addEventListener(TimerEvent.TIMER, onTimer);

		timerSeconds.start();
	}

	/**
	 * 
	 * @param	e
	 */
	private function onTimer(e:Event):Void 
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_CLOCK)); // restart the BKG measurement
		var date:Date = Date.now();
		dateText.setText(DateFormat.getDateString(date));
		timeText.setText(DateTools.format(date, "%H:%M:%S"));
		//trace("Idle 			: " + NativeApplication.nativeApplication.timeSinceLastUserInput);
	}
}