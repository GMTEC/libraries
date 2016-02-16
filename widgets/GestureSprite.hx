package widgets; 

import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.events.TransformGestureEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

/**
 * ...
 * @author GM
 */
class GestureSprite extends MovieClip 
{
	public var moveEnabled:Bool = false;
	public var bDown:Bool;

	public function GestureSprite() 
	{
		Multitouch.inputMode = MultitouchInputMode.GESTURE;
		//trace("GestureClip");
		
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		//addEventListener(MouseEvent.MOUSE_OUT, onMouseUp);
		
		//addEventListener(TransformGestureEvent.GESTURE_SWIPE , onSwipe);
		//addEventListener(TransformGestureEvent.GESTURE_ZOOM , onZoom);
	}

	function onZoom(evt:TransformGestureEvent):Void
	{
//		trace("onZoom X: " + evt.scaleX + "Y : " + evt.scaleY);
		//this.alpha = 0.5;
	}
	
	function onSwipe(evt:TransformGestureEvent):Void
	{
		this.alpha = 0.5;
		//this.x += evt.offsetX;
		//this.y += evt.offsetY;
//			trace("onSwipe X: " + evt.offsetX + "Y : " + evt.offsetY);
	}
	
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

	function onMouseMove(evt:MouseEvent):Void
	{
	}

}