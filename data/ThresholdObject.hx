package data;

import Array;
import Date;
import db.DBDefaults;
import enums.Enums.Parameters;
import flash.events.Event;
import flash.events.EventDispatcher;
import db.DBConfigChannels;
import events.PanelEvents;
import panelstatemachine.PanelStateMachine;
import db.DBLog;
import db.DBConfigChannels;

/**
 * ...
 * @author GM
 */
class PanelCounts
{
	public var date:Date;
	public var cps:Int;

	public function new(cpsIn:Int, dateIn:Date, countIn:Int = 0)
	{
		cps		= cpsIn;
		date	= dateIn;
	}
}

/**
 * 
 */
class ThresholdObject extends ConfigChannelData
{

	public var noise:Int;
	public var variance:Float;
	public var deviation:Float;
	public var thresholdCalculated:Int;
	public var threshold:Int;
	public var maximum:Int;
	public var minimum:Int;
	var busyDetected:Bool;
	private var _counter:Int;
	public var counterF:Int;
	static public inline var MAXINT:Int = 200000;

	/**
	 * Moving Average Data Array
	 */

	var average:Int;

	/**
	 * 
	 * @param	?addressIn
	 * @param	?channelIndex
	 * @param	?noiseIn
	 * @param	?triggerIn
	 */
	public function new(?addressIn:Int, ?channelIndex:Int, ?noiseIn:Int, ?triggerIn:Int) 
	{
		super(addressIn, channelIndex, noiseIn, triggerIn);

		datasArray 				= new Array<ChannelData>();
		resetMaximumAndMinimum();
	}
	
	/**
	 * 
	 */
	public function startNoiseMeasurement() 
	{
		//noiseStartPointer = datasArray.length;
	}

	/**
	 * 
	 */
	public function onSigmaModified() 
	{
		if (thresholdCalculated < 0)
			thresholdCalculated = threshold_high_during_init;

	}

	/**
	 * 
	 */
	public function resetMaximumAndMinimum()
	{
		maximum = 0;
		minimum = MAXINT;
	}

	function setFilteredCounter(value:Int):Int 
	{
		counterF = value;

		if (value < minimum && value > 0)
			minimum	= value;

		if (value > maximum)
			maximum	= value;

		return _counter;
	}

	function set_counter(value:Int):Int 
	{
		_counter = value;

		return _counter;
	}

	function get_counter():Int 
	{
		return _counter;
	}

	public var counter(get_counter, set_counter):Int;
	/**
	 * 
	 */
	public function calculateTriggerValueFromAverage(time:Int) 
	{
		//trace("calculateTriggerValueFromAverage");

		calculateAverageAndVariance(time);

		if (deviation < MinimumDeviation)
			deviation = MinimumDeviation;

		calculateTriggerValue();
	}

	public function calculateTriggerValue():Void
	{
		thresholdCalculated = noise + (cast deviation * sigma);
		//trace("calculateTriggerValue, sigma : " + sigma);
		//trace("calculateTriggerValue, trigger : " + trigger);

		onSigmaModified();
	}

	/**
	 * 
	 */
	public function calcSquareRootThreshold():Int
	{
		thresholdCalculated = Std.int(noise +  squareRoot * Math.sqrt(noise));
		onSigmaModified();
		//trace("calcSquareRootThreshold, trigger : " + trigger);

		return thresholdCalculated;
	}

	/**
	 * 
	 */
	public function calculateAverageAndVariance(time:Int, fromDB:Bool = false):PanelCounts
	{
		var diff:Int			= 0;
		var sum:Int 			= 0;
		var data:ChannelData	= null;
		var arrayLen:Int		= datasArray.length;
		var noiseEndPointer:Int;
		var noiseStartPointer:Int;

		if (fromDB)
		{
			noiseStartPointer 	= 0;
			noiseEndPointer		= arrayLen;
		}
		else
		{
			var lenUnused:Int 	= cast ((time - DefaultParameters.bkgMeasureTime) / 2);
			noiseStartPointer 	= arrayLen - lenUnused - DefaultParameters.bkgMeasureTime;
			noiseEndPointer		= noiseStartPointer + DefaultParameters.bkgMeasureTime;
		}

		if (noiseStartPointer < 0)
			noiseStartPointer = 0;

		var dataCount:Int 		= 0;

		for (i in noiseStartPointer ... noiseEndPointer)
		{
			counter = datasArray[i].counter;
			sum += counter;
			if (fromDB) setFilteredCounter(counter);
			dataCount ++;
		}

		//trace("noiseStartPointer 	: " + noiseStartPointer);
		//trace("noiseEndPointer 		: " + noiseEndPointer);
		//trace("dataCount 	: " + dataCount);
		//trace("sum 			: " + sum);
		//trace("noise 		: " + noise);
		noise 		= cast (sum / dataCount);
		variance 	= 0;

		for (i in noiseStartPointer ... noiseEndPointer)
		{
			diff = noise - datasArray[i].counter;
			variance += diff * diff;
		}

		variance = variance / dataCount;
		deviation = Math.sqrt(variance);

		if (sum == 0)
			return new PanelCounts(0, Date.now());

		var panelCounts:PanelCounts = null;

		panelCounts = new PanelCounts(noise, datasArray[arrayLen - 1].time);

		return panelCounts;
	}

	/**
	 * 
	 */
	function dumpArray() 
	{
		for (item in datasArray) {
			//trace("Item : " + item.cps);
		}
	}
}