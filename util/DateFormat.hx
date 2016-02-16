package util;

import Date;
import util.DateTools;

/**
 * ...
 * @author GM
 */
class DateFormat
{
	/**
	 * 
	 * @param	date
	 */
	public static function getDateString(date:Date):String
	{
		return ((cast date) ? DateTools.format(date, "%D") : null);
	}

	public static function getDateMonthString(date:Date):String
	{
		return ((cast date) ? DateTools.format(date, "%a") : null);
	}

	/**
	 * 
	 * @param	date
	 */
	public static function getTimeString(date:Date, seconds:Bool = true):String
	{
		return ((cast date) ? DateTools.format(date, seconds ? "%H:%M:%S" :  "%H:%M") : null);
	}

}