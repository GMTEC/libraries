package util;

/**
 * ...
 * @author GM
 * 
 */
import enums.Enums.MinMax;
import flash.display.Bitmap;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import org.aswing.ASColor;
import org.aswing.JLabel;
import util.plot.GestureSprite;
import util.plot.GraphXYZ;
import util.plot.PlotBase;

class PlotGraph extends PlotBase
{
	public var filmForeground : GestureSprite;
	public var filmMask : Sprite;
	public var filmWhiteBack : Sprite;
	public var filmBack : Sprite;
	public var cursor:Sprite;
	public var cursorLine:Sprite;

	public var filmGridX : Sprite;
	public var filmGridY : Sprite;
	var plotColor:ASColor;
	private var colorBackground:ASColor;
	var shiftValues:Bool;
	var XShiftOfst:Float = 0;
	
	public var XIncrement:Float = 1;
	public var YIncrement:Float = 1;
	//public var text1:fl.controls.Button;
	//
	public var pushVal : Float;
	public var pushTemp : Float;
	public var X : Float;
	public var Y : Float;
	public var XOrigin : Float;
	public var GraphWidth : Float;
	public var GraphHeight : Float;
	public var XGridIncrement : Float;
	public var YMin : Float;
	public var YMax : Float;
	public var maxValueY:Float;
	public var minValueY:Float;
	// Scales
	public var YScale : Float;
	public var YScaleLog : Float;
	public var XScale : Float;
	// Offsets
	//public var XOffset : Int;
	public var YOffset : Float;
	public var MaxXCounts : Float;
	public var XMinGabarit : Float;
	public var YMinGabarit : Float;
	public var XMaxGabarit : Float;
	public var YMaxGabarit : Float;
	// Alarms
	public var YHighAlarm : Float;
	public var YHighAlarmSet : Bool;
	//
	// Time:
	public var XMin : Int;
	public var XMax : Int;
	public var YLowAlarm : Int;
	public var LineWidth : Int;
	public var distriValues : Array<Dynamic>;
	public var Gabarit : Array<Dynamic>;
	public var LastY : Int;
	public var LastX : Int;
	public var PreviousValue : Int;
	public var LineOpacity : Float;
	public var opaqueWhiteBackground:Bool;
	public var maxOrMinValueYModified:Bool;
	public var logoMode:Bool;
	public var linearScale:Bool;
	public var timedXValues:Bool;

	var tfTitle1:JLabel;
	var tfTitle2:JLabel;
	var tfTitle3:JLabel;
	var mouseVal:JLabel;

	var xLabels:Array<JLabel>;
	var yLabels:Array<JLabel>;
	
	var XAxeLabel:JLabel;
	var YAxeLabel:JLabel;

	var drawRoundRectSize:Int = 1;
	var XOfst:Float;
	var arrayValues:Array<Dynamic>;
	var strXLabel:String;
	var strYLabel:String;
	
	var YScaleLin:Float;
	var bBackgroundColor = false;
	var bmBackground:Bitmap;
	var labelsSprite:Sprite;
	var mouseMoveFunc		:MouseEvent->Void;

	/**
	 * 
	 */
	public function new()
	{
		super();
		
		linearScale = true;
	
		tfTitle1 		= new JLabel(); // Trigger
		tfTitle2 		= new JLabel(); // Value
		tfTitle3		= new JLabel(); // Bkg		

		plotColor 		= new ASColor(ASColor.CLOUDS.getRGB(), 1);
		shiftValues 	= true;

		YScale			= YScaleLin = YScaleLog = 1;

		YOffset 		= 0;
		YHighAlarm 		= 70;
		YHighAlarmSet 	= false;
		LineWidth 		= 2;
		Gabarit 		= new Array<Dynamic>();
		LineOpacity 	= 0.35;
		Multitouch.inputMode = MultitouchInputMode.GESTURE;
		filmGridX 		= new Sprite();
		filmGridY 		= new Sprite();
		labelsSprite 	= new Sprite();
		filmWhiteBack 	= new Sprite();
		filmBack 		= new Sprite();
		filmMask 		= new Sprite();

		xLabels 		= new Array();
		yLabels 		= new Array();

		arrayValues 	= new Array<Dynamic>();
		distriValues 	= new Array<Dynamic>();
	}

