package db;

import data.DataObject;
import data.ThresholdObject;
import flash.data.SQLConnection;
import flash.data.SQLResult;
import org.aswing.ASColor;

/**
 * ...
 * @author GM
 */
class ChannelData extends ThresholdObject
{
 	// Table Structure :
	public var ID : 			Int;
	var _status : 		Int;
	public var reportNumber : 	Int;
	public var channelNumber : 	Int;
	public var radioActivity : 	Int;
    public var time : 			Date;

	/**
	 * 
	 * @param	dataIn
	 * @param	statusIn
	 * @param	reportNumberIn
	 * @param	noiseIn
	 * @param	thresholdIn
	 * @param	radioActivityIn
	 * @param	timeIn
	 */
	public function new()
	{
		super();
	}
/**
 * 
 * @param	dataIn
 * @param	statusIn
 * @param	reportNumberIn
 * @param	noiseIn
 * @param	thresholdIn
 * @param	radioActivityIn
 * @param	timeIn
 */
	public function setValues(
		counterIn:Int,
		statusIn:Int,
		reportNumberIn:Int,
		noiseIn:Int,
		thresholdIn:Int,
		radioActivityIn:Int,
		deviationIn:Int,
		timeIn:Date)

	{
		time				= timeIn;
		status				= statusIn;
		reportNumber		= reportNumberIn;
		noise				= noiseIn;
		thresholdCalculated				= thresholdIn;
		radioActivity		= radioActivityIn;
		deviation			= deviationIn;
		counter				= counterIn;
	}
	
	private function set_status(value:Int):Int 
	{
		return _status = value;
	}
		
	private function get_status():Int 
	{
		return _status;
	}
	
	public var status(get_status, set_status):Int;
}

class ConfigChannelData
{
    public var address : Int;
    public var channelIndex : Int;
    public var noise_default : Int;
    public var noise_factory : Int;
    public var threshold_low  : Int;
    public var threshold_high : Int;
    public var Detections : Int;
    public var Smoothing : Int;
	public var MinimumDeviation:Int;
    public var threshold_high_during_init : Int;
    public var display_time : Int;
    public var position : String;
    public var enabled : Bool;
    public var inErrorAllowed : Bool;
    //public var savedTrigger : Int;
    //public var savedNoise : Int;
    public var sigma : Int;
    public var squareRoot : Int;
	public var datasArray:Array<ChannelData>;

	public function new(addressIn:Int, channelIndexIn:Int, noiseIn:Int, triggerIn:Int) 
	{
		//trace("new ConfigChannelData : " + addressIn);

		address 		= addressIn;
		channelIndex 	= channelIndexIn;
	}
	
	public function getAddress():String
	{
		return Std.string(address);
	}
}

/**
 * 
 */
class DBChannelsDefaults extends DBBase
{
	public var connection:SQLConnection;
	public var channelsPattern:Int;

	function new():Void 
	{
		fName 		= DBBase.getConfigDataName();
		tableName	= "ChannelDefaults";

		super();

		getConfigChannelsDefaults();
 	}		

	public function getConfigChannelsDefaults():Void
	{
		dbStatement.clearParameters();
		dbStatement.text =  ("SELECT * FROM " + tableName);

		dbStatement.execute();
		var sqlResult:SQLResult = dbStatement.getResult();

		for (row in sqlResult.data)
		{
			var dao = new DataObject(row.address, row.IndexChan, row.noise, row.trigger);

			dao.label 						= row.Label;
			dao.sigma 						= row.Sigma;
			dao.squareRoot 					= row.SquareRoot;
			dao.noise_factory 				= row.noise_factory;
			dao.noise_default 				= row.noise_default;
			dao.sigma 						= row.sigma;
			dao.threshold_low 				= row.threshold_low;
			dao.threshold_high				= row.threshold_high;
			dao.threshold_high_during_init 	= row.threshold_high_during_init;
			dao.display_time 				= row.display_time;
			dao.position 					= row.position;
			dao.enabled 					= row.enabed;
			dao.thresholdMeasured 			= row.ThresholdMeasured;
			dao.thresholdFixed 				= row.ThresholdFixed;
			dao.thresholdMode 				= row.ThresholdMode;
			dao.plotColor					= new ASColor(row.PlotColor);
			dao.inErrorAllowed 				= row.InErrorAllowed;
			dao.Detections 					= row.Detections;
			dao.Smoothing 					= row.Smoothing;
			dao.MinimumDeviation 			= row.MinimumDeviation;

			dao.refreshMeasureMode();

			if (true)
			{
				if (row.IndexChan > 0)
				{
					Session.channelsArray.set(dao.getAddress(), dao);
					channelsPattern |= 1 << dao.channelIndex - 1;
				}
				else
					Session.IOsArray.set(dao.getAddress(), dao);
			}
			dao.enabled = true;
		}
	}

	/**
	 * 
	 * @param	name
	 * @return
	 */
	public static function getConfigChannel(address:Int):DataObject
	{
		for (channel in Session.channelsArray)
		{
			if (channel.address == address)
				return channel;
		}

		return null;
	}

	/**
	 * 
	 * @param	channel
	 */
	public function updateConfigChannelTable(dao:DataObject):Void
	{
		dbStatement.clearParameters();

		dbStatement.text = ("UPDATE " + tableName + " SET noise = '" + dao.noise + "', threshold = '"

			+ dao.thresholdCalculated + "', ThresholdFixed = '"
			+ dao.thresholdFixed + "', ThresholdMeasured = '"
			+ dao.thresholdMeasured + "', sigma = '"
			+ dao.sigma + "', SquareRoot = '"
			+ dao.squareRoot + "', ThresholdMode = '"
			+ dao.thresholdMode + "' WHERE address = '" + dao.address + "'");

		dbStatement.execute();

		dao.refreshMeasureMode(true);
	}

	/**
	 * 
	 * @param	channel
	 */
	public function updateConfigChannelLabel(indexIn:Int, labelIn:String):Void
	{
		var dao = new DataObject();

		dbStatement.clearParameters();
		dbStatement.text =  ("UPDATE " + tableName + " SET Label = '" + labelIn + "' WHERE IndexChan = '" + indexIn + "'");

		dbStatement.execute();
	}

	/**
	 * 
	 * @param	channel
	 */
	public function updateSmooting(label:String, smoothing:Int):Void
	{
		var dao = new DataObject();

		dbStatement.clearParameters();
		dbStatement.text =  ("UPDATE " + tableName + " SET Smoothing = '" + smoothing + "' WHERE Label = '" + label + "'");

		dbStatement.execute();
	}

	/**
	 * 
	 * @param	channel
	 */
	public function updateDetections(label:String, detections:Int):Void
	{
		dbStatement.clearParameters();
		dbStatement.text =  ("UPDATE " + tableName + " SET Detections = '" + detections + "' WHERE Label = '" + label + "'");

		dbStatement.execute();
	}

	/**
	 * 
	 * @param	channel
	 */
	public function updateEnabled(label:String, enabledIn:Bool):Void
	{
		dbStatement.clearParameters();
		dbStatement.text =  ("UPDATE " + tableName + " SET enabled = '" + enabledIn + "' WHERE Label = '" + label + "'");

		dbStatement.execute();
	}

	/**
	 * 
	 * @param	channel
	 */
	public function updateMinimumDeviation(label:String, detections:Int):Void
	{
		dbStatement.clearParameters();
		trace("detections : " + detections);
		dbStatement.text =  ("UPDATE " + tableName + " SET MinimumDeviation = '" + detections + "' WHERE Label = '" + label + "'");

		dbStatement.execute();
	}
}
