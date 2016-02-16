package widgets; 

import db.DBDefaults;
import enums.Enums.Parameters;
import flash.desktop.NativeDragManager;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.NativeDragEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import util.BitmapUtils;
import util.ScreenManager;

/**
 * ...
 * @author GM
 */

class Widget extends Sprite
{
	var _X:Int;
	var _Y:Int;

	var pointMouse:Point;
	var pointWidget:Point;
	var bDown:Bool;
	var moveEnabled:Bool = true;

	/**
	 *
	 */
	public function new()
	{
		super();

		pointMouse = new Point();
		pointWidget = new Point();

		x = cast DBDefaults.getIntParam(Parameters.paramWindowposX);
		y = cast DBDefaults.getIntParam(Parameters.paramWindowposY);
		var rect:Rectangle = ScreenManager.getMaximumAvailableResolution();

		if (x > rect.x)
			x = 0;
	}

	/**
	 *
	 * @param	evt
	 */
	public function onWidgetDown(evt:MouseEvent):Void
	{
		if (moveEnabled)
		{
			bDown = true;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onWidgetMove); // stage used to follow the mouse movement on the desktop
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			pointMouse.x = evt.stageX;
			pointMouse.y = evt.stageY;

			pointWidget.x = x;
			pointWidget.y = y;
		}
	}

	/**
	 *
	 * @param	evt
	 */
	function onWidgetMove(evt:MouseEvent):Void
	{
		if (bDown)
		{
			//trace(evt.stageX);
			x = pointWidget.x + evt.stageX - pointMouse.x;
			y = pointWidget.y + evt.stageY - pointMouse.y;
		}
	}

	/**
	 * 
	 * @param	evt
	 */
	function onMouseUp(evt:MouseEvent):Void
	{
		if (bDown)
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, onWidgetMove);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			bDown = false;
		}		
	}	
	/**
	 *
	 */
	function saveWinPos():Void
	{
		_X = cast x;
		_Y = cast y;
	}

	/**
	 *
	 * @param	e
	 */
	function onClickWidget(evt:MouseEvent):Void
	{
		removeEventListener(MouseEvent.MOUSE_MOVE, onWidgetMove);
		
		saveWinPos();
	}

	/**
	 *
	 * @param	e
	 */
	function onDragenter(e:NativeDragEvent):Void
	{
		NativeDragManager.acceptDragDrop(this);
	}

	/**
	 *
	 */
	function createWidget():Void
	{
		addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragenter);
		addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onDrop);
		addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, onDragExit);
		addEventListener(MouseEvent.CLICK, onClickWidget);
	}

	/**
	 *
	 * @param	mvc
	 */
	public function setposAndSize(spriteIn:Sprite, mvc:Rectangle, vis:Bool = true, duration:Float = 0.35):Void
	{
		//TweenMax.to(spriteIn, duration, {y: mvc.y, x: mvc.x, width: mvc.width, height: mvc.height, visible: vis});
	}

	public function fadeIn(sprite:Sprite, fade:Float = 1, time:Int = 0):Void
	{
		//if (sprite)
		//{
			//if (fade)
				//sprite.alpha = 0;
			//
			//sprite.visible = true;
			//
			//TweenMax.to(sprite, time == 0 ? ALPHA_TIME : time, {alpha: fade});
		//}
	}

	/**
	 *
	 */
	function magnifyWidget():Void
	{
		//fadeIn(widgetSmall, 0);
		//setposAndSize(widgetSmall, rectBigWidget);
		//
		//fadeIn(widgetBig);
		//setposAndSize(widgetBig, rectBigWidget);
		//swapChildren(widgetSmall, widgetBig);
	}

	/**
	 *
	 */
	function minimizeWidget():Void
	{
		//fadeIn(widgetBig, 0);
		//setposAndSize(widgetBig, rectSmallWidget, true);
		//
		//fadeIn(widgetSmall);
		//setposAndSize(widgetSmall, rectSmallWidget);
		//swapChildren(widgetSmall, widgetBig);
	}

	///**
	 //*
	 //*/
	//public function loadWidgetIcon():Void
	//{
		//var fileIcon:File = File.applicationDirectory.resolvePath(icon16Name);
//
		//var bitmaps:Array = fileIcon.icon.bitmaps;
		//var bmpData:BitmapData = new BitmapData(48, 48);
		//
		//for (i in 0 ... bitmaps.length-1)
		//{
			//bmpData = fileIcon.icon.bitmaps[i];
			//
			//if (bmpData.height == 32)
			//{
				//bmp48x48 = new Bitmap(bmpData);
				//bmp48x48.x += 100;
				//bmp48x48.y += 100;
				//bmp48x48.scaleX = 2;
				//bmp48x48.scaleY = 2;
				//widgetSmall.addChild(bmp48x48);
				//break;
			//}
		//}
	//}

	/**
	 *
	 * @param	event
	 */
	function onDrop(event:NativeDragEvent):Void
	{
	}

	/**
	 *
	 * @param	event
	 */
	function onDragExit(event:NativeDragEvent):Void
	{
		trace("Drag exit event.");
	}
}
