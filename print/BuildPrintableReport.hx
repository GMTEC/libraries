package print;

import data.DataObject;
import Date;
import db.DBDefaults;
import db.DBReports.ReportData;
import db.DBTranslations;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.printing.PrintJob;
import flash.printing.PrintJobOptions;
import flash.text.TextFormat;
import haxe.Timer;
import org.aswing.ASColor;
import org.aswing.ASFont;
import org.aswing.AsWingConstants;
import org.aswing.JLabel;
import print.BuildFPDF;
import Session;
import tools.ToolsView;
import util.DateFormat;
import util.DateUtil;
import util.Images;
import widgets.WBase;
import widgets.WPlotWm;

/**
 * ...
 * @author GM
 */


class BuildPrintableReport extends WBase
{
	static var scaleInch:Float = 0.5906;
	var labelsArray			:Map<String, JLabel>;
	var formatsArray		:Array<TextFormat>;
	var bmLogoCust			:Bitmap;
	var printJob			:PrintJob;
	var spriteToPrint		:Sprite;
	var reportNumber		:Int;
	var toolView			:ToolsView;
	var dScale				:Float = 1.3;
	var scaleView			:Float = 0.4;
	var buildFPDF			:BuildFPDF;

	/**
	 * 
	 */
	 function new(name:String)
	{
		super(name);
		
		labelsArray 	= new Map<String, JLabel>();
		formatsArray 	= new Array<TextFormat>();
		toolView 		= new ToolsView("ID_TOOL_REPORT_VIEW", 44, 44, onButZoomPlus, onButZoomMinus, onButPrint, onButCancel);
				
		setRightButtonDragging(true);

		bHook = true;
	}
	
	function onButZoomPlus(e:Dynamic) 
	{
		scaleView 	*= dScale;
		limitScaleView();
		spriteToPrint.scaleY 	= spriteToPrint.scaleX = scaleView;
	}

	function onButZoomMinus(e:Dynamic) 
	{
		scaleView 	/= dScale;
		limitScaleView();
		spriteToPrint.scaleY 	= spriteToPrint.scaleX = scaleView;
	}

	function onButPrint(e:Dynamic) 
	{
		toolView.butPrint.setEnabled(false);
		Main.root1.dispatchEvent(new Event(PanelEvents.PRINT_REPORT));				
	}

	function onButCancel(e:Dynamic) 
	{
		setVisible(false);
	}

	/**
	 * 
	 * @param	reportSelected
	 */
	public function selectReport(reportSelected:Int, plotsWidgets:Array<WPlotWm>) 
	{
		generateReport(reportSelected, plotsWidgets, true);
	}

	/**
	 * 
	 * @param	reportNumber
	 */
	public function viewReport(reportNumber:Int, plotsWidgets:Array<WPlotWm>, butPrint:Bool)
	{
		generateReport(reportNumber, plotsWidgets, butPrint);
		spriteToPrint.scaleX 	= scaleView;
		spriteToPrint.scaleY 	= scaleView;
		setVisible(!isVisible());
	}

	/**
	 * 
	 * @param	reportNumber
	 */
	public function printReport(reportNumber:Int, plotsWidgets:Array<WPlotWm>, butPrint:Bool)
	{
		generateReport(reportNumber, plotsWidgets, butPrint);
		setVisible(false);
		if(isAnyPrintEnabled() || butPrint)
			Timer.delay(startPrint, 500);
	}

	/**
	 * 
	 * @param	reportNumber
	 */
	public function generateReport(reportNumber:Int, plotsWidgets:Array<WPlotWm>, butPrint:Bool)
	{
		if (!cast spriteToPrint) {
			spriteToPrint	= new Sprite();
			spriteToPrint.cacheAsBitmap = true;
			addChild(spriteToPrint);
			addChild(toolView);
			//onButCancel(null);
		}

		this.reportNumber = reportNumber;

		if((cast reportNumber) && isAnyPrintEnabled() || butPrint)
		{
			if (Session.dbReportFormat.isModified())
			{
				Session.dbReportFormat.getFilteredData();
				initialized = false;
			}

			if(!initialized) // Check for file mofification
				initReport();

			addPlotWidgets(plotsWidgets);

			fillReportInfo();
			var index:Int = 1;

			for (dao in Session.channelsArray)
			{
				var dataOb:DataObject = Session.dbChannels.getChannelData(index, reportNumber);
				dataOb.label = dao.label;
				fillChannel(index ++, dataOb);
			}
		}
	}

	/**
	 * 
	 * @return
	 */
	function isPrintOnPrt1Enabled():Bool
	{
		var dao:ReportData = Session.dbReports.lastReportData;

		if (cast dao)
		{
			if (cast (dao.ReportResult)) { return DBDefaults.getBoolParam(Parameters.paramAutoPrintReportNegPrt1); }
			else { return DBDefaults.getBoolParam(Parameters.paramAutoPrintReportPosPrt1); }
		}
		return false;
	}