	/**
	 * 
	 */
	public function initLabels():Void
	{
		if (strXLabel == null)
			return;
		XAxeLabel 			= new JLabel(strXLabel);
		YAxeLabel 			= new JLabel(strYLabel);

		XAxeLabel.setFont(XAxeLabel.getFont().changeSize(12));
		YAxeLabel.setFont(XAxeLabel.getFont().changeSize(12));

		YAxeLabel.setComBoundsXYWH(-30, -32, 34, 16);
		XAxeLabel.setComBoundsXYWH(cast GraphWidth + 2, cast GraphHeight - 12, 34, 12);

		labelsSprite.addChild(XAxeLabel);
		labelsSprite.addChild(YAxeLabel);
	}

	/**
	 * 
	 * @param	strXLabel
	 * @param	strYlabel
	 */
	public function setLabels(strX:String, strY:String):Void
	{
		if (!logoMode)
		{
			strXLabel = strX;
			strYLabel = strY;
		}
	}

	/**
	 *
	 * @param	Graph
	*/
	public function init(xIn:Int, yIn:Int, wIn:Int, hIn:Int, bOverlay:Bool = false, ?mouseMoveFunc:MouseEvent->Void) : Void
	{
		this.mouseMoveFunc = mouseMoveFunc;
	
		XOrigin 		= xIn;
		X 				= XOrigin;
		Y 				= yIn;

		eraseValues();
		GraphWidth		= wIn;
		GraphHeight		= hIn;

		MaxXCounts 		= wIn;
		overlayGraph 	= bOverlay;

		createValuesMask();

		if (!logoMode)
		{
			var dX:Int = cast(GraphWidth / 3);
			tfTitle1.setComBoundsXYWH(0, -18,  cast GraphWidth / 3, 16);
			tfTitle2.setComBoundsXYWH(dX, -18,  cast GraphWidth / 3, 16);
			tfTitle3.setComBoundsXYWH(2 * dX, -18,  cast GraphWidth / 3, 16);
		}

		if (!overlayGraph)
		{
			initLabels();
			addChild(filmWhiteBack);
			addChild(filmBack);

			addChild(filmGridX);
			addChild(filmGridY);
			filmGridY.mask = filmMask;

			if (!logoMode)
			{
				labelsSprite.addChild(tfTitle1);
				labelsSprite.addChild(tfTitle2);
				labelsSprite.addChild(tfTitle3);
			}

			filmBack.mask = filmMask;

			drawWhiteBackground();
			drawBackgroundImage(colorBackground);
			drawForeground(0x808080);
			createLabels();
		}

		filmValues.mask = filmMask;
		addChild(filmMask);
		addChild(labelsSprite);
		addChild(filmValues);		

		mouseVal	= new JLabel(); // Value under Mouse Cursor
		mouseVal.setFont(mouseVal.getFont().changeSize(10));
		drawCursor();
		mouseVal.setComBoundsXYWH(20, 10, 40, 16);
		addChild(cursor);
		addChild(mouseVal);
	
		if (cast filmForeground) {

			drawCursorLine();
			addChild(cursorLine);
			addChild(filmForeground); // mask for gesture
		}
	}

	/**
	 * 
	 */
	function createValuesMask() 
	{
		var gfx = filmMask.graphics;
		gfx.beginFill(0xffffff);
		gfx.drawRoundRect(X, Y, GraphWidth + 4, GraphHeight + 4, drawRoundRectSize);
		gfx.endFill();
	}

	/**
	 * 
	 */
	function createLabels()
	{
		var textField:JLabel;
		var labelHeight:Int = timedXValues ? 24 : 12;

		for (index in 0...11)
		{
			// X Label
			textField 					= new JLabel();
			textField.setFont(XAxeLabel.getFont().changeSize(10));
			textField.setComBoundsXYWH(0, cast GraphHeight + y + 6, 42, labelHeight);
			textField.visible			= !logoMode;

			labelsSprite.addChild(textField);
			xLabels.push(textField);

			// Y Label
			textField 					= new JLabel();			
			textField.setFont(XAxeLabel.getFont().changeSize(10));
			textField.setComBoundsXYWH(-38, 0, 42, 12);
			textField.visible			= !logoMode;

			labelsSprite.addChild(textField);
			yLabels.push(textField);
		}

		setDrawingOnScreen();
	}

