package comp;

import widgets.SpriteMenuButton;

/**
 * ...
 * @author GM
 */
class ButtonPortal extends ButtonMenu
{
	/**
	 * 
	 * @param	bmDataIn
	 * @param	label
	 * @param	xIn
	 * @param	yIn
	 * @param	bitmapName
	 * @param	wIn
	 * @param	hIn
	 */
	public function new(name:String, xIn:Int, yIn:Int, wIn:Int, hIn:Int, text:String = "", sprite:SpriteMenuButton = null, iconSizeIn:Int = 0) 
	{
		super(name, xIn, yIn, wIn, hIn, text, sprite, iconSizeIn);

		//Main.root.addEventListener(PanelEvents.EVT_PANEL_STATE, onStateRefresh);
	}

	///**
	 //* 
	 //* @param	e
	 //*/
	//private function onStateRefresh(evt:StateMachineEvent):Void 
	//{
		//var state:PanelState = evt.getPanelState();
		//icon.setBitmap(Session.panelStateMachine.statusStateArray[evt.stateMachine].logo);
	//}
}