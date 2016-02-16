package util.plot;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import util.PlotGraph;

/**
 * ...
 * @author GM
 */
class GestureSprite extends Sprite 
{
	public var moveEnabled	:Bool = false;
	public var bDown		:Bool;
	var mouseMoveFunc		:MouseEvent->Void;

	public function new(mouseMoveFunc:MouseEvent->Void) 
	{
		super();

		this.mouseMoveFunc 		= mouseMoveFunc;

		Multitouch.inputMode 	= MultitouchInputMode.GESTURE;

		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

		//addEventListener(TransformGestureEvent.GESTURE_SWIPE , onSwipe);
		//addEventListener(TransformGestureEvent.GESTURE_ZOOM , onZoom);
	}

	/**
	 * 
	 * @param	evt
	 */
	function onMouseDown(evt:MouseEvent):Void
	{
		if(moveEnabled)
			bDown = true;
		//this.alpha = 0.5;
	}

	function onMouseUp(evt:MouseEvent):Void
	{
		if (bDown)
		{
			bDown = false;
		}		
		//this.alpha = 0.1;
	}

	/**
	 * 
	 * @param	e
	 */
	private function onMouseOut(e:MouseEvent):Void 
	{
		if (cast mouseMoveFunc) mouseMoveFunc(e);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onMouseMove(e:MouseEvent):Void 
	{
		if (cast mouseMoveFunc) mouseMoveFunc(e);
	}
}