	/**
	 * 
	 * @param	Value
	 */
	public function CheckRangeAndSetAlarm(Value : Int) : Void
	{
		if(YHighAlarm > 0) 
		{
			if(!YHighAlarmSet && Value > YHighAlarm) 
			{
				YHighAlarmSet = true;
				//sound0.play();
			}

			else 
			{
				if(Value < YHighAlarm) 
				{
					YHighAlarmSet = false;
				}
			}
		}
	}

	/**
	 * 
	 * @param	valY
	 * @param	valX
	 * @param	valZ
	 */
	public function pushValue(?valX : Int, ?dateIn:Date, ?valY : Int, ?valZ : Int = 0, ?event : Int = 0, ?calcMinMax:Bool = false) : Void
	{						
		if (shiftValues && arrayValues.length >= MaxXCounts)
		{
			arrayValues.shift(); // Shift values if array full;
			XShiftOfst ++;
		}

		if (calcMinMax)
		{
			adjustMaxValue(valY);
			adjustMinValue(valY);
		}

		arrayValues.push(new GraphXYZ(valX, valY, (cast dateIn) ? dateIn.getTime(): 0));
	}

	function adjustMaxValue(value:Int) 
	{
		if (value > maxValueY)
		{
			maxValueY = value * 1.1;
			maxOrMinValueYModified = true;
		}
	}

	function adjustMinValue(value:Int) 
	{
		if (value < minValueY)
		{
			minValueY = value / 1.1;
			maxOrMinValueYModified = true;
		}
	}

	/**
	 * 
	 * @param	colBack
	 */
	public function drawForeground(colBack : Int) : Void
	{
		filmForeground 	= new GestureSprite(mouseMoveFunc);
		var gfx = filmForeground.graphics;
		gfx.clear();
		gfx.lineStyle(2, 0x101010);
		gfx.beginFill(colBack);
		gfx.drawRect(X, Y, GraphWidth, GraphHeight);
		gfx.endFill();
		filmForeground.alpha = 0.01;
	}

	/**
	 * 
	 * @param	colBack
	 */
	function drawCursor() : Void
	{
		cursor	= new Sprite(); // Value under Mouse Cursor
		cursor.visible = false;
		var gfx = cursor.graphics;
		gfx.clear();
		gfx.lineStyle(1, ASColor.PUMPKIN.getRGB());
		gfx.beginFill(ASColor.PUMPKIN.getRGB());
		gfx.drawRect( -2, -2, 4, 4);
		gfx.endFill();
	}
	
	/**
	 * 
	 * @param	colBack
	 */
	function drawCursorLine() : Void
	{
		cursorLine	= new Sprite(); // Value under Mouse Cursor
		cursorLine.visible = false;
		var gfx = cursorLine.graphics;
		gfx.clear();
		gfx.lineStyle(1, ASColor.TURQUOISE.getRGB());
		gfx.moveTo(0, 0);
		gfx.lineTo(0, this.GraphHeight);
	}

	/**
	 * 
	 */
	function drawWhiteBackground() : Void
	{
		if (opaqueWhiteBackground)
		{
			//var gfx = filmWhiteBack.graphics;
			//gfx.beginFill(ASColor.CLOUDS.getRGB());
			//gfx.drawRoundRect(X, Y, GraphWidth, GraphHeight, drawRoundRectSize);
			//gfx.endFill();
		}
	}

	/**
	 * 
	 * @param	txtIn
	 */
	public function setTitle(arIn:Array<String>):Void
	{
		tfTitle1.setText(arIn[0]);
		tfTitle2.setText(arIn[1]);
		tfTitle3.setText(arIn[2]);
	}

	/**
	 * 
	 */
	function drawBackgroundImage(?color:ASColor)
	{
		if (bBackgroundColor)
		{
			var gfx = filmBack.graphics;

			if (!cast color) color = new ASColor(ASColor.EMERALD.getRGB(), 1); // Default Green Color

			gfx.clear();
			gfx.lineStyle(LineWidth, ASColor.MIDNIGHT_BLUE.getRGB(), 1);
			gfx.beginFill(color.getRGB(), 1);
			gfx.drawRoundRect(X, Y, GraphWidth, GraphHeight, drawRoundRectSize);
			gfx.endFill();
		}
	}

