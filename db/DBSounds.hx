package db;

import flash.data.SQLConnection;
import org.aswing.util.HashMap;
import sound.SoundPlay;

/**
 * ...
 * @author GM
 */

class Brol
{

}

class SoundBaseData
{
	public var Key:String;
	public var FileName:String;
	public var Volume:Float;
	public var Min:Int;
	public var Max:Int;
	public var RepeatCount:Int;
	public var Enabled:Bool;
	public function new() {
		
	}
}

class SoundData extends SoundBaseData
{	
	public var soundPlay:SoundPlay;

	public function new(keyIn:String, filenamein:String, volumeIn:Float, minIn:Int, maxIn:Int, repeatCount:Int, enabledIn:Bool) 
	{
		super();
		Key			= keyIn;
		FileName	= filenamein;
		Volume		= volumeIn;
		Min			= minIn;
		Max			= maxIn;
		RepeatCount	= repeatCount;
		Enabled		= enabledIn;
	}
}

class DBSounds extends DBBase
{
	public static var soundsMap = new HashMap();
	public static var connection:SQLConnection;
 
	function new():Void 
	{
		soundsMap = new HashMap();
		fName 		= DBBase.getConfigDataName();
		tableName	= "SoundDefaults";

		super(true);

		getSoundsData();
	}

	/**
	 * 
	 * @param	channel
	 * @param	reportNumber
	 */
	public function getSoundsData ():Void
	{
		for (data in sqlResult.data)
		{
			soundsMap.set(data.Key, new SoundData(data.Key, data.FileName, data.Volume, data.Min, data.Max, data.RepeatCount, data.Enabled));
		}
 	}

	/**
	 * 
	 * @param	channel
	 * @param	channelData
	 */
	public function updateSoundData(soundData:SoundData):Void
	{		
		dbStatement.text =  ("UPDATE " + tableName + " SET Volume = '" + soundData.Volume + "' WHERE Key = '" + soundData.Key + "'");
		dbStatement.execute();
		dbStatement.text =  ("UPDATE " + tableName + " SET RepeatCount = '" + soundData.RepeatCount + "' WHERE Key = '" + soundData.Key + "'");
		dbStatement.execute();
	}
}