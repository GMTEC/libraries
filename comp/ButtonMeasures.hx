package comp;
import enums.Enums.MinMax;
import events.PanelEvents;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import util.Images;
import widgets.WPlotRefreshed;

/**
 * ...
 * @author GM
 */
class ButtonMeasures extends ButtonMenu
{
	var plotWidget:		WPlotRefreshed;
	var minMaxPlot:		MinMax;

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
	public function new(bmDataIn:Bitmap, label:String, xIn:Int, yIn:Int, bitmapName:Bool = true, wIn:Int = 48, hIn:Int = 48) 
	{	
		minMaxPlot = new MinMax();
		W 			= 32;

		for (channel in Session.channelsArray)
		{
			plotWidget = new WPlotRefreshed("", channel);
			break;
		}

		plotWidget.setLogoMode();
		plotWidget.init(cast W, cast W, 0, 8, 200, Math.POSITIVE_INFINITY);
		plotWidget.x 		+= 11;
		plotWidget.y 		+= 20;

		super(bmDataIn, label, xIn, yIn, bitmapName = true, wIn = 48, hIn = 48);

		Main.root1.addEventListener(PanelEvents.EVT_DATA_REFRESH, onDataRefresh);
		Main.root1.addEventListener(PanelEvents.EVT_BKG_ELAPSED, onInitElapsed);
	}

	/**
	 * 
	 * @param	e
	 */
	public function onDataRefresh(e:ParameterEvent)
	{
		var modified:Bool = false;

		if (plotWidget.graphVal.maxValueY > minMaxPlot.maxValue)
		{
			minMaxPlot.maxValue = plotWidget.graphVal.maxValueY;
			modified = true;
		}

		if (plotWidget.graphTrg.maxValueY > minMaxPlot.maxValue)
		{
			minMaxPlot.maxValue = plotWidget.graphTrg.maxValueY;
			modified = true;
		}

		if (plotWidget.graphVal.minValueY < minMaxPlot.minValue)
		{
			minMaxPlot.minValue = plotWidget.graphVal.minValueY;
			modified = true;
		}

		if (modified)
		{
			plotWidget.setYRange(minMaxPlot.rounded(100));
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function onInitElapsed(e:Event):Void 
	{
		minMaxPlot.reset();

		plotWidget.resetMinAndMaxYValues();
		plotWidget.drawGrid();
	}

	/**
	 * 
	 * @param	bmDataIn
	 */
	public function setBitmapData(bmDataIn:BitmapData):Void 
	{
		bmLogo.bitmapData = bmDataIn;
		Images.resize(bmLogo, cast W, cast W);
	}
}