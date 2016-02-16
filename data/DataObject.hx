package data;

import db.DBConfigChannels.ChannelData;
import db.DBDefaults;
import enums.Enums.ChannelState;
import enums.Enums.PanelState;
import enums.Enums.Parameters;
import org.aswing.ASColor;
import util.DateUtil;

#if cpp
#end

/**
 * ...
 * @author GM
 * 
 * Object transmitted by the PGM card
 * Protocol Sibus NTT-1632-3/1008

Transmission de données 
•	Caractère 1 : STX : Début de transmission (Char(2))
•	Caractère 2 : Adresse Source : de 32 à 255
•	Caractère 3 : Adresse Destination : de 32 à 255
•	Caractère 4 : Cmd 1 : Commande Partie 1 : voir définition chapitre suivant
•	Caractère 5 : Cmd 2 : Commande Partie 2 : voir définition chapitre suivant
•	Caractère 6 : L : nombre de datas transmis + 32
•	Caractère 7 : Data 1
•	Caractère 8 : Data 2 …
•	…
•	Caractère n : CS1 : Check Sum Partie 1 (LSB)
•	Caractère n+1 : CS2 : Check Sum Partie 2 (MSB)

Cmd 1 :
•	Bit 7 : 1 L
•	Bit 6 : Direction : 0 = Transmission, 1 = Demande 
•	Bit 5 à 3 : Type :
0 : Fichier (Longeur variable) (convertit)
1 : byte (Longueur 2)	=> unsigned char (en C)
2 : word (Longueur 4)	=> unsigned int (en C)
3 : long (Longueur 8)	=> long (en C)
4 : float (Longueur 8)	=> float (en C)
5 : String (Longueur variable) => pas convertit (ASCII)
6 : Texte (Longueur variable) => pas convertit (ASCII)
7 : Image (Longueur variable) => structure image MD4220 N/B sur 8 bits convertit
•	Bit 2 à 0 : destination
0 : port externe (COM2)  (Réseau ou imprimante)
1 : UT Paramètres
2 : port interne (IHM) (COM1)
3 : port I²C
4 : UT Variable
5 : IHM Paramètres
6 : Mémoire programme
7 : non utilisé

Cmd 2 : N° du paramètre + 32


/**
 * 
 */
class DataObject extends ThresholdObject
{
	public var channelInitialized:Bool;
	public var label:String;
	public var timeout:Int;
	public var checkSumErrors:Int;
	public var timeoutErrors:Int;

	public var timeData:Date;
	public var IOStatus:Int;
	public var channelState:ChannelState;
	public var thresholdFixed:Int;
	public var endIndex:Int;
	public var reportStartIndex:Int;

	var _noise:Int;
	var _threshold:Int;

	var iPacket:Int;
	var alarmsOnTriggered: Int;
	var previousState:PanelState;

	public var inRAAlarm: Bool; // Current RA > threshold
	public var inRAAlarmToAck: Bool; // CAlarm not yet reset
	public var thresholdMode:Int;
	public var plotColor:ASColor;
	public var datagramNumber:Int;
	public var oldDatagramNumber:Int;
	public var requestNumber:Int;
	var trailerTime:Int;
	public var thresholdMeasured:Int;
	public var logEnabled:Bool;

	var rateMeterBuffer:Array<Int>;
	var rateMeterSum:Int;
	public var strLogFile:String;
	public var isComparingHighWhenPortalFree:Bool;

	/**
	 * 
	 * Default Constructor
	 */
	public function new(?addressIn:Int, ?channelIndex:Int, ?noiseIn:Int, ?triggerIn:Int) 
	{
		super(addressIn, channelIndex, noiseIn, triggerIn);

		rateMeterBuffer				= new Array<Int>();

		channelState			 	= enabled ? ChannelState.INIT : ChannelState.DISABLED;
		counter 					= -1;
		_threshold 					= triggerIn;
		_noise 						= noiseIn;
		trailerTime 				= cast DBDefaults.getIntParam(Parameters.paramTrailerTime) / 1000;
	}

	/**
	 * 
	 * @param	e
	 */
	public function onStartMeasure():Void 
	{
		reportStartIndex = datasArray.length - trailerTime;

		if (reportStartIndex < 0)
		{
			reportStartIndex = 0; // Back x seconds from history
		}
	}

	/**
	 * 
	 * @param	e
	 */
	public function onNoiseComputed():Void 
	{
		if (thresholdMode == 2)
		{
			thresholdCalculated = thresholdFixed;
		}

		checkProcessedValue();
	}

