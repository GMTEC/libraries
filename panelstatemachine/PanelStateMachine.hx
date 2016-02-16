package panelstatemachine ;

import data.DataObject;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.ChannelState;
import enums.Enums.ErrorCode;
import enums.Enums.ErrorStates;
import enums.Enums.PanelState;
import enums.Enums.Parameters;
import error.Errors;
import events.PanelEvents;
import flash.display.Bitmap;
import flash.events.Event;
import flash.utils.Timer;
import haxe.Timer;
import org.aswing.ASColor;
import sound.Sounds;
import panelstatemachine.PanelInitialization;
import util.DebounceSignal;
import util.Images;
import sprites.SpriteNuclear;

/**
 * ...
 * @author GM
 */
typedef StatusStateParam = { state:PanelState, label:String, color:ASColor, textColor:Int, logoFunction:Void->Dynamic, signalFunction:Void->Dynamic };
typedef ChannelStateParam = { state:ChannelState, label:String, color:ASColor, textColor:Int, logo:Bitmap, signal:Bitmap };

class StateColor
{
	public static var backColorInStart:ASColor;
	public static var backColorInInit:ASColor;
	public static var backColorInInitBusy:ASColor;
	public static var backColorInInUse:ASColor;
	public static var backColorInControlling:ASColor;
	public static var backColorInTest:ASColor;
	public static var backColorInRAAlarm:ASColor;
	public static var backColorInBKG:ASColor;
	public static var backColorInOUT:ASColor;
	public static var backColorInUnknown:ASColor;
	public static var backColorInSpeed:ASColor;
}

/**
 * 
 */
class PanelStateMachine extends StateMachine
{
	public var portalInitializing:Bool;
	public var firstBKGInit:Bool = true;
	public var statusStateArray:Array<StatusStateParam>;
	public var countersStateArray:Array<ChannelStateParam>;
	public var manualAlarmSoundAckwowledged:Bool;

	public var allChannelInitialized:Bool;
	private var _portalBKGMeasurement:Bool;
	public var allChannelsOUT:Bool = true;

	public var timeFree:Date;
	public var timeBusy:Date;
	var speedToHigh:Bool;

	var _portalOut:Bool; // Set
	var _portalInTest:Bool; // Set
	var _portalControlling:Bool;
	var _portalFailure:Bool;
	var portalBusyDebouceSignal:DebounceSignal;
	var previousAlarmsNotAcknowledged:Int;
	var paramAutomaticAlarmAck:Bool;
	public var alarmsRADetected:Int;
	public var channelsinRAAlarmToAcknowledged:Int;
	public var inRAAlarm:Bool;

	/**
	 * 
	 */
	public function new() 
	{
		super();

		statusStateArray 		= new Array <StatusStateParam>();
		countersStateArray 		= new Array <ChannelStateParam>();

		initColors();
		createPortalStatusBitmaps();
		createCountersStatusBitmaps();
		portalBusyDebouceSignal = new DebounceSignal(DBDefaults.getIntParam(Parameters.paramBusyDebounceTime), PanelEvents.EVT_PORTAL_BUSY, PanelEvents.EVT_BUSY_DEBOUNCED, PanelEvents.EVT_CREATE_REPORT);

		paramAutomaticAlarmAck 	= DBDefaults.getBoolParam(Parameters.paramAutomaticAlarmAck);
		panelInitialization 	= new PanelInitialization();

		Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_ACK, onRAAlarmAcknowledge);
		Main.root1.addEventListener(PanelEvents.EVT_RA_ALARM_SOUND_ACK, onRAAlarmSoundAcknowledge);
		Main.root1.addEventListener(PanelEvents.EVT_BKG_ELAPSED, onBKGElapsed);
		Main.root1.addEventListener(PanelEvents.EVT_RESET_FIRST_INIT, OnInitDone);
		Main.root1.addEventListener(PanelEvents.EVT_RESET_BKG, OnStartFirstBKGMeasurement);
		Main.root1.addEventListener(PanelEvents.EVT_RESET_INIT, OnStartFirstBKGMeasurement);
		Main.root1.addEventListener(PanelEvents.EVT_DATA_REFRESH, onDataRefresh);
		Main.root1.addEventListener(PanelEvents.EVT_BUSY_DEBOUNCED, onPortalFree);
		Main.root1.addEventListener(PanelEvents.EVT_COMPUTE_NOISE, onNoiseComputed);
		Main.root1.addEventListener(PanelEvents.EVT_COM_ON, startStateMachine);