	/**
	 * 
	 * @param	Min
	 * @param	Max
	 */
	public function setXRange(Min : Float, Max : Float) : Void
	{
		if (XMinSet != Min || XMaxSet != Max)
		{
			XMinSet = Min;
			XMaxSet = Max;

			if(Min == Max)
				XScale = 1;
			else
				XScale = GraphWidth / (XMaxSet - XMinSet - 1);

			var fl:Float = GraphWidth / XScale;
			MaxXCounts = Std.int(fl);
			XOfst = Std.int(startIndex * XScale);

			if (!overlayGraph)
				drawXScaleValues();
		}
	}

	/**
	 * 
	 * @param	Min
	 * @param	Max
	 */
	public function setYRange(minMax:MinMax) : Void
	{
		var Min = minMax.minValue;
		var Max = minMax.maxValue;

		if (YMin != Min || YMax != Max)
		{
			if (Min == Max) Max = Min * 2;
			YMin 		= Min;
			YMax 		= Max;
			maxValueY 	= YMax;
			//trace("YMin : " + YMin);
			//trace("YMax : " + YMax);

			if (Min == Max)
			{
				YScaleLin 	= 1;
				YScaleLog 	= GraphHeight / 10;
			}
			else
			{
				YScaleLin	= GraphHeight / (YMax - YMin);
				YScaleLog 	= GraphHeight / 10;
			}
	
			YScale		= linearScale ? YScaleLin : YScaleLog;

			if (!overlayGraph )
				drawYScaleValues();
		}
	}

	/**
	 * 
	 */
	public function drawGrid():Void 
	{
		drawYScaleValues();
		drawXScaleValues();
	}

	/**
	 * 
	 */
	function drawYScaleValues()
	{
		var gfx 			= filmGridY.graphics;
		gfx.clear();
		gfx.lineStyle(0.4, ASColor.GRAY.getRGB(), 1);

		var dY:Float 		= ((YMax - YMin) / 10) ;

		var YGrid : Float 	= YMax * YScale;
		var dYGrid:Float 	=  dY * YScale;
		var curYValue:Float = YMin;

		YGrid = GraphHeight;
		dYGrid = GraphHeight / 10;
		var toggle:Bool = false;

		// Horizontal Lines, this is OK:

		for (label in yLabels)
		{
			var iX:Int 				= cast curYValue;
			label.setText(cast iX);
			label.y = YGrid - 4;
			label.visible 	= !logoMode && (toggle = !toggle);
			curYValue 				+= dY;

			gfx.moveTo(0, YGrid);
			gfx.lineTo(X + GraphWidth, YGrid);
			YGrid 					-= dYGrid;
		}
	}

	/**
	 * 
	 */
	function drawXScaleValues() 
	{
		var gfx = filmGridX.graphics;
		gfx.clear();

		gfx.lineStyle(0.4, ASColor.GRAY.getRGB(), 1);

		var dX 			: Float; // X Grid Start position
		var XGrid 		: Float = 0; // X Grid Start position

		// Draw vertical lines :

		var diffX:Float = cast XMaxSet - XMinSet;

		var maxGridLines:Int = (xLabels.length - 1);
		var values:Float;

		if (diffX > maxGridLines)
		{
			values = maxGridLines;
			dX = diffX / values;
		}
		else {
			 values = (XMaxSet - XMinSet);
			 dX = 1;
		}

		for (label in xLabels) label.visible = false;

		if (values >= xLabels.length)
			values = xLabels.length - 1;

		timedXValues ? drawTimedXScaleValues(gfx, values, XMin, XGrid) : drawIndexedXScaleValues(gfx, values, XMin, XGrid, dX);
	}

	/**
	 * 
	 * @param	gfx
	 * @param	values
	 */
	function drawIndexedXScaleValues(gfx:Graphics, values:Float, curXValue:Float, XGrid:Float, dX:Float) 
	{
		var dXGrid:Float 	=  GraphWidth / values;

		for (index in 0...cast values + 1)
		{
			var iX:Int = cast curXValue;
			xLabels[index].visible = true;
			xLabels[index].setText(cast iX);
			xLabels[index].x = x + XGrid - 22;
			curXValue += dX;

			gfx.moveTo(XGrid, 0);
			gfx.lineTo(XGrid, GraphHeight);
			XGrid += dXGrid;
		}	
	}

