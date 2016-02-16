package widgets;
import db.DBTranslations;
import error.Errors;
import events.PanelEvents;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.BitmapFilter;
import haxe.Timer;
import Main;
import org.aswing.ASColor;
import statemachine.StateMachine.StateColor;
import widgets.WBase;

/**
 * ...
 * @author GM
 */

class WIndicatorsPane extends WBase
{
	var butOutOfOrder:WIndicator;
	var butWarning:WIndicator;
	var butRAAlarm:WIndicator;
	var butControl:WIndicator;
	var butInUse:WIndicator;
	var butBKG:WIndicator;
	var bTest:Bool;
	var butAllIndicators:Sprite;
	var fontSize:Int = 10;
	var strBKG:String;
	static var butWidthDefault	= 98;
	static var butWidthOffset	= 97;
	static var butHeightDefault = 22;

	public function new(nameIn:String, filtersIn:Array<BitmapFilter>=null, ?dup = false) 
	{
		super(nameIn, filtersIn, dup);

		butAllIndicators = new Sprite();
		strBKG = DBTranslations.getText("IDS_BKG") + ' ';

		butInUse = new WIndicator("ID_STATUS_INUSE", DBTranslations.getText("IDS_STATUS_INUSE"), StateColor.backColorInInUse, ASColor.MIDNIGHT_BLUE, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butInUse);

		butControl = new WIndicator("ID_STATUS_CONTROL", DBTranslations.getText("IDS_STATUS_CONTROLLING"), StateColor.backColorInControlling, ASColor.MIDNIGHT_BLUE, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butControl);
		butControl.x = butWidthOffset;

		butRAAlarm = new WIndicator("ID_STATUS_ALARM", DBTranslations.getText("IDS_STATUS_ALARM"), StateColor.backColorInRAAlarm,  ASColor.CLOUDS, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butRAAlarm);
		butRAAlarm.x = butWidthOffset * 2;

		butBKG = new WIndicator("ID_STATUS_BKG", strBKG, StateColor.backColorInBKG,  ASColor.CLOUDS, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butBKG);
		butBKG.x = butWidthOffset * 3;

		butWarning = new WIndicator("ID_STATUS_WARNING", DBTranslations.getText("IDS_STATUS_WARNING"), StateColor.backColorInTest, ASColor.MIDNIGHT_BLUE, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butWarning);
		butWarning.x = butWidthOffset * 4;

		butOutOfOrder = new WIndicator("ID_STATUS_OUT", DBTranslations.getText("IDS_STATUS_OUT"), StateColor.backColorInOUT, ASColor.CLOUDS, butWidthDefault, butHeightDefault, fontSize);
		butAllIndicators.addChild(butOutOfOrder);
		butOutOfOrder.x = butWidthOffset * 5;

		addChild(butAllIndicators);

		//spriteBack.y += 22;
		//spriteBack.height += 4;
		//Main.root.addEventListener(PanelEvents.EVT_PORTAL_BUSY, onStateRefresh);
		//Main.root.addEventListener(PanelEvents.EVT_PORTAL_FREE, onStateRefresh);
		Main.root1.addEventListener(PanelEvents.EVT_PANEL_STATE, onStateRefresh);
		Main.root1.addEventListener(PanelEvents.EVT_TEST_MODE_ON, onTestOn);
		Main.root1.addEventListener(PanelEvents.EVT_TEST_MODE_OFF, onTestOff);
		Main.root1.addEventListener(PanelEvents.EVT_CLOCK, onClockEvent);
	}

	/**
	 * 
	 * @param	name
	 */	
	public override function duplicate(name:String):WIndicatorsPane
	{
		trace("duplicateIndicatorsPane()");
		return new WIndicatorsPane(name, true);
	}

	/**
	 * 
	 */
	static var clockState:Bool = false;
	/**
	 * 
	 * @param	e
	 */
	private function onClockEvent(e:Event):Void 
	{
		haxe.Timer.delay(onToggleLamp, 500);
		clockState = false;
		refreshButWarning();
		refreshButRAAlarmWarning();
	}

	function refreshButWarning() 
	{
		butWarning.setEnabled(bTest || Errors.portalInWarning && clockState);
	}

	function refreshButRAAlarmWarning() 
	{
		var lampOn:Bool = Session.panelStateMachine.inRAAlarmToAck ? (Session.panelStateMachine.inRAAlarmToAck && clockState) : Session.panelStateMachine.inRAAlarm;

		butRAAlarm.setEnabled(bTest || lampOn);
	}

	function onToggleLamp() 
	{
		clockState = !clockState;
		refreshButWarning();
		refreshButRAAlarmWarning();
	}

	private function onTestOn(e:Event):Void 
	{
		bTest = true;
		onStateRefresh(null);
	}

	private function onTestOff(e:Event):Void 
	{
		bTest = false;
		onStateRefresh(null);
	}

	/**
	 * 
	 * @param	e
	 */
	function onStateRefresh(e:StateMachineEvent):Void
	{
		butRAAlarm.setEnabled		(bTest || Session.panelStateMachine.inRAAlarmToAck);
		butInUse.setEnabled		(bTest || Session.panelStateMachine.portalInUse && !Errors.portalInError);
		butControl.setEnabled	(bTest || Session.panelStateMachine.portalControlling);
		butOutOfOrder.setEnabled(bTest || Errors.portalInError);
		butBKG.setEnabled		(bTest || Session.panelStateMachine.portalBKGMeasurement);
		butBKG.setText(strBKG + Session.panelStateMachine.getShortStatusTextLabel());
	}
}