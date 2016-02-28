package events;

import flash.events.Event;
import Main;
import enums.Enums;

/**
 * ...
 * @author GM
 */

class PanelEvents
{
	// Events:

	public static inline var EVT_PANEL_STATE:String			= "EVT_PANEL_STATE";	// Panel State Change
	public static inline var EVT_DATA_REFRESH:String		= "EVT_DATA_REFRESH";	// panel Data Changig
	public static inline var EVT_IO_REFRESH:String			= "EVT_IO_REFRESH";		// panel I/O Changig
	public static inline var EVT_ALARM_ON:String			= "EVT_ALARM_ON";		// Error Alarm Set
	public static inline var EVT_ALARM_OFF:String			= "EVT_ALARM_OFF";		// Error Alarm Reset
	public static inline var EVT_WARNING_ON:String			= "EVT_WARNING_ON";		// Warning Set
	public static inline var EVT_RA_ALARM_ON:String			= "EVT_RA_ALARM_ON";	// Radio Activity Alarm Set
	public static inline var EVT_RA_ALARM_OFF:String		= "EVT_RA_ALARM_OFF";	// Radio Activity Alarm Reset
	public static inline var EVT_RA_ALARM_ACK:String		= "EVT_RA_ALARM_ACK";	// Radio Activity Alarm Reset
	public static inline var EVT_RA_ALARM_SOUND_ACK:String	= "EVT_RA_ALARM_SOUND_ACK";	// Radio Activity Alarm Reset
	public static inline var EVT_LANGUAGE_CHANGE:String		= "EVT_LANGUAGE_CHANGE";	// Language Change
	public static inline var EVT_REMOTING_INITIALIZED:String= "EVT_REM_OK";				// Remoting dtabases read
	public static inline var EVT_GET_PAGES:String			= "EVT_GET_PAGES";				// Remoting dtabases read

	public static inline var EVT_BUSY_DEBOUNCED:String		= "EVT_BUSY_DEBOUNCED";	// Debounce message for portal detection delay

	public static inline var EVT_APP_EXIT:String			= "EVT_APP_EXIT";		// Exit from the application (closing dbs, coms, ...

	public static inline var EVT_SIMUL_SLIDER:String		= "EVT_SIMUL_SLIDER";	// Simulator Slider value
	public static inline var EVT_SIMUL_DATA:String			= "EVT_SIMUL_DATA"; 	// Simulator value
	public static inline var EVT_SERIAL_DATA:String			= "EVT_SERIAL_DATA"; 	// Serial value
	public static inline var EVT_PORTAL_BUSY:String			= "EVT_PORTAL_BUSY";	// Portal busy (beam closed)
	public static inline var EVT_PORTAL_FREE:String			= "EVT_PORTAL_FREE"; 	// Simulator value (beam open)
	public static inline var EVT_CREATE_REPORT:String		= "EVT_CREATE_REPORT"; 	// Simulator value (beam open)
	public static inline var EVT_BKG_ELAPSED:String			= "EVT_INIT_ELAPSED";	// Time Elapsed for initialization
	public static inline var EVT_RESET_INIT:String			= "EVT_RESET_INIT";		// Time Elapsed for initialization
	public static inline var EVT_RESET_BKG:String			= "EVT_RESET_BKG";		// Time Elapsed for initialization
	public static inline var EVT_COMPUTE_NOISE:String		= "EVT_COMPUTE_NOISE";		// Compute Noise Again
	public static inline var EVT_RESET_FIRST_INIT:String	= "EVT_RESET_FIRST_INIT";	// Time Elapsed for first initialization
	public static inline var EVT_PARKING_ERROR:String		= "EVT_PARKING_ERROR";	// portal Busy During Initialization
	public static inline var EVT_REPORT_CREATED:String		= "EVT_REPORT_CREATED";	// Report created
	public static inline var EVT_USER_LOGGING:String		= "EVT_USER_LOGGING";	// User Logged In

	public static inline var EVT_GREEN_LIGHT:String			= "EVT_GREEN_LIGHT";	// green Lamp
	public static inline var EVT_RED_LIGHT:String			= "EVT_RED_LIGHT";		// red Lamp
	public static inline var EVT_RED_ORANGE:String			= "EVT_ORANGE_LIGHT";	// orange Lamp

	public static inline var EVT_CLOCK:String				= "EVT_CLOCK";			// Clock
	public static inline var EVT_ON_SHOW:String				= "EVT_ON_SHOW";		// A new Window is showed;
	public static inline var EVT_PARAM_UPDATED:String		= "EVT_PARAM_UPDATED";	// A parameter is updated in the database;
	public static inline var EVT_COM_ON:String				= "EVT_COM_ON";			// Communication established;
	public static inline var EVT_COM_OFF:String				= "EVT_COM_OFF";		// Communication finished;

