package error;

import db.DBTranslations;
import enums.Enums.ErrorCode;
import enums.Enums.ErrorOrigin;
import enums.Enums.ErrorSeverity;
import enums.Enums.ErrorStates;
import error.Errors.Error;
import error.Errors.ErrorInfo;
import events.PanelEvents;
import flash.events.Event;
import StringTools;

/**
 * ...
 * @author GM
 */

 
class ErrorInfo extends Error
{	
	public function new(errorCode:Int, paramIn:String = null, origin:Int = 0)
	{
		param = paramIn;
		origin = origin == 0? ErrorOrigin.ORIGIN_STATE : origin;
		super(errorCode, origin, ErrorStates.FALSE, ErrorSeverity.INFORMATIONAL, paramIn);
	}
}

class Error
{
	public var code:Int;
	public var origin:Int;
	public var status: Int;
	public var severity: Int;
	public var logMsg:String;
	public var param:String;
	public var time:Date;

	/**
	 * 
	 * @param	codeIn
	 * @param	originIn
	 * @param	statusIn
	 */
	public function new(codeIn:Int, originIn:Int, statusIn:Int, severityIn = 0, ?paramIn:String)
	{
		setError(codeIn, originIn, statusIn, severityIn, paramIn);
	}

	public function getLabelText():String 
	{
		var text:String = "";

		switch (code)
		{
			case ErrorCode.ERROR_DATA_CRC:				text = DBTranslations.getText("IDS_ERROR_DATA_CRC");
			case ErrorCode.ERROR_DEVICE_NOT_FOUND: 		text = DBTranslations.getText("IDS_ERROR_DEVICE_NOT_FOUND");
			case ErrorCode.ERROR_DATA_NOT_SEND: 		text = DBTranslations.getText("IDS_ERROR_DATA_CRC");
			case ErrorCode.ERROR_TIMEOUT:				text = DBTranslations.getText("IDS_ERROR_TIMEOUT");
			case ErrorCode.ERROR_SUCCESS:				text = DBTranslations.getText("IDS_ERROR_SUCCESS");
			case ErrorCode.ERROR_INVALID_DATA:			text = DBTranslations.getText(status == 0 ? "IDS_ERROR_VALID_DATA" : "IDS_ERROR_INVALID_DATA");
			case ErrorCode.ERROR_DB:					text = DBTranslations.getText("IDS_DB_ERROR");

			case ErrorCode.MSG_STARTING					:text = DBTranslations.getText("IDS_STARTING");
			case ErrorCode.MSG_REPORT_CREATED			:text = DBTranslations.getText("IDS_REPORT_CREATED");
			case ErrorCode.MSG_RA_DETECTED				:text = DBTranslations.getText("IDS_RA_DETECTED");
			case ErrorCode.MSG_NOISE_MEASURE_START		:text = DBTranslations.getText("IDS_NOISE_MEASURE_START");
			case ErrorCode.MSG_NOISE_MEASURE_DONE		:text = DBTranslations.getText("IDS_NOISE_MEASURE_DONE");
			case ErrorCode.MSG_STATUS_CONTROLLING		:text = DBTranslations.getText("IDS_STATUS_CONTROLLING");
			case ErrorCode.MSG_USER_LOGGING				:text = DBTranslations.getText("IDS_MSG_USER_LOGGING");
			case ErrorCode.MSG_USER_QUIT				:text = DBTranslations.getText("IDS_MSG_QUIT_PROGRAM");
			case ErrorCode.MSG_CALIBRATION				:text = DBTranslations.getText("IDS_MSG_CALIBRATION");
		}		

		if(param != null && text.indexOf("%1") > -1)
			return StringTools.replace(text, "%1", Std.string(param));
		else
			return text;
	}

	/**
	 * 
	 * @param	codeIn
	 * @param	originIn
	 * @param	statusIn
	 */
	public function setError(codeIn:Int, originIn:Int, statusIn:Int, severityIn = 0, ?paramIn:String) 
	{
		code		= codeIn;
		origin 		= originIn;
		status	 	= statusIn;
		severity	= severityIn;
		param 		= paramIn;
	}
}

/**
 * 
 */
class ErrorEvent extends Event
{
	public var error:Error;

	public function new(name:String, errorIn:Error)
	{
		error = errorIn;
	
		super(name);
	}
}

/**
 * 
 */
class Errors
{
	static var errorsMap = new Map <Int, Error> ();

	public static var portalInError:Bool;
	public static var portalInWarning:Bool;
	public static var managersInError:Int;
	public static var managersInWarning:Int;
	public static var comInError:Bool;
	public static var IPInError:Bool;
	public static var fileInError:Bool;

	/**
	 * 
	 */
	public function new() 
	{
		Main.root1.addEventListener(PanelEvents.EVT_ERROR_SET, OnErrorSet);
		Main.root1.addEventListener(PanelEvents.EVT_ERROR_ACK, OnErrorReset);
		Main.root1.addEventListener(PanelEvents.EVT_BKG_ELAPSED, onInitElapsed);
		Main.root1.addEventListener(PanelEvents.EVT_RESET_BKG, OnResetInitializationCounter);
		Main.root1.addEventListener(PanelEvents.EVT_RESET_INIT, OnResetInitializationCounter);
		Main.root1.addEventListener(PanelEvents.EVT_PORTAL_BUSY, onPortalBusy);
		Main.root1.addEventListener(PanelEvents.EVT_REPORT_CREATED, onReportCreated);
		Main.root1.addEventListener(PanelEvents.EVT_USER_LOGGING, onUserLogging);
		Main.root1.addEventListener(PanelEvents.EVT_APP_EXIT, OnExit);
	}

