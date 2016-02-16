package widgets;

import flash.geom.Rectangle;
import flash.Lib;
import org.aswing.ASColor;
import org.aswing.geom.IntRectangle;
import util.Images;
import flash.display.Bitmap;
import Array;
import util.Images;
import util.Filters;
import flash.display.Sprite;
import db.DBTranslations;
import flash.events.Event;
import flash.display.DisplayObject;
import events.PanelEvents;
import enums.Enums;
import motion.Actuate;
import db.DBDefaults;
import panesmain.MainWindow;
import flash.events.MouseEvent;
import util.ScreenManager;

/**
 * ...
 * @author GM
 */
class WSmall extends Widget
{
	//var previousLogo:Sprite;
	var widgetSize:Int;

	/**
	 * 
	 */
	public function new()
	{
		super();

		x			= cast DBDefaults.getIntParam(Parameters.paramWidgetposX);
		y			= cast DBDefaults.getIntParam(Parameters.paramWidgetposY);
		widgetSize	= cast DBDefaults.getIntParam(Parameters.paramWidgetSize);

		var rect:Rectangle = ScreenManager.getMaximumAvailableResolution();

		if (x > rect.width)
		{
			rect = ScreenManager.getActualScreenBounds(1);
			x = rect.right - widgetSize;
			y = rect.top;
		}

		createWidget();

	}

	override function createWidget():Void
	{
		addEventListener(MouseEvent.MOUSE_DOWN, onWidgetDown);
		super.createWidget();

	}
	/**
	 * 
	 * @param	duplicated
	 */
	public function removeWidget(duplicated:Dynamic) 
	{

	}
	/**
	 * 
	 * @param	duplicated
	 */
	public function addWidget(duplicated:Dynamic) 
	{

	}	
	/**
	 *
	 */
	override function saveWinPos():Void
	{
		super.saveWinPos();

		Session.dbDefaults.setIntParam(Parameters.paramWidgetposX, cast x);
		Session.dbDefaults.setIntParam(Parameters.paramWidgetposY, cast y);
	}

	/**
	 *
	 */
	public function bringToFront(sprite:Sprite):Void
	{
		sprite.parent.setChildIndex(sprite, sprite.parent.numChildren - 1);
	}
}
