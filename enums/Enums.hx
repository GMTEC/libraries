package enums;

/**
 * ...
 * @author GM
 */

class Files
{
	static public inline var LICENSE:String = "LicenseEN.html";
}

/**
 * 
 */
class Constants
{
}

/**
 * 
 */
class MinMax
{
	public var minValue:Float;
	public var maxValue:Float;

	public function new(?min:Float, ?max:Float):Void 
	{
		if (min == null)
			reset();
		else{
			minValue = min;
			maxValue = max;
		}
	}

	/**
	 * 
	 * @param	val
	 * @return
	 */
	public function setvalue(val:Float):Bool 
	{
		var modified:Bool = false;

		if (val < minValue)
			minValue = val; modified = true;

		if (val > maxValue)
			maxValue = val; modified = true;
			
		return modified;
	}

	/**
	 * 
	 * @param	min
	 * @param	max
	 */
	public function setMinMax(minMax:MinMax):Bool 
	{
		var modified:Bool = false;

		if (minMax.minValue < minValue)
			minValue = minMax.minValue; modified = true;

		if (minMax.maxValue > maxValue)
			maxValue = minMax.maxValue; modified = true;
			
		return modified;
	}

	public function rounded(object) : MinMax
	{
		minValue -= minValue % 100;
		maxValue -= maxValue % 100;

		return this;
	}
	
	public function reset() 
	{
		minValue = Math.POSITIVE_INFINITY;
		maxValue = 0;
	}
}

/**
 * 
 */
class Parameters
{
	public static var WIDTH_CENTERPANE:Int = 674;

	public static inline var paramInitializationTime:String		= "InitializationTime";			// Start Time to stabilize the hardware
	public static inline var paramHighThresholdDuringPortalFree:String = "HighThresholdDuringPortalFree";// Default Threshold During portal free

	public static inline var paramDetectionsBeforeAlarm:String	= "DetectionsBeforeAlarm";		// Detailled View Selected
	public static inline var paramTimeoutBeforeAlarm:String		= "TimeoutBeforeAlarm";			// Timeout retries before alarm is set
	public static inline var paramBKGMeasurementTime:String		= "BKGMeasurementTime";			// Detailled View Selected
	public static inline var paramAcquistionBufferLenght:String = "AcquistionBufferLenght";		// AcquistionBufferLenght in Seconds
	public static inline var paramBKGReactualizationTime:String	= "BKGReactualizationTime";		// After this period in ms if no busy detected, noise is computed again
	public static inline var paramRateMeterBufferSize:String	= "RateMeterBufferSize";		// Buffer Size

	public static inline var paramBusyDebounceTime:String		= "BusyDebounceTime";			// Busy signel debounce time in ms

	public static inline var paramComIO:String					= "ComIO";						// Serial Com IO
	public static inline var paramComArduino:String				= "ComArduino";					// Serial Com Arduino
	public static inline var paramComArduinoSpeed:String		= "ComArduinoSpeed";			// Serial Com Arduino
	public static inline var paramClientAddress:String			= "ClientAddress";				// UDp Address for remote control
	public static inline var paramServerAddress:String			= "ServerAddress";				// UDp Address for remote control
	public static inline var paramCalibrationDate:String		= "CalibrationDate";			// UDp Address for remote control

	public static inline var paramPollingTime:String			= "PollingTime";				// Detailled View Selected
	public static inline var paramDefaultFont:String			= "Font";						// Detailled View Selected
	public static inline var paramSimulatorMode:String			= "SimulatorMode";				// COM not opened, simulation only
	public static inline var paramHookMode:String				= "HookMode";					// Hook for component displacement
	public static inline var paramArduinoMode:String			= "ArduinoMode";				// Arduino for IOs
	public static inline var paramReportZoomFactor:String		= "ReportZoomFactor";			// Image Scaling for Report image
	public static inline var paramAutomaticAlarmAck:String		= "AutomaticAlarmAck";			// Automatic Alarm Reset with next truck

	public static inline var paramLoggingAll:String				= "LoggingAll";					// If 1: all traces are logged for Debug purpose