	/**
	 * 
	 * @return
	 */
	function isPrintOnPrt2Enabled():Bool
	{
		var dao:ReportData = Session.dbReports.lastReportData;

		if (cast dao)
		{
			if (cast (dao.ReportResult)) { return DBDefaults.getBoolParam(Parameters.paramAutoPrintReportNegPrt2); }
			else { return DBDefaults.getBoolParam(Parameters.paramAutoPrintReportPosPrt2); }
		}
		return false;
	}

	/**
	 * 
	 * @return
	 */
	function isAnyPrintEnabled() :Bool
	{
		var bret:Bool = isPrintOnPrt1Enabled() || isPrintOnPrt2Enabled();
		
		return bret;
	}

	/** 
	deep copy of anything 
	**/ 
	public function deepCopy<T>( v:T ) : T 
	{ 
	if (!Reflect.isObject(v)) // simple type 
	{ 
	  return v; 
	} 
	else if( Std.is( v, Array ) ) // array 
	{ 
	  var r = Type.createInstance(Type.getClass(v), []); 
	  untyped 
	  { 
	for( ii in 0...v.length ) 
	  r.push(deepCopy(v[ii])); 
	  } 
	  return r; 
	} 
	else if( Type.getClass(v) == null ) // anonymous object 
	{ 
	  var obj : Dynamic = {}; 
	for( ff in Reflect.fields(v) ) 
	  Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff))); 
	  return obj; 
	} 
	else // class 
	{ 
	  var obj = Type.createEmptyInstance(Type.getClass(v)); 
		for( ff in Reflect.fields(v) ) 
		  Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff))); 
		  return obj; 
	} 
	return null; 
	}
 
	/**
	 * 
	 * @param	plotsWidgets
	 */
	public function addPlotWidgets(plotsWidgets:Array<WPlotWm>) 
	{
		var dX = 40;

		for (widget in plotsWidgets)
		{
			var bmData 	= new BitmapData(cast widget.width, cast widget.height);
			widget.drawBitmapObjectOnBm(bmData);

			var sprite = new Sprite();
			sprite.graphics.beginBitmapFill(bmData);
			sprite.graphics.drawRect(0, 0, bmData.width, bmData.height);
			sprite.addChild(new Bitmap(bmData));
			sprite.x 		= getLabel("ID_RES_REPORT_PLOT").x + dX;
			sprite.y 		= getLabel("ID_RES_REPORT_PLOT").y;
			sprite.scaleX 	= sprite.scaleY = getLabel("ID_RES_REPORT_PLOT").scaleX;
			spriteToPrint.addChild(sprite);
			dX 				+= cast Session.HEIGHT;
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private override function onMouseWheel(e:MouseEvent):Void 
	{
		scaleX += e.delta * 0.01;

		scaleY = scaleX;
	}
	
	/**
	 * 
	 */
	function limitScaleView() 
	{
		if (scaleView > 1.5) scaleView = 1.5;
		else if (scaleView < 0.3) scaleView = 0.3;
	}

	/**
	 * 
	 * @param	x
	 */
	function getScaled(x:Float) : Float {return x * scaleInch; }

	/**
	 * 
	 * @param	x
	 */
	function getScaledX(x:Float) : Float {return x * scaleInch; }

	/**
	 * 
	 * @param	x
	 */
	function getScaledY(y:Float) : Float {return y * scaleInch; }

	/**
	 * 
	 */
	function startPrint() 
	{
		if (!(cast buildFPDF))
			buildFPDF = new BuildFPDF();
		buildFPDF.printBitmap(spriteToPrint);

		if (isPrintOnPrt1Enabled())
			printOnPrinter1();
		
		if (isPrintOnPrt2Enabled())
			printOnPrinter2();

		toolView.butPrint.setEnabled(true);
	}

	/**
	 * 
	 */
	function printOnPrinter1() // PDF Printer
	{
		printOnPrinter(DBDefaults.getStringParam(Parameters.paramPrinterName1));
	}

	/**
	 * 
	 */
	function printOnPrinter2() 
	{
		printOnPrinter(DBDefaults.getStringParam(Parameters.paramPrinterName2));
	}

	/**
	 * 
	 */
	function printOnPrinter(strPrinter:String) 
	{
		var printJob:PrintJob 				= new PrintJob();
		var printJobOptions:PrintJobOptions = new PrintJobOptions();
		printJobOptions.printAsBitmap 		= true;

		printJob.printer = DBDefaults.getStringParam(Parameters.paramPrinterName1);
		var accepted:Bool = printJob.start2(null, false);

		try{
			if (accepted && PrintJob.active)
			{
				spriteToPrint.scaleX = spriteToPrint.scaleY = printJob.pageHeight / spriteToPrint.height;
				printJob.addPage(spriteToPrint, printJobOptions);
				printJob.send();
			}
		}

		catch (unknown : Dynamic )
		{
			trace(unknown);
		}
	}

	/**
	 * 
	 * @return
	 */
	function initReport():Void
	{
		initialized = true;

		var bitmap:Bitmap = Images.loadReportFRBitmap();
		spriteToPrint.addChild(bitmap);

		bmLogoCust = new Bitmap(Images.BmCustomerLogo.bitmapData);

		for (dao in Session.dbReportFormat.reportFormatArray)
		{
			var label:JLabel = new JLabel("?");

			if (dao.name == "ID_DEST_LOGO")
			{
				Images.resize(bmLogoCust, cast getScaled(dao.height));
				bmLogoCust.x = getScaledX(dao.X);
				bmLogoCust.y = getScaledY(dao.Y);
				spriteToPrint.addChild(bmLogoCust);
			}

			labelsArray.set(dao.name, label);
			label.setComBoundsXYWH(cast getScaledX(dao.X), cast getScaledY(dao.Y), cast getScaled(dao.width), cast getScaled(dao.height));
			label.setVerticalAlignment(AsWingConstants.CENTER);

			label.setForeground(new ASColor(dao.color, dao.alpha));
			label.setFont(new ASFont("Arial", dao.size, dao.bold, dao.italic, dao.underline));
			spriteToPrint.addChild(label);
		}
	}

	/**
	 * 
	 * @param	name
	 * @return
	 */
	function getLabel(name:String):JLabel 
	{
		return labelsArray.get(name);
	}

	/**
	 * 
	 */
	public function fillChannel(index:Int, dao:DataObject): Void
	{
		getLabel(index == 1 ? "ID_RES_LEFT_TITLE" 	: "ID_RES_RIGHT_TITLE").setText(cast dao.label);
		getLabel(index == 1 ? "ID_LEFT_MINIMUM" 	: "ID_RIGHT_MINIMUM").setText(cast dao.minimum);
		getLabel(index == 1 ? "ID_LEFT_MAXIMUM" 	: "ID_RIGHT_MAXIMUM").setText(cast dao.maximum);
		getLabel(index == 1 ? "ID_LEFT_BKG" 		: "ID_RIGHT_BKG").setText(cast dao.noise);
		getLabel(index == 1 ? "ID_LEFT_THRESHOLD" 	: "ID_RIGHT_THRESHOLD").setText(cast dao.thresholdCalculated);
	}

	/**
	 * 
	 * @param	str
	 * @param	width
	 * @return
	 */
	function getReportText(str:String, width:Int):String 
	{
		//var html1:String = "<html><body style='width: ";
		//var html2:String = "px'>";

		return DBTranslations.getText(str);
	}

	/**
	 * 
	 * @param	reportNumber
	 */
	public function fillReportInfo() 
	{
		trace("fillReportInfo , reportNumber : " + reportNumber);
		var dao:ReportData = Session.dbReports.getReport(reportNumber);

		getLabel("ID_EXP_DENOM")				.setText("");
		getLabel("ID_EXP_ADDRESS")				.setText("");
		getLabel("ID_EXP_CITY")					.setText("");
		getLabel("ID_EXP_CP")					.setText("");
		getLabel("ID_EXP_COUNTRY")				.setText("");

		getLabel("ID_REP_NUMBER")				.setText(cast reportNumber);
		getLabel("ID_REP_DATE")					.setText(DateFormat.getDateString(dao.TimeOut));
		getLabel("ID_REP_TIME")					.setText(DateFormat.getTimeString(dao.TimeOut));

		getLabel("ID_RES_REPORT_POS")			.setText((cast dao.ReportResult) ?  getReportText("IDS_MSG_REPORT_POSITIVE", cast (getLabel("ID_RES_REPORT_NEG").width)) : " ");
		getLabel("ID_RES_REPORT_NEG")			.setText((cast dao.ReportResult) ? " " : getReportText("IDS_MSG_REPORT_NEGATIVE", cast (getLabel("ID_RES_REPORT_NEG").width)));
		getLabel("ID_RES_REPORT_POS")			.setText((cast dao.ReportResult) ? getReportText("IDS_MSG_REPORT_POSITIVE", cast(getLabel("ID_RES_REPORT_POS").width)) :  " ");

		getLabel("ID_TRA_REGISTRATION")			.setText(dao.VehicleRegistration);
		getLabel("ID_TRA_VEHICLE_ID")			.setText(dao.VehicleID);
		getLabel("ID_TRA_CMR")					.setText(dao.CMR);
		getLabel("ID_TRA_COMMENT")				.setText(dao.Comment);

		getLabel("ID_INST_REFERENCES")			.setText(DBTranslations.getText("IDS_MSG_CALIBRATED") + DateUtil.getStringDate((DBDefaults.getStringParam(Parameters.paramCalibrationDate))));
		getLabel("ID_REM")						.setText("");

		getLabel("ID_PRINT_DATE")				.setText(DateUtil.getStringDate(Date.now().toString()));
	}

	public function isSelected() : Bool
	{
		return (cast spriteToPrint) ? isVisible() : false;
	}
}