	/**
	 * 
	 */
	public function refreshMeasureMode(bRestartBKGMes:Bool = false) 
	{
		//trace("thresholdMode : " + thresholdMode);

		if (!channelInitialized)
			channelInitialized = thresholdMode > 0;

			switch(thresholdMode)
			{
				case 0:
					// recalculate BKG with the new Sigma
					calculateTriggerValue();
					threshold = thresholdCalculated;

				case 2: threshold = thresholdFixed;
				case 1: threshold = calcSquareRootThreshold();
			}

		Session.measuringMode = thresholdMode;
	}

	/**
	 * 
	 * @param	e
	 */
	public function onRAAlarmAcknowledge():Void 
	{
		resetMaximumAndMinimum();
		alarmsOnTriggered 		= 0;
		inRAAlarmToAck			= false;

		checkProcessedValue();
	}

	/**
	 * 
	 * @param	e
	 */
	public function OnResetBKGMeasure():Void 
	{
		resetMaximumAndMinimum();

		if (thresholdMode == 0)
		{
			thresholdCalculated = threshold_high_during_init;
		}
	}

	/**
	 * 
	 */
	function resetRAAlarm(immediate:Bool = false):Void
	{
		inRAAlarm 			= false;
		alarmsOnTriggered 	= 0;
	}

	/**
	 * 
	 */
	function setRAAlarm(immediate:Bool = false):Void
	{
		if (immediate || (++ alarmsOnTriggered >= Detections))
		{
			if(!inRAAlarm)
			{
				inRAAlarm 		= true;
				inRAAlarmToAck	= true;
			}
		}
	}

	/**
	 * 
	 */
	public function computeThreshold(time:Int):Void
	{
		if (!inRAAlarm)
		{
			calculateTriggerValueFromAverage(time);
			threshold			= thresholdCalculated;
			thresholdMeasured	= thresholdCalculated;
			deviation 			= Std.int(deviation);
			_noise 				= noise;
			channelInitialized 	= true;
			//trace("Set in DB  Noise: " + _noise);
			//trace("Set in DB  Trigger: " + _threshold);
			Session.dbChannelsDefaults.updateConfigChannelTable(this);
			//trace("Compute Alarm(), trigger = " + bufferDataArray.trigger);
		}
	}

	/**
	 * 
	 * @return
	 */
	public function isValueInvalid():Bool
	{
		return channelState != ChannelState.OK;
	}

	/**
	 * 
	 * @return
	 */
	function isBusy():Bool {
		return Session.IOStatus != 3;
	}

	public function setChannelState(state:ChannelState)
	{
		channelState = state;
	}

	/**
	 * 
	 */
	function getDataState() : ChannelState
	{
		var state:PanelState = Session.panelStateMachine.stateMachine;

		if(!Session.panelStateMachine.isInitialized())
			return ChannelState.INIT;

		if (channelState == ChannelState.TIMEOUT)
			return channelState;

		if (channelState == ChannelState.ERROR)
			return channelState;

		if (counterF < threshold_low) return ChannelState.LOW;

		return Session.panelStateMachine.portalBKGMeasurement ? ChannelState.BKG : ChannelState.OK;
	}

	/**
	 * 
	 */
	function checkProcessedValue() 
	{
		var state:ChannelState = getDataState();

		if (state != channelState)
		{
			channelState = state;
		}

		if (!channelInitialized)
		{
			if ((checkCounterFValue()) || (counterF > threshold_high))
			{
				setRAAlarm(true);
				return;
			}
		}

		else if (counterF > threshold) // 
		{
			setRAAlarm();

			return;
		}

		resetRAAlarm();
	}

	static var checkCount:Int = 0;

	/**
	 * 
	 */
	function checkCounterFValue():Bool
	{
		var retVal:Bool 	= false;
		var sumCount:Int	= 0;

		if (checkCount ++ == Smoothing && (datasArray.length > Smoothing))
		{
			retVal =  ((sumCount / Smoothing ) > threshold_high_during_init);
			checkCount 	= 0;
			sumCount 	= 0;
		}
		else
		{
			sumCount += counter;
			retVal = counter > threshold_high_during_init;
		}

		return retVal;
	}

	/**
	 * 
	 * @return
	 */
	function getThresholdValue():Int
	{
		if (isComparingHighWhenPortalFree && !isBusy())	return threshold_high_during_init;
		return (Session.panelStateMachine.portalBKGMeasurement || (thresholdCalculated < threshold_low)) ? threshold_high_during_init : thresholdCalculated;
	}

