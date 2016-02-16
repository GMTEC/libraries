package widgets;

import com.haxepunk.utils.Key;
import comp.JAdjuster1;
import db.DBConfigWidgets.ConfigWidgetData;
import db.DBDefaults;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.BitmapFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import org.aswing.ASColor;
import org.aswing.geom.IntRectangle;
import org.aswing.JButton;
import org.aswing.JCheckBox;
import org.aswing.JPanel;
import org.aswing.util.CompUtils;
import tweenx909.TweenX;

/**
 * ...
 * @author GM
 */
class WBase extends JPanel
{
	public static inline var X_ZOOMED:Int 	= 50;
	public static inline var Y_ZOOMED:Int 	= 140;
	public static inline var BIGSCALE:Float = 1.2;
	public static inline var butH:Int 		= 72;
	public static inline var butW:Int 		= 120;
	public static inline var butdH 			= 76;
	private var spriteToFadeIn				:DisplayObject;
	private var finalFade					:Float;

	var W:Int;
	var H:Int;

	public var leftSide:Bool 	= false;
	var initialized:Bool;
	var hookVisible:Bool;

	var pointMouse:Point;
	var zoomed:Bool;
	var bDown:Bool;
	static var bDownOnWidget:Bool;
	var configWidget:ConfigWidgetData;
	public var butBackground:JButton;

	var bHook:Bool;
	//var dPos:Float = 8;
	var dragging:Bool;
	var bMoved:Bool;
	var childIndex:Int;
	var _toggleObjects:Array<WBase>;
	static private inline var EASE:Float = 0.2;
	var spriteDrag:Sprite;
	var adjScale:JAdjuster1;
	var chkSmall:JCheckBox;
	var adjX:JAdjuster1;
	var adjY:JAdjuster1;
	var duplicatedWidget:WBase;
	var configWidgetExists:Bool;
	var menu:Sprite;
	var rectBound:Rectangle;

	/**
	 * 
	 * @param	nameIn
	 *
	 */
	public function new(nameIn:String, filtersIn:Array<BitmapFilter> = null, ?duplicating:Bool = false)
	{
		super();

		name = nameIn;

		Main.root1.addEventListener(PanelEvents.EVT_DATA_REFRESH, onDataRefresh);
		Main.root1.addEventListener(PanelEvents.EVT_WIN_REFRESH, refreshPositionAndScale);
		Main.root1.addEventListener(PanelEvents.EVT_PARAM_UPDATED, onParamUpdated);

		bHook = DBDefaults.getIntParam(Parameters.paramHookMode) == 1;

		if(bHook)
			Main.root1.addEventListener(PanelEvents.EVT_PANE_HELP, OnHook);

		refreshPositionAndScale();

		pointMouse = new Point();

		if (filtersIn != null)
			filters = filtersIn;
		
		addEventListener( Event.ADDED_TO_STAGE, onAddedToStage);

		if(!duplicating && configWidgetExists) duplicateWidget();
	}
	
	/**
	 * 
	 */
	public function removeWidget() 
	{
		if (configWidgetExists)
		{
			duplicatedWidget.parent.removeChild(duplicatedWidget);
			configWidgetExists = false;
		}
		if(cast this.parent) this.parent.removeChild(this);
	}

	/**
	 * 
	 * @param	name
	 */	
	public function duplicate(name:String):Dynamic
	{
		return null;
	}

