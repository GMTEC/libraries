package tools;
import db.DBBase;
import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.data.SQLResult;
import flash.events.DataEvent;
import flash.events.Event;
import icon.IconFromBm;
import openfl.events.TextEvent;
import org.aswing.border.EmptyBorder;
import org.aswing.event.InteractiveEvent;
import org.aswing.ext.DateChooser;
import org.aswing.geom.IntRectangle;
import org.aswing.Insets;
import org.aswing.JFrame;
import org.aswing.util.DateAs;
import panescenter.WReport.DateType;
import tools.WTools.ToolButton;
import util.DateUtil;
import util.Filters;
import util.Images;
import util.ScreenManager;
import widgets.WSearchDlg;

/**
 * ...
 * @author GM
 */
class ToolSQLDated extends ToolSQL
{

	var toolChooserDate		:ToolsVertWidget;
	var dateSelected		:Array<DateAs>;
	var datesFrom			:Array<DateAs>;
	var datesTo				:Array<DateAs>;
	var dateSelectedTo		:DateAs;
	var dateLabelOnTable	:String;
	var dateChooserFrame	:JFrame;
	var dateChooser			:DateChooser;
	var bSingleDate			:Bool;
	var iconSingleDate		:IconFromBm;
	var iconDateFromTo		:IconFromBm;
	var butDate:ToolButton;
	var butDateTo:ToolButton;
	var butDateFrom:ToolButton;

	public function new(name:String, ?func:SQLResult->Void) 
	{
		super(name, func);

		bSingleDate 		= true;
		dateSelected		= new Array <DateAs>();
		dateSelectedTo		= new DateAs();
		datesFrom			= new Array <DateAs>();
		datesTo				= new Array <DateAs>();

		dateSelected[0] 	= new DateAs();
		datesFrom[0] 		= new DateAs();
		datesTo[0] 			= new DateAs();
		setTodayDate();

		datesFrom[0].setTime(DateUtil.getDate(DBDefaults.getStringParam(Parameters.paramReportsStartDate)).getTime());
		datesTo[0].setTime(DateUtil.getDate(DBDefaults.getStringParam(Parameters.paramReportsEndDate)).getTime());

		toolChooserDate		= new ToolsVertWidget("ID_PLOT_TOOL_REPORT"); // 100, 8

		butDate 		= push(Images.loadSQLDate(), 		null,  							" ", "IDS_TT_MENU_DATE", 	onButDateSelected);
		butDateFrom 	= push(Images.loadSQLDateFrom(), 	null, 							" ", "IDS_TT_MENU_FROM", 	onButDateFrom);
		butDateTo		= push(Images.loadSQLDateTo(), 		null, 	 						" ", "IDS_TT_MENU_TO",	 	onButDateTo);
	}

	/**
	 * 
	 * @param	e
	 */
	private override function onSearchOnText(e:TextEvent):Void 
	{
	}


	/**
	 * 
	 */
	public override function init():Void {
		bSingleDate = false;
		super.init();
	}

	/**
	 * 
	 * @param	object
	 */
	function incrementSelectionDate(inc:Int) 
	{
		if (bSingleDate)
		{
			DateUtil.incrementDays(dateSelected[0], inc);
			DateUtil.incrementDays(dateSelectedTo, inc);
		}
		else {
			DateUtil.incrementDays(datesFrom[0], inc);
			DateUtil.incrementDays(datesTo[0], inc);
		}

		applyFilters();
	}

	/**
	 * 
	 * @return
	 */
	public override function getIconSQL():IconFromBm 
	{
		return iconCurrent;
	}

	/**
	 * 
	 * @return
	 */
	public override function getTextSQL():String 
	{
		return dateLabelOnTable;
	}

	/**
	 * 
	 * @param	e
	 */
	function onButDateSelected(e:Dynamic):Void 
	{
		bSingleDate = true;
		onButDateChooser("IDS_CHOOSE_DATE", changeDate, DateType.SINGLE);
	}

	/**
	 * 
	 * @param	e
	 */
	function onButDateFrom(e:Dynamic):Void 
	{
		bSingleDate = false;
		onButDateChooser("IDS_CHOOSE_START_DATE", changeFrom, DateType.FROM);
	}

	/**
	 * 
	 * @param	e
	 */
	function onButDateTo(e:Dynamic):Void 
	{

		bSingleDate = false;
		onButDateChooser("IDS_CHOOSE_END_DATE", changeTo, DateType.TO);
	}
	
	/**
	 * 
	 * @param	e
	 */
	public override function hideDialogs(e:Event):Void 
	{
	}

