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
import org.aswing.geom.IntRectangle;
import org.aswing.Insets;
import org.aswing.JFrame;
import tables.Table;
import tables.TableReport;
import tools.WTools.ToolButton;
import util.Filters;
import util.Images;
import util.ScreenManager;
import widgets.WSearchDlg;

/**
 * ...
 * @author GM
 */
class ToolSQL extends ToolsVertWidget
{
	public var dbTable		:DBBase;

	var onGetResultFunc		:SQLResult->Void;
	var onPrevFunc			:Void->Void;
	var onNextFunc			:Void->Void;
	var iconCurrent			:IconFromBm;
	var oldFunc				:Dynamic->Void;
	var strItemsNumber		:String;
	var butNext				:ToolButton;
	var butPrev				:ToolButton;
	var butFilter			:ToolButton;
	var butSearch			:ToolButton;
	var wSearchDlg			:WSearchDlg;
	var table				:Table;

	public function new(name:String, ?w:Int=40, ?h:Int=40, func:SQLResult->Void) 
	{
		super(name, w, h);

		onGetResultFunc		= func;

		butFilter 		= push(Images.loadSQLFilterOff(), Images.loadSQLFilterOn(), 		" ", "IDS_TT_MENU_FILTER", 	onButFilterOnOff);
		butPrev 		= push(Images.loadButPrevious(), 	null, 							" ", "IDS_TT_MENU_PREV", 	onButPrevious);
		butNext 		= push(Images.loadButNext(), 		null, 							" ", "IDS_TT_MENU_NEXT", 	onButNext);
		butSearch 		= push(Images.loadView(false), 			null, 							" ", "IDS_TT_MENU_SEARCH", 	onButSearch);

		Main.root1.addEventListener(PanelEvents.EVT_PANE_CHANGE, hideDialogs);
		Main.root1.addEventListener(PanelEvents.EVT_SQL_SEARCH, onSearchOnText);
	}

	/**
	 * 
	 * @param	reportsTable
	 */
	public function setTable(tableIn:Table) 
	{
		table = tableIn;
		setNextRecordFunc(table.onNextRecord);
		setPrevRecordFunc(table.onPrevRecord);
	}

	/**
	 * 
	 * @param	e
	 */
	public function hideDialogs(e:Event):Void 
	{
	}

	/**
	 * 
	 * @return
	 */
	public function getTextSQL():String 
	{
		return null;
	}
	/**
	 * 
	 * @param	e
	 */
	private function onSearchOnText(e:TextEvent):Void 
	{
	}

	public function setPrevRecordFunc(func:Void->Void) { onPrevFunc = func; }
	public function setNextRecordFunc(func:Void->Void) { onNextFunc = func; }

	/**
	 * 
	 * @param	e
	 */
	function onButPrevious(e:Dynamic) :Void {
		if(cast onButPrevious) onPrevFunc();
	}

	/**
	 * 
	 */
	public function init():Void {
		dbTable.selectTimeInterval();
	}

	/**
	 * 
	 * @param	e
	 */
	function onButNext(e:Dynamic) :Void
	{
		if(cast onButNext) onNextFunc();
	}

	/**
	 * 
	 * @param	e
	 */
	function onButSearch(e:Dynamic) :Void
	{
		if(cast onButSearch) onSearchFunc();
	}

	/**
	 * 
	 * @return
	 */
	public function getIconSQL():IconFromBm 
	{
		return iconCurrent;
	}

	/**
	 * 
	 * @param	e
	 */
	function onButFilterOnOff(e:Dynamic):Void 
	{
		dbTable.bFilterOn = !dbTable.bFilterOn;
		setIconSprite(0, dbTable.bFilterOn); 
		applyFilters();
	}

	/**
	 * 
	 * @param	e
	 */
	function onSearchFunc():Void 
	{
		if (wSearchDlg == null)
			wSearchDlg = new WSearchDlg(this, Main.widgetBig);
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_SQL_SEARCH_DLG));		
	}

	/**
	 * 
	 * @param	table
	 */
	public function setDBTable(table:DBBase):Void
	{
		dbTable = table;
	}

	/**
	 * 
	 */
	public function applyFilters():Void
	{
	}
}