	private function onPortalBusy(e:Event):Void 
	{
		sendErrorInfoMessage(new ErrorInfo(ErrorCode.MSG_STATUS_CONTROLLING));
	}

	private function OnExit(e:Event):Void 
	{
		sendErrorInfoMessage(new ErrorInfo(ErrorCode.MSG_USER_QUIT, Session.getCurrentUserName()));
	}

	private function onReportCreated(e:ParameterEvent):Void 
	{
		sendErrorInfoMessage(new ErrorInfo(ErrorCode.MSG_REPORT_CREATED, e.parameter));
	}

	private function onUserLogging(e:ParameterEvent):Void 
	{
		sendErrorInfoMessage(new ErrorInfo(ErrorCode.MSG_USER_LOGGING, e.parameter));
	}

	private function OnResetInitializationCounter(e:Event):Void 
	{
		sendErrorInfoMessage(new ErrorInfo(ErrorCode.MSG_NOISE_MEASURE_START));
	}

	private function onInitElapsed(e:ParameterEvent):Void 
	{
		sendErrorInfoMessage(new ErrorInfo(ErrorCode.MSG_NOISE_MEASURE_DONE, e.parameter));
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnErrorSet(e:ErrorEvent):Void 
	{
		setError(e);
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnErrorReset(e:ErrorEvent):Void 
	{
		setError(e);
	}

	/**
	 * 
	 * @param	panetEvent
	 * @param	errorCode
	 */
	public static function dispatchError(panelEvent:String, origin:Int, errorCode:Int, errorState:Int, severity:Int, ?paramIn:String):Void
	{
		//trace("panelEvent : " + panelEvent + " origin : " + origin + " dispatchError : " + errorState + "Severity : "  + severity);

		var er:Error =  new Error(errorCode, origin, errorState, severity, paramIn);
		Main.root1.dispatchEvent(new ErrorEvent(panelEvent, er));
		sendErrorMessage(er);

	}

	/**
	 * 
	 */
	public static function sendErrorInfoMessage(er:ErrorInfo, param:String = null)
	{
		er.time 	= Date.now();
		er.logMsg 	= er.getLabelText();
		Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_MESSAGE_SET, er));
		Session.dbLog.logMessage(er);
	}

	/**
	 * 
	 */
	public static function sendErrorMessage(er:Error)
	{
		er.time = Date.now();
		Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_MESSAGE_SET, er));
		Session.dbLog.logMessage(er);
	}

	/**
	 * 
	 * @param	code
	 * @param	errorStatus
	 */
	function setError(e:ErrorEvent) 
	{
		var inError:Bool = portalInError;
		var inWarnig:Bool = portalInWarning;

		errorsMap.set(e.error.code, e.error);
		computeErrors();

		if (portalInError != inError) // Error State Changed
		{
			sendErrorMessage(e.error);
			playErrorSound();
		}

		if (portalInWarning != inWarnig) // Warning State Changed
		{
			sendErrorMessage(e.error);
		}

		Main.root1.dispatchEvent(new StateMachineEvent()); // new State refresh
	}

	/**
	 * 
	 */
	static function computeErrors()
	{
		managersInError = 0;
		managersInWarning = 0;

		for (error in errorsMap)
			setManagersErrors(error);
	}

	/**
	 * 
	 * @param	error
	 */
	static function setManagersErrors(error:Error) 
	{
		var state:Bool = error.status == ErrorStates.TRUE;
		var severe = error.severity == ErrorSeverity.SEVERE;
		var warning = error.severity == ErrorSeverity.WARNING;

		if (severe)
			managersInError += state ? 1 : 0;

		if (warning)
		{
			managersInWarning += state ? 1 : 0;

			if (state)
				Main.root1.dispatchEvent(new Event(PanelEvents.EVT_WARNING_ON));
		}

		switch(error.origin)
		{
			case ErrorOrigin.ORIGIN_SERIAL: comInError = state;
			case ErrorOrigin.ORIGIN_IP:		IPInError = state;
			case ErrorOrigin.ORIGIN_FILE:	fileInError = state;
			default:{}
		}

		if (portalInError != (managersInError > 0))
		{
			portalInError = !portalInError;
			//Session.panelStateMachine.stateModified();
		}

		portalInWarning = managersInWarning > 0;
	}

	/**
	 * 
	 */
	static function playErrorSound() 
	{
		Main.root1.dispatchEvent(new Event(portalInError ? PanelEvents.EVT_ALARM_ON : PanelEvents.EVT_ALARM_OFF));
	}

	/**
	 * 
	 * @param	state
	 */
	static function setFileManagerInError(state:Bool) 
	{
		if (fileInError != state)
		{
			playErrorSound();
			fileInError = state;
		}
	}
}