	/**
	 * 
	 * @param	gfx
	 * @param	values
	 */
	function drawTimedXScaleValues(gfx:Graphics, values:Float, curXValue:Float, XGrid:Float) 
	{
		var dXGrid:Float 	= GraphWidth / values;
		var valScale:Float 	= arrayValues.length / (values + 1);

		for (index in 0...cast values + 1)
		{
			xLabels[index].visible = true;
			var valXYZ:GraphXYZ = arrayValues[cast(valScale * index)];

			xLabels[index].setText(DateFormat.getTimeString(Date.fromTime(valXYZ.Z), false) + '\n' + DateFormat.getDateMonthString(Date.fromTime(valXYZ.Z)));
			xLabels[index].x = x + XGrid - 22;
			gfx.moveTo(XGrid, 0);
			gfx.lineTo(XGrid, GraphHeight);
			XGrid += dXGrid;
		}	
	}

	function initGraphicStyles() : Void
	{
		filmValues.graphics.lineStyle(LineWidth, plotColor.getRGB(), plotColor.getAlpha());
	}

	/**
	 * 
	 */
	public function eraseValues() : Void
	{
		resetMinAndMaxYValues();
		XShiftOfst = 0;
		startIndex = 0;
		MaxXCounts = 1024;
		LastX = 0;
		LastY = 0;
		XMaxSet = 0;
		XMinSet = 0;
		XMin = Std.int(Math.POSITIVE_INFINITY);
		XMax = 0;
		YMin = XMin;
		YMax = XMax;
		arrayValues 	= new Array<Dynamic>();
		filmValues.graphics.clear();
	}

	/**
	 * 
	 */
	public function resetMinAndMaxYValues() 
	{
		maxValueY = 0;
		minValueY = Math.POSITIVE_INFINITY;
	}

	/**
	 * 
	 * @param	bTimed
	 */
	public function drawValues(bTimed:Bool = false) : Void
	{
		if (arrayValues.length == 0)
			return;

		var gfx = filmValues.graphics;
		gfx.clear();
		var tempXY : GraphXYZ = arrayValues[startIndex];
		gfx.moveTo(valueToX(tempXY.X), valueToY(tempXY.Y));
		var index : Int;

		index = startIndex + 1;

		initGraphicStyles();

		while(index < arrayValues.length)
		{
			gfx.lineTo(valueToX(arrayValues[index].X), valueToY(arrayValues[index].Y));
			index++;
		}
	}

	/**
	 * 
	 * @param	val
	 * @return
	 */
	function valueToX(val : Float) : Float
	{
		var ret:Float = XOrigin  + ((val - XShiftOfst) * XScale) - XOfst;

		return ret;
	}
	
	/**
	 * 
	 * @param	val
	 * @return
	 */
	function valueFromX(val : Float) : Float
	{
		var ret:Float = XOrigin  + ((val - XShiftOfst) / XScale) - XOfst;

		return ret;
	}

	/**
	 * 
	 * @param	val
	 * @return
	 */
	function valueToY(val : Float) : Float
	{
		var ret:Float;
	
		if (linearScale)
			ret = GraphHeight - (YScale * (val - YMin));
		else
			ret = GraphHeight - (YScale *  Math.log(Math.abs(val - YMin)/Math.log(10)));

		//trace("Value : " + ret);
		return ret;
	}

	/**
	 * 
	 * @param	val
	 * @return
	 */
	function valueFromY(val : Float) : Float
	{
		var ret:Float;
	
		if (linearScale)
			ret = GraphHeight - ((val - YMin) * YScale);
		else
			ret = GraphHeight - (Math.log(Math.abs(val - YMin)/Math.log(10)) * YScale);

		//trace("Value : " + ret);
		return ret;
	}

	/**
	 * 
	 * @param	val
	 * @return
	 */
	function valueDistriToX(val : Int) : Int
	{
		var fl:Float = XDistriOrigin + ((val - XMin) * XDistriScale);
		
		return Std.int(fl);
	}

	/**
	 * 
	 * @param	val
	 * @return
	 */
	function valueDistriToY(val : Int) : Int
	{
		////trace((GraphHeight - (YDistriScale * (val - YMin)));
		var fl:Float = GraphHeight + 24 - (YDistriScale * (val - YMin));

		return Std.int(fl);
	}

	/**
	 * Return a random integer between limits min. and max.
	 * @param	min
	 * @param	max
	 * @return
	 */
	public function randRange(min : Int, max : Int) : Int
	{
		var randomNum : Int = Math.floor(Math.random() * (max - min + 1)) + min;
		return randomNum;
	}

