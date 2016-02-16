package panelstatemachine ;
import flash.events.EventDispatcher;
import events.PanelEvents;
import enums.Enums;
import error.Errors;
import sound.SoundPlay;
import sound.Sounds;

/**
 * ...
 * @author GM
 */

class StateMachine extends EventDispatcher
{
	var _stateMachine:PanelState;
	var evt:StateMachineEvent;
	var _portalBusy:Bool; // Set
	var previousState:PanelState;
	public var inRAAlarmToAck:Bool;
	var panelInitialization:PanelInitialization;
	var _portalInUse:Bool;

	public function new() 
	{
		super();

		evt = new StateMachineEvent();
	}

	/**
	 * 
	 * @return
	 */
	public function get_stateMachine():PanelState 
	{
		return _stateMachine;
	}

	/**
	 * 
	 * @param	value
	 * @return
	 */
	function set_stateMachine(value:PanelState):PanelState 
	{
		if (_stateMachine != value)
		{
			_stateMachine = value;
			stateModified(value);
		}

		return value;
	}

	public function stateModified(value:PanelState = null) 
	{
		if (value != null && value != previousState)
		{
			previousState = value;
			evt.stateMachine = value;
			//trace(" ****************************Dispatch State: " + evt.stateMachine);
			if (_portalInUse) panelInitialization.autoThresholdComputing.setDebounce();
			else panelInitialization.autoThresholdComputing.stopDebounce();
		}

		Main.root1.dispatchEvent(new StateMachineEvent()); // 0 for all channels		return true;
	}

	/**
	 * 
	 */
	public var stateMachine (get_stateMachine, set_stateMachine):PanelState;	
}