	/**
	 * 
	 */
	public function duplicateWidget(dup:Bool = true)
	{
		trace("duplicateWidget()" + dup);
		if (!dup)
		{
			Main.widgetSmall.removeWidget(duplicatedWidget);
		}
		else
		{
			duplicatedWidget = duplicate(name + "_DUP");
			if ((cast duplicatedWidget) && duplicatedWidget.configWidget.Visible) Main.widgetSmall.addWidget(duplicatedWidget);
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function onAddedToStage(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		createInflatedBackground();
	}

	/**
	 * 
	 * @param	e
	 */
	private function rightMouseUpHandler(e:MouseEvent):Void 
	{
	}

	/**
	 * 
	 * @param	e
	 */
	private function rightMouseDownHandler(e:MouseEvent):Void 
	{
		if (bHook)
		{
			if (bDownOnWidget)
				setWinPos(); // Save new position

			bDownOnWidget = !bDownOnWidget;
		
			trace("Widget: " + configWidget.name + ", x: " + x + ", y: " + y+ ", width: " + width+ ", height: " + height);

			if (spriteDrag == null)
				createBackground();

			e.stopPropagation();
			spriteDrag.visible = !spriteDrag.visible;

			if (!spriteDrag.visible)
			{
				rightMouseUpHandler(null);
				setRightButtonDragging(false);
				setLeftButtonDragging(false);
			}
			else
			{
				setRightButtonDragging();
				setLeftButtonDragging();
				addEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel); // stage used to follow the mouse movement on the desktop
				//createButtons();
				//refreshButtonsValues();
			}
			setButtonsVisible(spriteDrag.visible);
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function onMouseMove(e:MouseEvent):Void 
	{
		refreshButtonsValues();
	}

	/**
	 * 
	 */
	function createButtons() 
	{
		if (!cast adjScale)
		{
			var butX:Int 	= 100;
			var butY:Int 	= 0;
			var dY:Int		= 40;
			var dX:Int		= 0;
			adjScale 	= CompUtils.addAdjuster(this, "", null, butX, butY, 1, 40, translatorToScale, _onAdjScale, 100);
			adjX 		= CompUtils.addAdjuster(this, "", null, butX += dX, butY += dY, -1024, 1024, _translatorToXY, _onAdjX, 100);
			adjY 		= CompUtils.addAdjuster(this, "", null, butX += dX, butY += dY, -1024, 1024, _translatorToXY, _onAdjY, 100);
			chkSmall	= CompUtils.addCheckBox(this, "IDS_VISIBLE_ON_DESKTOP", butX += dX, butY += dY+10, _onChkSmall);
		}
	}

	function _onChkSmall(res:Dynamic) :Void
	{
		if (cast duplicatedWidget)
		{
			duplicateWidget(chkSmall.isSelected());
			duplicatedWidget.configWidget.Visible = chkSmall.isSelected();
		}
		refreshPositionAndScale();
	}

	/**
	 * 
	 */
	function _onAdjScale(res:Dynamic) :Void
	{
		if (cast rectBound)
			drawDashedRect(spriteDrag, rectBound.x, rectBound.y, rectBound.width, rectBound.height, cast 8/scaleX, cast 4/scaleX, 1/scaleX);
	}

	function _onAdjY(e:Dynamic) :Void
	{
	}

	function _onAdjX(e:Dynamic) :Void
	{
	}

	/**
	 * 
	 * @param	value
	 * @return
	 */
	function translatorToScale(value:Int):String
	{
		scaleX = scaleY = cast value / 10;
		return Math.round(value) + '%';
	}
	
	function _translatorToXY(value:Int):String
	{
		return cast value;
	}

	/**
	 * 
	 * @param	v
	 */
	function setButtonsVisible(v:Bool = true) 
	{
		if (dragging) return;
		if (menu == null)
		{
			menu = new Sprite();
			menu.addChild(adjScale);
			menu.addChild(adjX);
			menu.addChild(adjY);
			menu.addChild(chkSmall);
			Main.stageMain.stage.addChild(menu);
		}

		var stagePoint:Point = new Point(0, 0);
		var targetPoint:Point;
		targetPoint = Main.widgetBig.localToGlobal(stagePoint);
		
		trace("********X: " + targetPoint.x);
		trace("********Y: " + targetPoint.y);
	
		menu.x = targetPoint.x;
		menu.y = targetPoint.y;

		menu.visible = v;
		adjScale.setEnabled(v);
		adjX.setEnabled(v);
		adjY.setEnabled(v);
		chkSmall.setEnabled(v);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onKeyDown(e:KeyboardEvent):Void 
	{
		switch (e.keyCode)
		{
			case Key.UP: 	y --; refreshButtonsValues();
			case Key.DOWN: 	y ++; refreshButtonsValues();
			case Key.RIGHT: x ++; refreshButtonsValues();
			case Key.LEFT: 	x --; refreshButtonsValues();
		}
	}

	/**
	 * 
	 * @param	xIn
	 * @param	yIn
	 * @param	wIn
	 * @param	hIn
	 * @param	strokeLength
	 * @param	gap
	 * @return
	 */
	function drawDashedRect(rect:Sprite, xIn:Float=0, yIn:Float=0, wIn:Float=0, hIn:Float=0, strokeLength:Float=0, gap:Float=0, w:Float = 0):Sprite
	{
		if (rect == null)
			rect = new Sprite();
			rect.graphics.clear();
		CompUtils.drawDashedLine(rect, xIn, yIn, xIn + wIn, yIn, strokeLength, gap, w);
		CompUtils.drawDashedLine(rect, xIn + wIn, yIn, xIn + wIn, yIn + hIn, strokeLength, gap, w);
		CompUtils.drawDashedLine(rect, xIn + wIn, yIn + hIn, xIn, yIn + hIn, strokeLength, gap, w);

		return CompUtils.drawDashedLine(rect, xIn, yIn + hIn, xIn, yIn, strokeLength, gap, w);
	}

	/**
	 * 
	 * @param	obj
	 */
	public function addToggleObject(obj:WBase)
	{
		if (!cast _toggleObjects) {
			_toggleObjects			= new Array<WBase>();
		}
		obj.addEventListener(MouseEvent.CLICK, onObjectClick);
		_toggleObjects.push(obj);
	}

	/**
	 * 
	 * @param	e
	 */
	private function onObjectClick(e:MouseEvent):Void 
	{
		var objClicked:WBase = e.currentTarget;
		objClicked.zoomed = !objClicked.zoomed;

		for (obj in _toggleObjects) {
			if (obj != e.currentTarget) obj.setVisible(!objClicked.zoomed);
		}

		objClicked.zoomTo((objClicked.zoomed) ? scaleX * BIGSCALE : 0);
	}
	///**
	 //* 
	 //* @param	e
	 //*/
	//private function onObjectClick(e:MouseEvent):Void 
	//{
		//var objClicked:Object = e.currentTarget;
//
		//for (obj in _toggleObjects) {
			//if (obj != e.currentTarget) obj.setVisible((objClicked.scaleX == objClicked.scaleX * BIGSCALE));
		//}
//
		//objClicked.zoomTo((objClicked.scaleX == BIGSCALE)  ? 0 : BIGSCALE);
	//}
	/**
	 * 
	 */
	public function setRightButtonDragging(dragging:Bool = true) 
	{
		if (dragging)
		{
			addEventListener (MouseEvent.RIGHT_MOUSE_DOWN, rightMouseDownHandler); // stage used to follow the mouse movement on the desktop
			addEventListener (MouseEvent.RIGHT_MOUSE_UP, rightMouseUpHandler); // stage used to follow the mouse movement on the desktop
		}
		else {
			//removeEventListener (MouseEvent.RIGHT_MOUSE_DOWN, rightMouseDownHandler); // stage used to follow the mouse movement on the desktop
			removeEventListener (MouseEvent.RIGHT_MOUSE_UP, rightMouseUpHandler); // stage used to follow the mouse movement on the desktop
			removeEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel); // stage used to follow the mouse movement on the desktop
		}
	}

	public function setLeftButtonDragging(dragging:Bool = true) 
	{
		if (dragging)
		{
			addEventListener (MouseEvent.MOUSE_DOWN, leftMouseDownHandler); // stage used to follow the mouse movement on the desktop
			addEventListener (MouseEvent.MOUSE_UP, leftMouseUpHandler); // stage used to follow the mouse movement on the desktop
			addEventListener (MouseEvent.CLICK, onMouseClick); // stage used to follow the mouse movement on the desktop
			parent.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		else {
			removeEventListener (MouseEvent.MOUSE_DOWN, leftMouseDownHandler); // stage used to follow the mouse movement on the desktop
			removeEventListener (MouseEvent.MOUSE_UP, leftMouseUpHandler); // stage used to follow the mouse movement on the desktop
			removeEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel); // stage used to follow the mouse movement on the desktop
			removeEventListener (MouseEvent.CLICK, onMouseClick); // stage used to follow the mouse movement on the desktop
			parent.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
	}

	private function onMouseClick(e:MouseEvent):Void 
	{
		e.stopPropagation();
	}

	private function leftMouseUpHandler(e:MouseEvent):Void 
	{
		e.stopPropagation();

		trace("stopDrag");
		stopDrag();
		setLeftButtonDragging(false);
		rightMouseDownHandler(e);
	}

	private function leftMouseDownHandler(e:MouseEvent):Void 
	{
		e.stopPropagation();
		trace("startDrag");
		startDrag();
		setLeftButtonDragging();
	}

	/**
	 * 
	 * @param	e
	 */
	private function mouseClickHandler(e:MouseEvent):Void 
	{
		spriteDrag.visible = false;
		setButtonsVisible(false);
	}

	/**
	 * 
	 * @param	dragging
	 */
	public function setDragging(dragging:Bool = true)
	{
		this.dragging = dragging;

		if (dragging) setRightButtonDragging();
	}

	/**
	 * 
	 * @param	e
	 */
	function onParamUpdated(e:Event = null):Void 
	{
		bHook = DBDefaults.getIntParam(Parameters.paramHookMode) == 1;
		refresh();
	}

	public function refresh() 
	{
		if((cast duplicatedWidget) && (cast chkSmall)) chkSmall.setSelected(duplicatedWidget.alpha > 0);
	}

	/**
	 * 
	 */
	function refreshPositionAndScale(e:Event = null) 
	{
		configWidget = Session.dbConfigWidgets.getConfigWidget(name);
		configWidgetExists = cast configWidget;

		if (!configWidgetExists)
			configWidget = new ConfigWidgetData(name, 0, 0, 0, 0, 1, true);
	
		setDragging(configWidget.Draggable);

		W 		= configWidget.Width;
		H 		= configWidget.Height;
		x 		= configWidget.XPos;
		y 		= configWidget.YPos;
		scaleX 	= scaleY = configWidget.Scale;
	}

	/**
	 * 
	 * @param	v
	 */
	override public function setVisible(v:Bool):Void 
	{
		if (v)
		{
			super.setVisible(true);
			TweenX.tweenFunc(fadeNewBitmap, [0.2], [1], EASE);
		}
		else
		{
			TweenX.tweenFunc(fadeNewBitmap, [0.8], [0], EASE).onFinish(_hide);
		}
	}

	/**
	 * 
	 * @param	alpha
	 */
	function fadeNewBitmap(alpha:Float) 
	{
		this.alpha = alpha;
	}

	/**
	 * 
	 * @param	v
	 */
	public function zoomTo(value:Float):Void 
	{
		TweenX.tweenFunc(setZoom, 	[scaleX], [(value == BIGSCALE) ? value : configWidget.Scale], EASE);
		TweenX.tweenFunc(setPos, 	[x, y], (value == BIGSCALE) ? [X_ZOOMED, Y_ZOOMED] : [configWidget.XPos, configWidget.YPos], EASE);
	}

	/**
	 * 
	 * @param	xIn
	 * @param	yIn
	 */
	function setPos(xIn:Float, yIn:Float) 
	{
		x = xIn;
		y = yIn;
	}

	/**
	 * 
	 */
	function setZoom(z:Float) 
	{
		scaleX = scaleY = z;
	}

	/**
	 * 
	 */
	function _hide() 
	{
		super.visible = false;
	}
	
	/**
	 * 
	 * @param	e
	 */
	private function OnHook(e:Event):Void 
	{
		hookVisible = !hookVisible;
	}

	/**
	 * 
	 * @param	e
	 */
	function onDataRefresh(e:ParameterEvent):Void
	{	
	}

	/**
	 * 
	 * @param	wIn
	 * @param	hIn
	 * @param	parentIn
	 * @param	bArrowsOnly
	 */
	public function createBackgroundWithPaper(wIn:Float = 0, hIn:Float = 0, ?papercolor:ASColor, bArrowsOnly:Bool = true):IntRectangle
	{
		//createBackground(wIn, hIn, bArrowsOnly);	
		if (cast papercolor)
		{
			var paper:Sprite = new Sprite();
			//paper.alpha = 0.6;
			paper.x += 12;
			paper.y += 12;
			var gfx:Graphics = paper.graphics;
			gfx.lineStyle(1, ASColor.MIDNIGHT_BLUE.getRGB(), 0.6);
			gfx.beginFill(papercolor.getRGB(), papercolor.getAlpha());
			gfx.drawRoundRect(0, 0, wIn - 24, hIn - 24, 8);
			addChild(paper);
		}

		return new IntRectangle(cast 46, cast 28, cast wIn - 80, cast hIn - 56);
	}

	/**
	 * 
	 */
	public function createInflatedBackground(infl:Int = 10) 
	{
		rectBound = getMyBounds();
		rectBound.inflate(infl, infl);
		var color = new ASColor(0, 0.001);
		var gfx:Graphics = this.graphics;
		gfx.lineStyle(0,0,0);
		gfx.beginFill(color.getRGB(), color.getAlpha());
		gfx.drawRect(rectBound.x, rectBound.y, rectBound.width, rectBound.height);
		gfx.endFill();
	}

	/**
	 * 
	 * @return
	 */
	public function getMyBounds():Rectangle
	{
		return getBounds(this);
	}

	/**
	 * Draw Background and other decorators
	 * @param	wIn
	 * @param	hIn
	 * @param	bArrowsOnly
	 */
	public function createBackground(?wIn:Float = 0, ?hIn:Float = 0, ?colorIn:ASColor, ?bArrowsOnly:Bool = true)
	{
		spriteDrag = new Sprite();

		rectBound = getMyBounds();
		rectBound.inflate(10, 10);

		colorIn = (cast colorIn) ? colorIn : new ASColor(0, 0.1);
		var gfx:Graphics = spriteDrag.graphics;
		gfx.beginFill(colorIn.getRGB(), colorIn.getAlpha());
		gfx.drawRect(rectBound.x, rectBound.y, rectBound.width, rectBound.height);
		gfx.endFill();
		spriteDrag.visible = false;
		addChild(spriteDrag);
		setChildIndex(spriteDrag, 0);
		Main.root1.addEventListener (MouseEvent.CLICK, mouseClickHandler); // stage used to follow the mouse movement on the desktop
		_onAdjScale(null);
	}


	/**
	 * 
	 * @param	e
	 */
	private function onMouseWheel(e:MouseEvent):Void 
	{
		e.stopPropagation();
		scaleX += e.delta * 0.01;

		scaleY = scaleX;
		refreshButtonsValues();
		_onAdjScale(null);
	}

	function refreshButtonsValues() 
	{
		if (cast adjScale)
		{
			trace("posX : " + x);
			adjScale.adjuster.setValue(cast scaleX * 10);
			adjX.adjuster.setValue(cast x);
			adjY.adjuster.setValue(cast y);
			if (cast menu) setButtonsVisible(menu.visible);
		}
	}

	/**
	 *
	 */
	function setWinPos():Void
	{
		trace("setWinPos X:" + Std.int(x) + ", Y: " + Std.int(y));
		configWidget.XPos 	= Std.int(x);
		configWidget.YPos 	= Std.int(y);
		configWidget.Scale	= scaleX;
		Session.dbConfigWidgets.setConfigWidget(configWidget);

		//if (x < 0 || y < 0)
		//{
			//duplicateWidget();
		//}
//
		//else if (x > 0 && y > 0)
			//duplicateWidget(false);
	}

	/**
	 *
	 * @param	mvc
	 */
	public function setposAndSize(spriteIn:Sprite, mvc:Rectangle, vis:Bool = true, duration:Float = 0.35):Void
	{
		//TweenMax.to(spriteIn, duration, {y: mvc.y, x: mvc.x, width: mvc.width, height: mvc.height, visible: vis});
	}

	/**
	 *
	 */
	public function bringToFront(front:Bool = true):Void
	{
		if (!cast childIndex) {
			childIndex = parent.getChildIndex(this);
		}
		parent.setChildIndex(this, front ? (parent.numChildren - 1) : childIndex);
	}

	/**
	 * 
	 * @return
	 */
	public function getTitleText():String
	{
		return "";
	}
}