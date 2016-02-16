package db;

import flash.data.SQLConnection;
import flash.media.Camera;
import org.aswing.util.HashMap;

/**
 * ...
 * @author GM
 */
class TriggerConditions
{
	public static var noTrigger	:Int		= 0;
	public static var onAlarm	:Int		= 1;
	public static var onReport	:Int		= 2;
	public static var onBusy	:Int		= 4;
	public static var onMotion	:Int		= 8;
}

/**
 * 
 */
class CameraData
{	
	public var Number			:Int;
	public var Name				:String;
	public var DetectionLevel	:Int;
	public var Timeout			:Int;
	public var MotionDetection	:Bool;
	public var Trigger			:Int;
	public var Use				:String;

	public function new(Name:String, MotionDetection:Bool, DetectionLevel:Int, Timeout:Int, trigger:Int = 0, use:String = "") 
	{
		this.Name				= Name;
		this.MotionDetection 	= MotionDetection;
		this.DetectionLevel 	= DetectionLevel;
		this.Trigger	 		= cast trigger;
		this.Use 				= use;
	}

	public function triggerOnBusy() 		: Bool { return cast Trigger & TriggerConditions.onBusy		;}
	public function triggerOnMotion() 		: Bool { return cast Trigger & TriggerConditions.onMotion	;}
	public function triggerOnAlarm() 		: Bool { return cast Trigger & TriggerConditions.onAlarm	;}

	public function setTriggerOnBusy(set:Bool) 		{ if (set) Trigger |= TriggerConditions.onBusy; 	else Trigger &= ~(TriggerConditions.onBusy) 	; }
	public function setTriggerOnMotion(set:Bool) 	{ if (set) Trigger |= TriggerConditions.onMotion; 	else Trigger &= ~(TriggerConditions.onMotion) 	; }
	public function setTriggerOnAlarm(set:Bool) 	{ if (set) Trigger |= TriggerConditions.onAlarm; 	else Trigger &= ~(TriggerConditions.onAlarm) 	; }
}

/**
 * 
 */
class DBCameras extends DBBase
{
	public static var camerasMap = new Map<Int, CameraData>();
	public static var connection:SQLConnection;
 
	function new():Void 
	{
		fName 		= DBBase.getConfigDataName();
		tableName	= "Cameras";

		super(true);

		getCamerasData();
	}

	/**
	 * 
	 * @param	index
	 * @return
	 */
	public static function getCameraData(index:Int):CameraData
	{
		var data = DBCameras.camerasMap.get(index);

		return (cast data) ? data : new CameraData(Camera.getCamera(cast index).name, false, 100, 2); // Default Values
	}

	/**
	 * 
	 * @param	channel
	 * @param	reportNumber
	 */
	public function getCamerasData ():Void
	{
		if (cast sqlResult.data)
		{
			for (data in sqlResult.data)
			{
				camerasMap.set(data.Number, new CameraData(data.Name, data.MotionDetection, data.DetectionLevel, data.Timeout, data.Alarm, data.Use));
			}
		}
 	}

	/**
	 * 
	 * @param	channel
	 * @param	channelData
	 */
	public function updateDetectionLevel(data:CameraData):Void
	{
		dbStatement.itemClass = CameraData;

		if(cast camerasMap.get(data.Number))
		{
			dbStatement.text =  ("UPDATE " + tableName +  " SET DetectionLevel = " + data.DetectionLevel +  ", Timeout = " + data.Timeout + ", Trigger = " + data.Trigger + " WHERE Number = " + data.Number + "");
		}
		else {
			dbStatement.text =  "INSERT INTO " + tableName + " values(" + data.Number + ",'" + data.Name + "'," + data.DetectionLevel + "," + data.Timeout + "," + data.Trigger + data.Use + ");";
		}

		camerasMap.set(data.Number, data);

		dbStatement.execute();
	}
}