	/**
	 * 
	 * @param	col
	 * @param	alpha
	 */
	public function setColorBackground(col:ASColor = null) 
	{
		bBackgroundColor = true;

		if (col != colorBackground)
		{
			colorBackground = (col == null) ? ASColor.EMERALD : col;
			//drawBackgroundImage(colorBackground);
		}
	}

	public function getMaxY() 
	{
		return YMax;
	}

	public function getCountX() : Int
	{
		return arrayValues.length;
	}

	/**
	 * 
	 * @param	linear
	 */
	public function setlinearScale(linear:Bool) 
	{
		linearScale = linear;
		YScale		= linearScale ? YScaleLin : YScaleLog;
	}

	public function setPlotColor(color:ASColor, textLabelIndex:Int = 0) 
	{
		plotColor = color;

		if (!logoMode)
		{
			if (textLabelIndex == 0) {tfTitle1.setForeground(color); return; }
			if (textLabelIndex == 1) {tfTitle2.setForeground(color); return; }
			if (textLabelIndex == 2) { tfTitle3.setForeground(color); return; }
		}
	}

	/**
	 * 
	 * @param	bm
	 */
	public function setBackgroundBitmap(bm:Bitmap, x:Int, y:Int)
	{
		bmBackground 		= bm;
		bmBackground.x 		= x;
		bmBackground.y 		= y;
		bmBackground.alpha	= 0.6;

		addChild(bmBackground);
		bmBackground.filters = Filters.filterWhiteShadow;
	}

	/**
	 * 
	 * @param	radioActivity
	 */
	public function setBackgroundBitmapVisible(radioActivity:Bool) 
	{
		bmBackground.visible = radioActivity;
	}

	/**
	 * 
	 */
	public function setDrawingOnPaper() 
	{
		for (label in xLabels) {
			label.setForeground(ASColor.BLACK);
			label.paintImmediately();
		}

		for (label in yLabels) {
			label.setForeground(ASColor.BLACK);
			label.paintImmediately();
		}

		XAxeLabel.setForeground(ASColor.BLACK);
		YAxeLabel.setForeground(ASColor.BLACK);

		XAxeLabel.paintImmediately();
		YAxeLabel.paintImmediately();
	}

	/**
	 * 
	 */
	public function setDrawingOnScreen() 
	{
		for (label in xLabels) {
			label.setForeground(ASColor.CLOUDS);
			label.paintImmediately();
		}

		for (label in yLabels) {
			label.setForeground(ASColor.CLOUDS);
			label.paintImmediately();
		}

		XAxeLabel.setForeground(ASColor.CLOUDS);
		YAxeLabel.setForeground(ASColor.CLOUDS);

		XAxeLabel.paintImmediately();
		YAxeLabel.paintImmediately();
	}

	/**
	 * 
	 * @param	e
	 */
	public function showValuesUnderCursor(e:MouseEvent = null) 
	{
		if (e.localX < 0 || e.localX > GraphWidth || e.localY < 0 || e.localY > GraphHeight) {
			mouseVal.setText("");
			cursor.visible 		= false;

			if (cast filmForeground) {
				cursorLine.visible 	= false;
			}
		}
		else if ((cast e) && cast arrayValues.length) {

			var index:Int 		= cast Math.min(valueFromX(e.localX), arrayValues.length - 1);
			if (index < 0) index = 0;
			var graphXY:GraphXYZ = arrayValues[index];
			cursor.x		= e.localX;
			cursor.y		= valueFromY(graphXY.Y);
			mouseVal.x 		= e.localX - 15;
			mouseVal.y 		= cursor.y - 15;
			mouseVal.setText(cast graphXY.Y);
			cursor.visible = true;

			if (cast filmForeground) {
				cursorLine.visible = true;
				cursorLine.x	= e.localX;
		
			}
		}
	}

	/**
	 * 
	 */
	function pu() : Void
	{
		if(LastY > PreviousValue) 
		{
			filmValues.graphics.lineStyle(LineWidth, ASColor.ALIZARIN.getRGB(), LineOpacity);
			PreviousValue = LastY;
		}

		else 
		{
			if(LastY < PreviousValue) 
			{
				filmValues.graphics.lineStyle(LineWidth, ASColor.BELIZE_HOLE.getRGB(), LineOpacity);
				PreviousValue = LastY;
			}

			else 
			{
				filmValues.graphics.lineStyle(LineWidth, ASColor.EMERALD.getRGB(), LineOpacity);
			}
		}
	}
}

