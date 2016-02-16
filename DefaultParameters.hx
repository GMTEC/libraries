package ;
import db.DBDefaults;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.events.Event;

/**
 * ...
 * @author GM
 */
class DefaultParameters
{
	public static var language:Int;
	public static var tweenTime:Float = 0.5;
	public static var BKGReactualizationTime:Int;
	public static var initializationTime:Int;
	public static var bkgInitializationTime:Int;
	public static var bkgMeasureTime:Int;
	public static var datagramsArrayLenght:Int = 600;
	public static var rateMeterBufferSize:Int = 4;
	public static var strLanguage:String;
	public static var dateFormat:String;
	public static var timeFormat:String;
	public static var paramMaximumControlTime:Int; // In Seconds
	public static var paramAlarmTimeout:Int;
	public static var paramErrorTimeout:Int;
	public static inline var paramEncryptionKey:String			= "nopasswordnopassnopasswordnopass";			
	public static var dateMonthFormat:String;

	public function new() 
	{
		Main.root1.addEventListener(PanelEvents.EVT_PARAM_UPDATED, refresh);
		refresh(null);
	}

	/**
	 * 
	 * @param	e
	 */
	private function refresh(e:Event):Void 
	{
		initializationTime			= DBDefaults.getIntParam(Parameters.paramInitializationTime);
		BKGReactualizationTime		= DBDefaults.getIntParam(Parameters.paramBKGReactualizationTime);
		datagramsArrayLenght		= DBDefaults.getIntParam(Parameters.paramAcquistionBufferLenght);
		language					= DBDefaults.getIntParam(Parameters.paramLanguage);
		dateFormat					= DBDefaults.getStringParam(Parameters.paramDateFormat);
		timeFormat					= DBDefaults.getStringParam(Parameters.paramTimeFormat);
		dateMonthFormat				= DBDefaults.getStringParam(Parameters.paramDateMonthFormat);
		bkgInitializationTime		= DBDefaults.getIntParam(Parameters.paramBKGMeasurementTime);
		paramMaximumControlTime		= DBDefaults.getIntParam(Parameters.paramMaximumControlTime);
		rateMeterBufferSize			= DBDefaults.getIntParam(Parameters.paramRateMeterBufferSize);
		//paramAlarmTimeout			= DBDefaults.getIntParam(Parameters.paramAlarmTimeout);
		//paramErrorTimeout			= DBDefaults.getIntParam(Parameters.paramErrorTimeout);
		bkgMeasureTime				= DBDefaults.getIntParam(Parameters.paramBKGMeasureTime);
	}

	/**
	 * 
	 * @param	languageID
	 * @return
	 */
	public static function getLanguage(languageID:Int):String 
	{
		switch languageID
		{
			case 0: return "Français";
			case 1: return "English";
			case 2: return "Nederlands";
			case 3: return "Deutsch";
		}

		return null;
	}
}