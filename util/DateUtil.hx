package util;

import org.aswing.util.DateAs;
import util.DateFormat;

/**
 * ...
 * @author GM
 */
class DateUtil
{
	public static var millisecondsPerDay:Float = 1000 * 60 * 60 * 24;

	public function new() 
	{
	}
	
	public static function incrementDays(date:DateAs, inc:Int) : DateAs
	{
		date.setTime(date.getTime() + inc * millisecondsPerDay);
		
		return date;
	}

	public static function getStringDate(timeInIn:String) : String
	{
		return DateFormat.getDateString(getDate(timeInIn));
	}

	public static function getStringTime(timeInIn:String) : String
	{
		return DateFormat.getTimeString(getDate(timeInIn));
	}

	/**
	 * 
	 * @param	timeInIn
	 * @return
	 */
	public static function getDate(timeInIn:String) : Date
	{
		try{
			//trace("getDate : " + timeInIn);
			var strArray:Array<String> = Std.string(timeInIn).split(' ');
			var strdateArray:Array<String> = strArray[0].split('-');
			var strtimeArray:Array<String> = strArray[1].split(':');
			return new Date(Std.parseInt(strdateArray[0]), Std.parseInt(strdateArray[1]) - 1, Std.parseInt(strdateArray[2]), Std.parseInt(strtimeArray[0]), Std.parseInt(strtimeArray[1]), Std.parseInt(strtimeArray[2]));
			//trace("getDate : " + timeInIn);
		}
		catch (unknown : Dynamic )
		{
			trace("getDate throwing exception");
			return Date.now();
		}
	}
}