	/**
	 * 
	 */
	public function processCurrentValue():Void
	{
		threshold = getThresholdValue();
		//trace("threshold : " + threshold);
		setFilteredCounter(getFilteredCounter(counter));

		checkProcessedValue(); // !!!!

		var channelData:ChannelData = new ChannelData();

		channelData.counter 		= counter;
		channelData.counterF 		= counterF;
		channelData.status 			= IOStatus;
		channelData.deviation		= deviation;
		channelData.reportNumber 	= Session.lastReport.lastReportData.ReportNumber+1;

		if(inRAAlarm)
			channelData.radioActivity = 1;

		channelData.time			= Date.now();
		channelData.noise 			= noise;
		channelData.thresholdCalculated			= thresholdCalculated;
		channelData.deviation		= deviation;
		channelData.variance		= variance;
		pushCurrentData(channelData);

		checkSumErrors	= 0;
	}

	/**
	 * 
	 * @param	enabled
	 */
	public function enablelog(enabled:Bool):Void 
	{
		if (enabled != logEnabled)
		{
			if (logEnabled)
				strLogFile = null;
			logEnabled = enabled;
		}
	}

	/**
	 * 
	 * @param	data
	 */
	public function pushCurrentData(channelData:ChannelData) 
	{
		datasArray.push(channelData);
		//trace("datasArray Lenght : " + datasArray.length);

		if (logEnabled)
			writeValue(channelData);

		if (datasArray.length >= DefaultParameters.datagramsArrayLenght) // x min. buffer
		{
			datasArray.shift();
			if (reportStartIndex > 0)
				reportStartIndex--;
		}
		
		// !!!!!!!!!!!!!!!!!!!!!!!!!!!
		//computeThreshold(1);
	}

	/**
	 * Write Value in Log File
	 * @param	channelData
	 */
	function writeValue(cd:ChannelData)
	{
		if (strLogFile == null)
			strLogFile = "Time,Counter,Deviation,Variance,Threshold,Noise,Address " + this.address + "\n";

		strLogFile += DateUtil.getStringTime(Date.now().toString()) + ',' + cd._counter + ',' + Std.string(Std.int(cd.deviation)) + ',' + Std.string(Std.int(cd.variance)) +',' + cd.thresholdCalculated + ','  + cd.noise + '\n';
	}

	/**
	 * 
	 * @param	channelData
	 */
	function getFilteredCounter(counter:Int) : Int
	{
		rateMeterBuffer.push(counter);

		while (rateMeterBuffer.length > Smoothing)
		{
			rateMeterSum -= rateMeterBuffer.shift();
		}

		rateMeterSum += counter;
		
		return cast rateMeterSum / rateMeterBuffer.length;
	}

	/**
	 * 
	 */
	public function saveReportData():Bool
	{
		trace("saveReportData(), start index : " + reportStartIndex);

		return Session.dbChannels.saveReportData(datasArray, channelIndex, reportStartIndex);
	}

	/**
	 * 
	 * @return
	 */
	function get_noise():Int 
	{
		//if (_noise == 0)
			//return savedNoise;

		return _noise;
	}

	function set_noise(value:Int):Int 
	{	
		_noise = value;

		return _noise;
	}

	function get_threshold():Int 
	{
		if (_threshold == 0)
			return threshold_high_during_init;

		return _threshold;
	}

	/**
	 * 
	 * @param	value
	 * @return
	 */
	function set_threshold(value:Int):Int 
	{
		_threshold = value;

		return _threshold;
	}

	/**
	 * 
	 */
	public function getBarGraphValue() :Int
	{
		return counter;
	}

	/**
	 * 
	 * @return
	 */
	public function getCounterBackColor(onAlarm:Bool) : ASColor
	{
		//trace("channelState : " + channelState);
		return Session.panelStateMachine.getCounterStateBackgroundColor(channelState, (!onAlarm && inRAAlarmToAck) || inRAAlarm);
	}

	/**
	 * 
	 * @return
	 */
	public function getCounterTextColor(onAlarm:Bool) : ASColor
	{
		switch(channelState)
		{
			case ChannelState.INIT, ChannelState.OK: return Session.panelStateMachine.getCounterTextColor(channelState, (!onAlarm && inRAAlarmToAck) || inRAAlarm);
			default: return new ASColor(ASColor.CLOUDS.getRGB(), 0.8);
		}
	}

	/**
	 * 
	 * @param	checkChecksum
	 */
	public function setChecksum(checkChecksum:Bool) 
	{
		checkSumErrors += checkChecksum ? 1 : 0;
	}

	/**
	 * 
	 * @return
	 */
	public function areValuesUndefined() : Bool
	{
		switch (channelState)
		{
			case ChannelState.TIMEOUT: return true;
			case ChannelState.DISABLED: return true;
			default:return false;
		}

		if (maximum == 0) return true;
		
		return false;
	}
}