	/**
	 * 
	 * @param	e
	 */
	function onButDateChooser(title:String, func:Dynamic->Void, bDateTo:DateType):Void 
	{
		if (dateChooserFrame == null)
		{
			dateChooserFrame = new JFrame(Main.widgetBig, "");
			dateChooserFrame.setLocationXY(60, 120);
	
			dateChooserFrame.setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE);
			dateChooserFrame.setMaximizedBounds(new IntRectangle(0, 0, 400, 400));
			//dateChooser = new DateChooser(toolChooserDate);
			dateChooser = new DateChooser();
			dateChooser.setDayNames(DBTranslations.getDayNames());
			dateChooser.setMonthNames(DBTranslations.getMonthNames());
			dateChooser.setAllowMultipleSelection(false);
			dateChooser.setBorder(new EmptyBorder(null, new Insets(4)));
			dateChooserFrame.setContentPane(dateChooser);

			dateChooserFrame.pack();
			dateChooser.addEventListener(InteractiveEvent.SELECTION_CHANGED, func);
			dateChooserFrame.filters = Filters.centerWinFilters;
		}

		dateChooserFrame.setTitle(DBTranslations.getText(title));
		dateChooserFrame.show();
		if(cast oldFunc) dateChooser.removeEventListener(InteractiveEvent.SELECTION_CHANGED, oldFunc);
		dateChooser.addEventListener(InteractiveEvent.SELECTION_CHANGED, func);
		oldFunc = func;

		dateChooser.setSelectedDate		(getDateFromType(bDateTo));
		dateChooser.setDisplayDate(getDateFromType(bDateTo).getFullYear(), getDateFromType(bDateTo).getMonth());
	}

	/**
	 * 
	 * @param	bDateTo
	 * @return
	 */
	function getDateFromType(bDateTo:DateType):DateAs 
	{
		switch (bDateTo)
		{
			case DateType.SINGLE: 	return dateSelected[0];
			case DateType.FROM: 	return datesFrom[0];
			case DateType.TO: 		return datesTo[0];
		}
	}


	/**
	 * 
	 * @param	e
	 */
	private function changeDate(e:InteractiveEvent):Void 
	{
		if (!e.isProgrammatic())
		{
			dateSelected 	= cast dateChooser.getSelectedDates();
			adjustDateSelectedTo();
			changeFromTo(dateSelected[0], e.isProgrammatic());
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function changeFrom(e:InteractiveEvent):Void 
	{
		if (!e.isProgrammatic())
		{
			datesFrom 	= cast dateChooser.getSelectedDates();
			datesFrom[0].setFullYear(dateChooser.getDisplayedYear());
			changeFromTo(datesFrom[0], e.isProgrammatic());
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function changeTo(e:InteractiveEvent):Void 
	{
		if (!e.isProgrammatic())
		{
			datesTo 	= cast dateChooser.getSelectedDates();
			datesTo[0].setFullYear(dateChooser.getDisplayedYear());
			changeFromTo(datesTo[0], e.isProgrammatic());
		}
	}

	/**
	 * 
	 * @param	date
	 * @param	isProgrammatic
	 * @param	adjust
	 */
	function changeFromTo(date:DateAs, isProgrammatic:Bool) 
	{
		dateChooserFrame.tryToClose();
		Session.dbDefaults.setStringParam(Parameters.paramReportsSelectedDate, dateSelected[0].toString());
		Session.dbDefaults.setStringParam(Parameters.paramReportsStartDate, datesFrom[0].toString());
		Session.dbDefaults.setStringParam(Parameters.paramReportsEndDate, datesTo[0].toString());
		applyFilters();
	}

	public override function refresh():Void
	{
		if (bSingleDate){
			dateLabelOnTable = DateUtil.getStringDate(dateSelected[0].getFullDate().toString()) + ', ' + cast dbTable.recordsNumber + strItemsNumber;
		}
		else {
			dateLabelOnTable = DateUtil.getStringDate(datesFrom[0].getFullDate().toString()) + ' - ' + (DateUtil.getStringDate(datesTo[0].getFullDate().toString())) + ', ' + cast dbTable.recordsNumber + strItemsNumber;
		}
	}

	/**
	 * 
	 */
	public override function applyFilters():Void
	{
		if (dbTable.bFilterOn)
		{
			if (bSingleDate)
			{
				iconCurrent = iconSingleDate;
				dbTable.selectTimeInterval(dateSelected[0], dateSelectedTo, onGetResultFunc);
			}

			else {
				iconCurrent = iconDateFromTo;
				dbTable.selectTimeInterval(datesFrom[0], datesTo[0], onGetResultFunc);
			}
		}
		else
		{
			setTodayDate();
			iconCurrent = iconSingleDate;
			dbTable.selectTimeInterval(dateSelected[0], dateSelectedTo, onGetResultFunc);
		}
	}

	/**
	 * 
	 */
	public function setTodayDate():Void
	{
		dateSelected[0].setTime(Date.now().getTime());
		dateSelected[0].setHours(0);
		dateSelected[0].setMinutes(0);
		dateSelected[0].setSeconds(0);
		adjustDateSelectedTo();
	}

	/**
	 * 
	 */
	function adjustDateSelectedTo() 
	{
		dateSelectedTo.setTime(dateSelected[0].getTime());
		dateSelectedTo.setDate(dateSelected[0].getDate() + 1);
	}
}