	public static inline var paramTime1ToBKG:String				= "Time1ToBKG";					// Time 1 for noise Measurement
	public static inline var paramTime2ToBKG:String				= "Time2ToBKG";					// Time 2 for noise Measurement
	public static inline var paramComIOTimeout:String			= "ComIOTimeout";				// Time 2 for noise Measurement

	public static inline var paramBackgroundColor:String		= "BackgroundColor";			// Time 2 for noise Measurement
	public static inline var paramKnockoutPanels:String			= "KnockoutPanels";				// Time 2 for noise Measurement

	public static inline var paramMeasuresXRange:String			= "MeasuresXRange";				// Plot X range in second
	public static inline var paramTrailerTime:String			= "TrailerTime";				// Time (in ms) recorded before portal Busy and after portal Free
	public static inline var paramAlarmTimeout:String			= "AlarmTimeout";				// Time (in S) for alarm Sound
	public static inline var paramErrorTimeout:String			= "ErrorTimeout";				// Time (in S) for error Sound
	public static inline var paramTestDuty:String				= "TestDuty";					// Time (in S) for error Sound
	public static inline var paramTestDelay:String				= "TestDelay";					// Time (in S) for error Sound

	public static inline var paramDateFormat:String				= "DateFormat";					// Language Date Format ex: %m/%d/%y
	public static inline var paramDateMonthFormat:String		= "DateMonthFormat";			// Language Date Format ex: %m/%d
	public static inline var paramTimeFormat:String				= "TimeFormat";					// Language Time Format ex: %H:%M:%S

	public static inline var paramLanguage:String				= "Language";					// Language french 0 English 1
	public static inline var paramPDFReport:String				= "PDFReport";					// Report created or not
	public static inline var paramInErrorAllowed:String			= "InErrorAllowed";				// Touch Screen mode Used
	public static inline var paramSigma:String					= "Sigma";						// Sigma Min. & Max.
	public static inline var paramThreshold:String				= "Threshold";					// Threshold Min. & Max.
	public static inline var paramSquareRoot:String				= "SquareRoot";					// SquareRoot Min. & Max.

	public static inline var paramServerMode:String				= "ServerMode";					// Server mode

	// Tray Options
	public static inline var paramShowOnTop:String				= "ShowOnTop";					// Show Widget always on top
	public static inline var paramWindowScaleX:String			= "WindowScaleX";				// Main Widget scale
	public static inline var paramWindowposX:String				= "WindowposX";					// Main Widget position
	public static inline var paramWindowposY:String				= "WindowposY";					// Main Widget position
	public static inline var paramWidgetposX:String				= "WidgetposX";					// Main Widget position
	public static inline var paramWidgetposY:String				= "WidgetposY";					// Main Widget position
	public static inline var paramWidgetSize:String				= "WidgetSize";					// Desktop Widget Size
	public static inline var paramSoundEnabled:String			= "SoundEnabled";				// All sounds enabled
	public static inline var paramAutoLogon:String				= "AutoLogon";					// AutoLogon enabled
	public static inline var paramDeviationMin:String			= "DeviationMin";				// Min. Deviation (1)

	public static inline var paramCameraIndex:String			= "CameraIndex";				// Camera Number
	public static inline var paramMaximumControlTime:String		= "MaximumControlTime";			// Maximum Control Time in seconds
	public static inline var paramProductID:String				= "ProductID";					// Product Validation Key
	public static inline var paramPrinterName1:String			= "PrinterName1";				// Printer Name
	public static inline var paramPrinterName2:String			= "PrinterName2";				// Printer Name
	public static inline var paramAutoPrintReport:String		= "AutoPrintReport";			// Automatic Report Print
	public static inline var paramAutoPDFReport:String			= "AutoPDFReport";				// Automatic PDF Report Generation
	public static inline var paramArduinoMessage:String			= "ArduinoMessage";				// Automatic Report Print
	public static inline var paramLastUser:String				= "LastUser";					// Last User logged In
	public static inline var paramBKGMeasureTime:String			= "BKGMeasureTime";				// Delay for BKG Measure
	public static inline var paramMinimumDeviation:String		= "MinimumDeviation";			// Minimum Deviation