	/**
	 * Errors
	 */
	public static inline var EVT_ERROR_ACK:String			= "EVT_ERROR_ACK";		// error Set
	public static inline var EVT_ERROR_SET:String			= "EVT_ERROR_SET";		// error Reset
	public static inline var EVT_MESSAGE_SET:String			= "EVT_MESSAGE_SET";	// Message Sent
	public static inline var EVT_LOG:String					= "EVT_LOG";			// Error Log

	public static inline var EVT_SQL_SEARCH_DLG:String		= "EVT_SQL_SEARCH_DLG";	// SQL Search Dialog
	public static inline var EVT_SQL_SEARCH:String			= "EVT_SQL_SEARCH";		// SQL Search String

	// Buttons
	public static inline var EVT_PANE_MEASURES:String		= "EVT_PANE_MEASURES";		// Detailled View Selected
	public static inline var EVT_PANE_MONITOR:String		= "EVT_PANE_MONITOR";		// Main View Selected
	public static inline var EVT_PANE_REPORT:String			= "EVT_PANE_REPORT";		// Report View Selected
	public static inline var EVT_PANE_HISTORY:String		= "EVT_PANE_HISTORY";		// History View Selected
	public static inline var EVT_PANE_LOG:String			= "EVT_PANE_LOG";			// Log Book View Selected
	public static inline var EVT_PANE_USERS:String			= "EVT_PANE_USERS";			// Users View Selected
	public static inline var EVT_PANE_HELP:String			= "EVT_PANE_HELP";			// Help invoked
	static public inline var EVT_PANE_EXIT_DLG:String 		= "EVT_PANE_EXIT_DLG";		// Exit Dialog Invoked
	static public inline var EVT_PANE_SETTINGS:String 		= "EVT_PANE_SETTINGS";		// Settings Dialog
	static public inline var EVT_PANE_PREVIOUS:String 		= "EVT_PANE_PREVIOUS";		// Previous View
	static public inline var EVT_PANE_CHANGE:String 		= "EVT_PANE_CHANGE";		// Other View
	static public inline var EVT_START_DRAG:String 			= "EVT_START_DRAG";			// Other View
	static public inline var EVT_STOP_DRAG:String 			= "EVT_STOP_DRAG";			// Other View
	static public inline var EVT_RIGHT_MOUSE_UP:String 		= "EVT_RIGHT_MOUSE_UP";		// Other View

	// Test Mode
	public static inline var EVT_TEST_MODE_ON:String		= "EVT_TEST_MODE_ON";		// Test Mode On
	public static inline var EVT_TEST_MODE_OFF:String		= "EVT_TEST_MODE_OFF";		// Test Mode Off
	public static inline var EVT_SHORT_SIREN:String			= "EVT_SHORT_SIREN";		// Short Siren for busy alarm
	public static inline var EVT_ABOUT:String				= "EVT_ABOUT";				// About Message
	static public inline var EVT_START_MEASURE:String		= "evtStartMeasure";		// reset Buffer position
	static public inline var EVT_WIN_REFRESH:String 		= "evtWinRefresh";			// Window Position and Scale refresh
	static public inline var PRINT_REPORT:String 			= "printReport";
	static public inline var EVT_IMAGES_LOADED:String 		= "evtImagesLoaded";
	static public inline var EVT_PANE_CAM:String 			= "evtViewCam";
	static public inline var EVT_BUT_CAM_ZOOM:String 		= "evtButCamZoom";
	static public inline var EVT_LICENSE_OK:String 			= "evtLicenseOk";
	static public inline var EVT_VIEW_REPORT:String 		= "evtViewReport";
	static public inline var EVT_PROXY_CONNECTED:String 	= "EVT_PROXY_CONNECTED";
	static public inline var EVT_BACK_COLOR_CHANGED:String 	= "evtBackColorChanged";

	static public inline var EVT_ALPR_DETECTED:String 		= "EVT_ALPR_DETECTED";

	public function new() 
	{
	}
}

/**
 * 
 */
class ParameterEvent extends Event
{
	public var parameter:Dynamic;

	public function new(name:String, param:Dynamic)
	{
		parameter = param;
	
		super(name);
	}
}
/**
 * 
 */
class StateMachineEvent extends Event
{
	public var stateMachine:PanelState;

	public function new()
	{
		stateMachine		= PanelState.INIT;
		super(PanelEvents.EVT_PANEL_STATE);
	}

}