		Main.root1.addEventListener(PanelEvents.EVT_BKG_ELAPSED, onNoiseComputed);
		Main.root1.addEventListener(PanelEvents.EVT_START_MEASURE, onStartMeasure);

		startStateMachine(null);
		Errors.sendErrorInfoMessage(new ErrorInfo(ErrorCode.MSG_STARTING));
	}

	/**
	 * 
	 */
	public function startStateMachine(e:Event):Void 
	{
		portalInitializing		= true;
		stateMachine 			= PanelState.INIT;
		panelInitialization.stopBKGTime();

		if (e != null)
			haxe.Timer.delay(onInitTimeElapsed, DefaultParameters.initializationTime); // Init Time

		stateModified();
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnErrorSet(e:ErrorEvent):Void 
	{
		if (e.error.code == ErrorCode.ERROR_TIMEOUT)
		{
			if (e.error.status == ErrorStates.TRUE)
			{
			}
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function onStartMeasure(e:Event):Void 
	{
		for (channel in Session.channelsArray)
		{
			channel.onStartMeasure();
		}
	}

	private function onNoiseComputed(e:Event):Void 
	{
		for (channel in Session.channelsArray) { channel.onNoiseComputed(); }		
		Session.dbHistory.onNoiseComputed();
	}

	/**
	 * 
	 * @param	e
	 */
	private function OnResetBKGMeasure(e:Event):Void 
	{
		for (channel in Session.channelsArray)
		{
			channel.OnResetBKGMeasure();
		}		
	}

	/**
	 * 
	 * @param	e
	 */
	private function onDataRefresh(e:ParameterEvent):Void 
	{
		if (e.parameter == "DATA")
		{
			//trace("IOStatus : " + Session.IOStatus);
			setPortalBusy(Session.IOTestStatus ?  true : Session.IOStatus != 3);
		}	
	}

	/**
	 * 
	 */
	function initColors() 
	{
		var alpha:Float = 1;

		StateColor.backColorInInit = new ASColor(ASColor.CLOUDS.getRGB(), alpha);
		StateColor.backColorInInitBusy = new ASColor(ASColor.CLOUDS.getRGB(), alpha);
		StateColor.backColorInInUse = new ASColor(ASColor.EMERALD.getRGB(), alpha);
		StateColor.backColorInControlling = new ASColor(ASColor.ORANGE.getRGB(), alpha);
		StateColor.backColorInTest = new ASColor(ASColor.SUN_FLOWER.getRGB(), alpha);
		StateColor.backColorInRAAlarm = new ASColor(ASColor.ALIZARIN.getRGB(), alpha);
		StateColor.backColorInStart = new ASColor(ASColor.CLOUDS.getRGB(), alpha);
		StateColor.backColorInBKG = new ASColor(ASColor.BELIZE_HOLE.getRGB(), alpha);
		StateColor.backColorInOUT = new ASColor(ASColor.ALIZARIN.getRGB(), alpha);
		StateColor.backColorInUnknown = new ASColor(ASColor.CLOUDS.getRGB(), alpha);
		StateColor.backColorInSpeed = new ASColor(ASColor.AMETHYST.getRGB(), alpha);
	}

	/**
	 * 
	 * @param	label
	 * @param	color
	 * @param	bitmap
	 */
	function addState(stateIn:PanelState, label:String, colorIn:ASColor, colTextIn:Int, logoFunctionIn:Void->Dynamic, signalFunctionIn:Void->Dynamic)
	{
		//trace("Adding : " + label);
		var state:StatusStateParam = { state:stateIn, label : DBTranslations.getText(label), color : colorIn, textColor: colTextIn, logoFunction : logoFunctionIn, signalFunction:signalFunctionIn };
		statusStateArray.push(state);
	}

	/**
	 * 
	 * @param	label
	 * @param	color
	 * @param	bitmap
	 */
	function addCounterState(stateIn:ChannelState, label:String, colorIn:ASColor, colTextIn:Int, ?bitmap:Bitmap, ?signalBM:Bitmap)
	{
		//trace("Adding : " + label);
		var state:ChannelStateParam = { state:stateIn, label : DBTranslations.getText(label), color : colorIn, textColor: colTextIn, logo : bitmap, signal:signalBM };
		countersStateArray.push(state);
	}

	/**
	 * create the Portal status Bitmaps
	 */
	function createPortalStatusBitmaps():Void
	{
		//trace("*******************  createStatusBitmaps");

		var spriteNuclear:SpriteNuclear 	= new SpriteNuclear();
		var spriteNuclearTop:SpriteNuclear	= new SpriteNuclear(true);

		addState(PanelState.START, 				"IDS_STATUS_START", 			StateColor.backColorInStart, 		ASColor.MIDNIGHT_BLUE.getRGB(), Images.loadStop, 							Images.loadSignalRed);
		addState(PanelState.INIT,				"IDS_STATUS_INIT", 				StateColor.backColorInInit, 		ASColor.MIDNIGHT_BLUE.getRGB(), Images.loadStop, 							Images.loadSignalRed);
		addState(PanelState.INIT_BUSY,			"IDS_STATUS_INIT_BUSY", 		StateColor.backColorInInitBusy, 	ASColor.MIDNIGHT_BLUE.getRGB(), Images.loadtruckWhite, 						Images.loadSignalRed);
		addState(PanelState.INUSE,				"IDS_STATUS_WAITING_CONTROL", 	StateColor.backColorInInUse, 		ASColor.MIDNIGHT_BLUE.getRGB(), Images.loadGo, 								Images.loadSignalGreen);
		addState(PanelState.INUSE_BUSY,			"IDS_STATUS_CONTROLLING", 		StateColor.backColorInControlling, 	ASColor.MIDNIGHT_BLUE.getRGB(), Images.loadtruckGreen, 						Images.loadSignalRed);
		addState(PanelState.TEST,				"IDS_STATUS_TEST", 				StateColor.backColorInTest, 		ASColor.CLOUDS.getRGB(), Images.loadGo, 								Images.loadSignalRed);
		addState(PanelState.RA,					"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInRAAlarm, 		ASColor.CLOUDS.getRGB(), Images.loadNuclear, 						Images.loadSignalRed);
		addState(PanelState.RA_ACK,				"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInRAAlarm, 		ASColor.CLOUDS.getRGB(), Images.loadNuclear,							Images.loadSignalRed);
		addState(PanelState.RA_BUSY,				"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInRAAlarm, 		ASColor.CLOUDS.getRGB(), Images.loadtruckRed, 						Images.loadSignalRed);
		addState(PanelState.RA_BUSY_ACK,			"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInRAAlarm, 		ASColor.CLOUDS.getRGB(), Images.loadtruckRed,  						Images.loadSignalRed);
		addState(PanelState.BKG_MEASURE,			"IDS_STATUS_BKG", 				StateColor.backColorInBKG, 			ASColor.CLOUDS.getRGB(), Images.loadStop, 							Images.loadSignalRed);
		addState(PanelState.BKG_MEASURE_RA,		"IDS_STATUS_RADIOACTIVITY",		StateColor.backColorInRAAlarm, 		ASColor.CLOUDS.getRGB(), Images.loadNuclear,						Images.loadSignalRed);
		addState(PanelState.BKG_MEASURE_BUSY,	"IDS_STATUS_BKG_BUSY", 			StateColor.backColorInBKG, 			ASColor.CLOUDS.getRGB(), Images.loadtruckBlue, 						Images.loadSignalRed);
		addState(PanelState.BKG_MEASURE_BUSY_RA,	"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInRAAlarm, 		ASColor.CLOUDS.getRGB(), Images.loadtruckRed,					 	Images.loadSignalRed);
		addState(PanelState.OUT,					"IDS_STATUS_OUT", 				StateColor.backColorInOUT, 			ASColor.CLOUDS.getRGB(), Images.loadStop, 							Images.loadSignalRed);
		addState(PanelState.UNKNOWN,				"IDS_STATUS_UNKNOWN", 			StateColor.backColorInUnknown, 		ASColor.MIDNIGHT_BLUE.getRGB(), Images.loadGo, 								Images.loadSignalRed);
		addState(PanelState.SPEED,				"IDS_STATUS_SPEED", 			StateColor.backColorInSpeed, 		ASColor.CLOUDS.getRGB(), Images.loadInitBusy, 								Images.loadSignalRed);
	}

	/**
	 * create the Portal status Bitmaps
	 */
	function createCountersStatusBitmaps():Void
	{
		//trace("*******************  createStatusBitmaps");

		addCounterState(ChannelState.OK, 				"IDS_STATUS_START", 			StateColor.backColorInInUse, 		ASColor.MIDNIGHT_BLUE.getRGB());
		addCounterState(ChannelState.HIGH,				"IDS_STATUS_INIT", 				StateColor.backColorInOUT, 			ASColor.MIDNIGHT_BLUE.getRGB());
		addCounterState(ChannelState.LOW,				"IDS_STATUS_INIT_BUSY", 		StateColor.backColorInOUT, 			ASColor.MIDNIGHT_BLUE.getRGB());
		addCounterState(ChannelState.BKG,				"IDS_STATUS_WAITING_CONTROL", 	StateColor.backColorInBKG, 			ASColor.CLOUDS.getRGB());
		addCounterState(ChannelState.ERROR,				"IDS_STATUS_CONTROLLING", 		StateColor.backColorInOUT,			ASColor.CLOUDS.getRGB());
		addCounterState(ChannelState.INRA,				"IDS_STATUS_TEST", 				StateColor.backColorInOUT, 			ASColor.CLOUDS.getRGB());
		addCounterState(ChannelState.INIT,				"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInInit, 		ASColor.MIDNIGHT_BLUE.getRGB());
		addCounterState(ChannelState.TIMEOUT,			"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInOUT, 			ASColor.CLOUDS.getRGB());
		addCounterState(ChannelState.DISABLED,			"IDS_STATUS_RADIOACTIVITY", 	StateColor.backColorInOUT, 			ASColor.CLOUDS.getRGB());
	}

	/**
	 * 
	 * @param	e
	 */
	private dynamic function onInitTimeElapsed()
	{
		//trace("onInitTimeElapsed");
		portalInitializing = false;
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_RESET_FIRST_INIT)); // Init Done
	}

	/**
	 * 
	 */
	public override function stateModified(value:PanelState = null)
	{
		var nextState:PanelState = PanelState.UNKNOWN;

		if (Errors.portalInError)
		{
			nextState = PanelState.OUT;
		}
		else
		{
			if (portalInitializing)
				nextState = _portalBusy ? PanelState.INIT_BUSY : PanelState.INIT;
			else
				if(firstBKGInit)
				{
					nextState = isInNotAckAlarm() ? (_portalBusy ? PanelState.BKG_MEASURE_BUSY_RA : PanelState.BKG_MEASURE_RA) : (_portalBusy ? PanelState.BKG_MEASURE_BUSY : PanelState.BKG_MEASURE);

					if (inRAAlarm)
						panelInitialization.stopBKGTime();
					else
						panelInitialization.OnResetBKGCounter(null);
				}
				else
					nextState = isInNotAckAlarm() ? (_portalBusy ? PanelState.RA_BUSY : inRAAlarmToAck ? PanelState.RA_ACK : PanelState.RA) : (_portalBusy ? PanelState.INUSE_BUSY : PanelState.INUSE);
			if (speedToHigh) nextState = PanelState.SPEED;
		}

		//trace("Next State 		: " + nextState);
		//trace("Portal In error 	: " + Errors.portalInError);
		_stateMachine = nextState;
		_portalInUse = 
			stateMachine == PanelState.INUSE ||
			stateMachine == PanelState.INUSE_BUSY  ||
			stateMachine == PanelState.RA_BUSY  ||
			stateMachine == PanelState.RA;
		super.stateModified(nextState);
	}

	/**
	 * 
	 */
	public function restartBKGMeasurement()
	{
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_RESET_BKG)); // restart the BKG measurement
	}

	/**
	 * 
	 * @param	e
	 */
	private function onRAAlarmAcknowledge(e:Event):Void 
	{
		trace("===========onRAAlarmAcknowledge==============");

		if (portalBKGMeasurement)
			restartBKGMeasurement();

		panelInitialization.autoThresholdComputing.startDebounce();

		inRAAlarmToAck = false;
		speedToHigh = false;
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_RA_ALARM_OFF)); // Init Done

		for (channel in Session.channelsArray)
		{
			channel.onRAAlarmAcknowledge();
		}

		stateModified();
	}
	
	public function isInNotAckAlarm():Bool 
	{
		return inRAAlarmToAck || inRAAlarm;
	}

	/**
	 * 
	 * @param	e
	 */
	private function onRAAlarmSoundAcknowledge(e:Event):Void 
	{
		manualAlarmSoundAckwowledged = true;
	}

	public function isInitialized():Bool 
	{
		return stateMachine.getIndex() > PanelState.INIT_BUSY.getIndex();
	}

	/**
	 * 
	 * @return
	 */
	public function isAlarmManualAckEnabled():Bool
	{
		return inRAAlarmToAck;
	}

	/**
	 * 
	 * @param	alarmsAcknowledged
	 */
	public function changeInRAAlarmsDetected(alarmsRADetectedIn:Int, channelsinRAAlarmToAcknowledgedIn:Int) 
	{
		alarmsRADetected 					= alarmsRADetectedIn;
		channelsinRAAlarmToAcknowledged 	= channelsinRAAlarmToAcknowledgedIn;
		//trace("changeInRAAlarmsDetected :  " + alarmsRADetected);

		inRAAlarm = alarmsRADetectedIn > 0;

		if (inRAAlarm)
		{
			if (!inRAAlarmToAck)
			{
				Main.root1.dispatchEvent(new Event(PanelEvents.EVT_RA_ALARM_ON)); // Init Done
				inRAAlarmToAck = true;
			}

			var strInfo:String = "";

			for (channel in Session.channelsArray)
			{
				strInfo += channel.label + ': ' + channel.maximum + ', ';
			}
			strInfo = strInfo.substr(0, strInfo.length - 2);
		
			Errors.sendErrorInfoMessage(new ErrorInfo(ErrorCode.MSG_RA_DETECTED, strInfo));
		}

		stateModified();
	}

	/**
	 * 
	 * @param	e
	 */
	function OnInitDone(e:Event):Void 
	{
		portalInitializing = false;
		OnResetBKGMeasure(null);
		OnStartFirstBKGMeasurement(null);
	}

	/**
	 * 
	 * @param	e
	 */
	function OnStartFirstBKGMeasurement(e:Event):Void 
	{
		firstBKGInit = true;
		OnResetBKGMeasure(null);
		stateModified();
	}

	/**
	 * 
	 * @param	alarms
	 */
	public function isInRAAlarmAndBusy() : Bool
	{
		return isInRAAlarm() && _portalBusy;
	}

	public function isRAAlarmAckEnabled():Bool 
	{
		return inRAAlarmToAck && (alarmsRADetected == 0);
	}

	/**
	 * 
	 * @param	alarms
	 */
	public function isInRAAlarm() : Bool
	{
		return inRAAlarmToAck || inRAAlarm;
	}

	/**
	 * 
	 * @return
	 */
	public function initTimeDecrementAllowed() : Bool
	{
		if (allChannelsOUT || isInRAAlarm() || inRAAlarmToAck)
		{
			return false;
		}

		return !Errors.portalInError;
	}

	/**
	 * 
	 * @return
	 */
	function allChannelsInitialized(param:Dynamic):Bool
	{
		for (channel in Session.channelsArray)
		{
			if (!channel.channelInitialized)
				return false;
		}

		return true;
	}

	/**
	 * 
	 * @param	e
	 */
	private function onBKGElapsed(e:ParameterEvent):Void 
	{
		//trace("onBKGElapsed stateMachine : " + stateMachine);

		firstBKGInit = false;

		if(portalBKGMeasurement)
		{
			if(true)
			{
				allChannelInitialized = true;

				//onNoiseComputed(null);

				if (stateMachine == PanelState.INUSE)
					Sounds.onInitElapsed();
			}
		}

		stateModified();
	}

	/**
	 * Beam closed
	 * @param	e
	 */
	private function onPortalFree(e:Event):Void 
	{
		timeFree = Date.now();
		trace("onPortalFree : " + timeFree);
		setSpeedAlarm();

		Sounds.onPortalFree();

		stateModified();
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PORTAL_FREE));
	}

	/**
	 * 
	 */
	function setSpeedAlarm() 
	{
		var duty:Float = (timeFree.getTime() - timeBusy.getTime() - DefaultParameters.paramTrailerTime);

		speedToHigh = duty < DefaultParameters.paramMinimumReportTime;

		if (speedToHigh) {
			Main.root1.dispatchEvent(new Event(PanelEvents.EVT_ALARM_ON));
		}
		stateModified();

		trace("Duty : " + duty);
	}

	/**
	 * Beam opened
	 * @param	e
	 */
	private function onPortalBusy():Void 
	{
		timeBusy = Date.now();
		trace("onPortalBusy : " + timeBusy);
		Sounds.onPortalBusy();
		stateModified();
	}

	/**
	 * 
	 * @return
	 */
	function get_portalInUse():Bool 
	{
		return _portalInUse;
	}

	public var portalInUse(get_portalInUse, null):Bool;

	/**
	 * 
	 * @return
	 */
	function get_portalControlling():Bool 
	{
		_portalControlling = _portalBusy && !portalBKGMeasurement && !Errors.portalInError;

		return _portalControlling;
	}

	public var portalControlling(get_portalControlling, null):Bool;

	function get_portalOut():Bool 
	{
		_portalOut = stateMachine == PanelState.OUT;

		return _portalOut;
	}

	public var portalOut(get_portalOut, null):Bool;

	/**
	 * 
	 * @return
	 */
	function get_portalInTest():Bool 
	{
		_portalInTest = stateMachine == PanelState.TEST;

		return _portalInTest;
	}

	/**
	 * 
	 */
	public var portalInTest(get_portalInTest, null):Bool;

	/**
	 * 
	 * @return
	 */
	function get_portalBKGMeasurement():Bool 
	{
		_portalBKGMeasurement = (_stateMachine.getIndex() >= PanelState.BKG_MEASURE.getIndex()) && (_stateMachine.getIndex() <= PanelState.BKG_MEASURE_BUSY_RA.getIndex());

		return _portalBKGMeasurement;
	}

	public var portalBKGMeasurement(get_portalBKGMeasurement, null):Bool;
	/**
	 * 
	 * @return
	 */
	function get_portalFailure():Bool 
	{
		_portalFailure = stateMachine == PanelState.OUT;

		return _portalFailure;
	}

	public var portalFailure(get_portalFailure, null):Bool;

	/**
	 * 
	 * @return
	 */
	public function getPortalBusy():Bool 
	{
		return _portalBusy;
	}

	/**
	 * 
	 * @param	busy
	 * @return
	 */
	public function setPortalBusy(busy:Bool): Void // pulses coming here
	{
		//trace("setPortalBusy : " + busy);

		if (busy != _portalBusy)
		{
			busy ? busyDetected() : freeDetected();

			if (busy)
			{
				stateModified();

				if (portalBusyDebouceSignal.debounced)
				{
					Sounds.onPortalBusy();
					Main.root1.dispatchEvent(new Event(PanelEvents.EVT_START_MEASURE, true));
					Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PORTAL_BUSY, true));
					resetErrorIfAutomaticAlarmAck();
				}
			}
		}
	}

	/**
	 * 
	 */
	function freeDetected() 
	{
		trace("freeDetected");
		_portalBusy = false;
		Sounds.onPortalBusy();

		portalBusyDebouceSignal.setDebounce();
	}

	/**
	 * 
	 */
	function busyDetected() 
	{
		if (portalBusyDebouceSignal.resetDebounce())
		{
			trace("busyDetected with To Short Condition, busy detected : " + _portalBusy);
		}
		else {

		}
		_portalBusy = true;

		onPortalBusy();
	}

	/**
	 * 
	 */
	public function resetErrorIfAutomaticAlarmAck() 
	{
		if (inRAAlarmToAck && paramAutomaticAlarmAck)
		{
			Main.root1.dispatchEvent(new Event(PanelEvents.EVT_RA_ALARM_ACK));
			Main.root1.dispatchEvent(new Event(PanelEvents.EVT_RA_ALARM_SOUND_ACK));
		}
	}

	/**
	 * 
	 */
	public function getBusySeconds() : Int
	{
		var diff:Float = (Date.now().getTime() - timeBusy.getTime()) / 1000;
		
		return cast diff;
	}

	/**
	 * 
	 */
	public function getStateBackgroundColor() : ASColor
	{
		return statusStateArray[Session.bTestMode ? PanelState.RA_BUSY.getIndex() : _stateMachine.getIndex()].color;	
	}

	/**
	 * 
	 */
	public function getCounterStateBackgroundColor(channelState:ChannelState, inAlarm:Bool) : ASColor
	{
		if (!isInitialized())
			return(StateColor.backColorInInit);

		if (inAlarm || Session.bTestMode)
			return countersStateArray[ChannelState.INRA.getIndex()].color;

		return countersStateArray[channelState.getIndex()].color;	
	}

	/**
	 * 
	 */
	public function getStateLabel() : String
	{
		if (!isInitialized())
			return statusStateArray[PanelState.INIT.getIndex()].label;
		return statusStateArray[Session.bTestMode ? PanelState.RA_BUSY.getIndex() : _stateMachine.getIndex()].label;	
	}

	/**
	 * 
	 */
	public function getStateTextColor() : ASColor
	{
		return new ASColor(statusStateArray[Session.bTestMode ? PanelState.RA_BUSY.getIndex() : _stateMachine.getIndex()].textColor, 0.8);	
	}

	/**
	 * 
	 */
	public function getCounterTextColor(channelState:ChannelState, inAlarm:Bool) : ASColor
	{
		if (portalInitializing || !isInitialized())
			return new ASColor(statusStateArray[PanelState.INIT.getIndex()].textColor, 0.8);

		if (inAlarm || Session.bTestMode)
			return new ASColor(statusStateArray[PanelState.RA.getIndex()].textColor, 0.8);

		return new ASColor(countersStateArray[channelState.getIndex()].textColor, 0.8);	
	}

	/**
	 * 
	 * @return
	 */
	public function getCounterTextLabel(dao:DataObject) : String
	{
		if (portalInitializing || !isInitialized())
			return"?";

		switch(dao.channelState)
		{
			case ChannelState.OK, ChannelState.INRA, ChannelState.BKG: return Std.string(dao.counterF);
			case ChannelState.HIGH: return DBTranslations.getText("IDS_COUNTER_HIGH");
			case ChannelState.LOW: return DBTranslations.getText("IDS_COUNTER_LOW");
			default: return '?';
		}
	}

	/**
	 * 
	 * @return
	 */
	public function getStatusTextLabel() : String
	{
		if (portalBKGMeasurement)
			return getStateLabel() + " " + (getPortalBusy() ? getBusySeconds() : PanelInitialization.bkgRemainingTime);

		else
			return getStateLabel();
	}

	/**
	 * 
	 */
	public function getStateLogo() : Bitmap
	{
		return statusStateArray[Session.bTestMode ? PanelState.RA_BUSY.getIndex() : _stateMachine.getIndex()].logoFunction();
	}

	/**
	 * 
	 */
	public function getShortStatusTextLabel() :String
	{
		if (portalBKGMeasurement)
			return (getPortalBusy() ? cast getBusySeconds() : cast PanelInitialization.bkgRemainingTime);

		else
			return "";
	}
}