	public static inline var paramAutoPrintReportPosPrt1:String	= "AutoPrintReportPosPrt1";		// 
	public static inline var paramAutoPrintReportNegPrt1:String	= "AutoPrintReportNegPrt1";		// 
	public static inline var paramAutoPrintReportPosPrt2:String	= "AutoPrintReportPosPrt2";		// 
	public static inline var paramAutoPrintReportNegPrt2:String	= "AutoPrintReportNegPrt2";		// 

	public static inline var paramReportsStartDate:String		= "ReportsStartDate";			// 
	public static inline var paramReportsEndDate:String			= "ReportsEndDate";				// 
	public static inline var paramReportsSelectedDate:String	= "ReportsSelectedDate";		// 
	public static inline var paramFrameRate:String				= "FrameRate";					// 
	public static inline var paramMinimumReportTime:String		= "MinimumReportTime";			// 
	static public inline var paramScaleEnabled:String			= "ScaleEnabled";				// Weight Scale

	static public inline var paramEULA:String					= "EULA";						// License read
}

/**
 * 
 */
class LanguageExt
{
	public static var languageCode:LanguageCode;
	public static inline var FRENCH:String	= "FRA";
	public static inline var ENGLISH:String	= "EN";

	static public function getLanguageExtension():String
	{
		if (languageCode ==  LanguageCode.FRENCH)
			return "FRA";
		else if (languageCode ==  LanguageCode.ENGLISH)
			return "EN";

		return "EN"; // default Language
	}
}

/**
 * 
 */
enum LanguageCode
{
	FRENCH;
	ENGLISH;
	DUTCH;
	GERMAN;
}

enum ReportResult
{
	NORMAL;
	ERROR;
	PENDING;
}

enum ThresholdMode
{
	SIGMA;
	SQUARE_ROOT;
	CONSTANT;
}

/**
 * 
 */
enum PanelState
{
	START;
	INIT;
	INIT_BUSY;
	INUSE;
	INUSE_BUSY;
	TEST;
	RA;
	RA_ACK;
	RA_BUSY;
	RA_BUSY_ACK;
	BKG_MEASURE;
	BKG_MEASURE_RA;
	BKG_MEASURE_BUSY;
	BKG_MEASURE_BUSY_RA;
	OUT;
	UNKNOWN;
	SPEED;
}

/**
 * 
 */
enum ChannelState
{
	OK;
	HIGH;
	LOW;
	BKG;
	ERROR;
	INRA;
	INIT;
	TIMEOUT;
	DISABLED;
}

/**
 * 
 */


class ErrorStates {
	static public var FALSE:Int				= 0;
	static public var TRUE:Int				= 1;
}

class ErrorSeverity {
	static public var INFORMATIONAL:Int				= 1;
	static public var WARNING:Int					= 2;
	static public var SEVERE:Int					= 3;
	static public var FATAL:Int						= 4;
}

class ErrorOrigin {
	static public var ORIGIN_STATE:Int				= 1;
	static public var ORIGIN_SERIAL:Int				= 2;
	static public var ORIGIN_IP:Int					= 3;
	static public var ORIGIN_FILE:Int				= 4;
	static public var ORIGIN_DB:Int				= 5;
}

class  ErrorCode
{
	static public var ERROR_SUCCESS:Int				= 1000;
	static public var ERROR_INVALID_DATA:Int 		= 1001;
	static public var ERROR_TIMEOUT:Int	 			= 1002;
	static public var ERROR_DEVICE_NOT_FOUND:Int 	= 1003;
	static public var ERROR_DATA_NOT_SEND:Int 		= 1004;
	static public var ERROR_DATA_CRC:Int	 		= 1005;
	static public var ERROR_DB:Int	 				= 1006;

	static public var MSG_REPORT_CREATED:Int		= 2000;
	static public var MSG_NOISE_MEASURE_START:Int	= 2001;
	static public var MSG_NOISE_MEASURE_DONE:Int	= 2002;
	static public var MSG_STATUS_CONTROLLING:Int	= 2003;
	static public var MSG_STARTING:Int				= 2004;
	static public var MSG_USER_LOGGING:Int			= 2005;
	static public var MSG_USER_QUIT:Int				= 2006;
	static public var MSG_RA_DETECTED:Int			= 2007;
	static public var MSG_CALIBRATION:Int			= 2008;
}

