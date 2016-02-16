package tables;

import db.DBBase;
import db.DBTranslations;
import flash.data.SQLResult;
import flash.events.MouseEvent;
import haxe.Timer;
import icon.IconFromBm;
import org.aswing.ASColor;
import org.aswing.event.FocusKeyEvent;
import org.aswing.event.SelectionEvent;
import org.aswing.geom.IntRectangle;
import org.aswing.JLabel;
import org.aswing.JScrollBar;
import org.aswing.JScrollPane;
import org.aswing.JTable;
import org.aswing.table.GeneralTableCellFactory;
import org.aswing.table.PropertyTableModel;
import org.aswing.table.sorter.TableSorter;
import org.aswing.VectorListModel;
import tables.renderer.RAIconCell.SelectionCell;
import widgets.WBase;
import widgets.WDialog;

/**
 * ...
 * @author GM
 */
class MessagesTableData
{
	public var selected		:Bool;
	public var reportNumber	:Int;
	public var result		:Int;
	public var date			:Date;
	public var time			:Date;
	public var duty			:Int;
	public var label		:String;

	public function new(?reportNumberIn:Int = 0, ?resultIn:Int = 0, ?dateIn:Date = null, ?dutyIn:Int = 0, ?labelIn:String, ?sel:Bool = false)
	{
		selected		= sel;
		reportNumber	= reportNumberIn;
		date 			= dateIn;
		time 			= (cast dateIn) ? dateIn : Date.now();
		duty 			= dutyIn;
		result 			= resultIn;
		label			= labelIn;
	}
}

/**
 * 
 */
class Table extends WBase
{
	static var wDialog				:WDialog;
	public var previousIndexSelected:Int;
	public var indexSelected		:Int;
	public var reportSelected		:Int;
	public var scrollBar			:JScrollBar;
	public var listData				:VectorListModel;
	public var tableRows			:Int = 16;
	public var dbTable				:DBBase;
	public var tableSorter			:TableSorter;

	var dateLabelOnTable			:JLabel;
	var table						:JTable;
	var model						:PropertyTableModel;
	var scrollPane					:JScrollPane;
	var iconDate					:IconFromBm;
	var rowVisible					:Int;
	var doubleClick					:Bool;
	var checkedItems				:Map<Int, Bool>;
	var scrollbarValue				:Int;
	var sortingColumn				:Int = 1;
	public var bFieldModified		:Bool;
	public var selectionFunc		:Dynamic->Void;

	/**
	 * 
	 * @param	name
	 * @param	wIn
	 * @param	hIn
	 */
	public function new(name:String, wIn:Int, hIn:Int, ?func:Dynamic->Void)
	{
		super(name);

		listData				= new VectorListModel();
		dateLabelOnTable		= new JLabel();
		table					= new JTable();
		scrollPane 				= new JScrollPane(table, JScrollPane.SCROLLBAR_NEVER);
		checkedItems			= new Map<Int, Bool> ();
		table.setBackground(ASColor.WET_ASPHALT);
		table.setForeground(ASColor.CLOUDS);
		table.setMideground(ASColor.CLOUDS);
		addChild(scrollPane);
		addChild(dateLabelOnTable);

		scrollBar 				= new JScrollBar();
		scrollBar.setComBoundsXYWH	(wIn - 4, 4, 28, cast hIn);

		scrollBar.setValues(0, tableRows, 0, 100, true);
		//scrollBar.x = x + wIn + 8;
		addChild(scrollBar);

		scrollBar.addStateListener((cast func) ? func : onScrollAdjust);
		//scrollBar.addEventListener(MouseEvent.CLICK, onScrollAdjust);

		dateLabelOnTable.setBounds(new IntRectangle(0, - 18, cast wIn, 20));

		var rect:IntRectangle 		= new IntRectangle(0, 0, wIn, hIn);
		scrollPane.x 				= rect.x - 16;
		scrollPane.y 				= rect.y + 4;
		scrollPane.setWidth(rect.width + 24);
		scrollPane.setHeight(rect.height);
		
		table.addEventListener(SelectionEvent.ROW_SELECTION_CHANGED, selectionListener);

		this.cacheAsBitmap 			= true;
	}

	/**
	 * 
	 * @param	e
	 */
	private function onTableKeyDown(e:FocusKeyEvent):Void 
	{
		if (e.keyCode == 38 || e.keyCode == 40)
		{
			scrollTable();
		}
	}

	/**
	 * 
	 */
	function scrollTable() 
	{
		var index = table.getSelectedRow();

		if (index == 0)
		{
			//scrollBar.setValue(scrollBar.getValue() - tableRows, false);
			//trace("scrollTable(0)");
		}

		else if (index == tableRows - 1)
		{
			//scrollBar.setValue(scrollBar.getValue() + tableRows, false);
			//trace("scrollTable(" + index + ")");
		}
	}

	/**
	 * 
	 */
	function init():Void 
	{
		tableSorter				= new TableSorter(model);
		tableSorter.setTableHeader(table.getTableHeader());
		tableSorter.setSortingStatus(sortingColumn, TableSorter.DESCENDING); // Decreasing sorting
		table.setModel(tableSorter);

		scrollbarValue = scrollBar.getMinimum();
		onHeaderClick();
		tableSorter.getTableHeader().addEventListener(MouseEvent.CLICK, onHeaderClick);
	}

	/**
	 * 
	 * @param	e
	 */
	public function selectionListener(e:SelectionEvent):Void
	{
		if (listData.getSize() > 0)
		{
			indexSelected = tableSorter.modelIndex( e.getFirstIndex() );

			if (table.getSelectedColumn() == 0) // CheckBox column 0
			{
				if (checkedItems.exists(indexSelected))
					checkedItems.remove(indexSelected);
				else
					checkedItems.set(indexSelected, true);
				selectItem( -1, true);

				dbTable.updateSelected(indexSelected, true);

				listData.getElementAt(indexSelected).selected = checkedItems.exists(indexSelected);  // Checkbox

				return;
			};

			onSelectionListener(indexSelected);
		}
	}

	/**
	 * 
	 * @param	sel
	 */
	function onSelectionListener(sel:Int)
	{
		if (bFieldModified)
		{
			if (wDialog == null)
			{
				wDialog = new WDialog(Main.widgetBig.mainWindow, Main.widgetBig);
				wDialog.setYesNoDialog(onOK, onCancel, "IDS_MSG_RECORD_SAVE", "IDS_YES", "IDS_NO");
			}
			wDialog.setVisible(true);
		}
		if (cast selectionFunc) selectionFunc(listData.getElementAt(sel));
	}
	
	function onCancel() 
	{
		wDialog.setVisible(false);
		bFieldModified = false;
	}
	
	function onOK() 
	{
		wDialog.setVisible(false);
		bFieldModified = false;
		
	}

	/**
	 * 
	 * @param	e
	 */
	private function onHeaderClick(e:MouseEvent = null):Void 
	{
		onScrollAdjust(false);
	}

	/**
	 * 
	 * @param	table
	 */
	function setDBTable(table:DBBase) {
		dbTable = table;
		dbTable.onApplyFilters = onApplyFilters;
	}

	/**
	 * 
	 * @param	comp
	 */
	function onScrollAdjust(comp:Dynamic) 
	{
		var desc:Bool = tableSorter.getSortingStatus(sortingColumn) == TableSorter.DESCENDING;
		trace("onScrollAdjust " + scrollBar.getValue());

		if (comp && !comp.programmatic) {
			table.clearSelection();
			dbTable.setIntervalFromCountNotStacked(getScrollBarValue(desc), tableRows, desc);
			selectItem(cast tableRows / 2);
		}
	}

	/**
	 * 
	 * @param	dynamic
	 */
	function getScrollBarValue(desc:Bool) 
	{
		return desc ? scrollBar.getMaximum() - scrollBar.getValue() - tableRows : scrollBar.getValue() - tableRows;
	}

	/**
	 * 
	 * @param	res
	 * @param	label
	 * @param	icon
	 */
	public function refreshList(res:SQLResult, ?label:String, ?icon:IconFromBm)
	{
		//trace("LIST LEN : " + listData.getSize());
		listData.removeRange(0, listData.getSize());
		//trace("LIST LEN : " + listData.getSize());

		if (cast label) {
			iconDate				= icon;
			dateLabelOnTable.setText(label);
		}

		if ((cast res) && cast res.data) {
			for(obj in res.data) {
				appendData(obj);
			}
		}
		else {
			listData.append(getDefaultData(), 0);	
		}

		previousIndexSelected = indexSelected + 1;

		if (scrollBar.getMaximum() == 0) selectItem(0, true);
		scrollBar.setMinimum(0);
		scrollBar.setMaximum(dbTable.recordsNumber);

		table.ensureCellIsVisible(0, 0);
		//trace("LIST LEN : " + listData.getSize());

	}

	/**
	 * 
	 * @param	object
	 */
	function appendData(object) {
		listData.append(dbTable.getData(object));
	}

	/**
	 * 
	 */
	function getDefaultData() : Dynamic{
		return null;
	}

	/**
	 * 
	 * @param	e
	 */
	private function onDoubleClick(e:MouseEvent):Void
	{
		if (doubleClick) {
			doubleClickAction();
		}
		else{
			doubleClick = true;
			Timer.delay(endClick, 300);
		}
	}

	function doubleClickAction() {
	}

	/**
	 * 
	 */
	function endClick() {
		doubleClick = false;
	}

	/**
	 * 
	 * @param	col
	 * @param	width
	 * @param	sortable = true
	 */
	function setColWidth(col:Int, width:Int, sortable = true):Void {
		table.getColumnAt(col).setMaxWidth(width);	// Report
		tableSorter.setColumnSortable(col, sortable);
	}

	/**
	 * 
	 */
	public function onPrevRecord() {
		scrollBar.setValue(scrollBar.getValue() -1, false);
	}

	public function onNextRecord() {
		scrollBar.setValue(scrollBar.getValue() +1, false);
	}

	/**
	 *
	 * @param	inc
	 */
	public function selectRecord(inc:Int) 
	{
		indexSelected += inc;

		if (indexSelected < 0) {
			indexSelected = 0;
		}
		if (indexSelected >= listData.getSize()) {
			indexSelected = listData.getSize()-1;
		}
		selectItem(indexSelected);
	}

	/**
	 * 
	 * @return
	 */
	function getRecordsNumber() : Int {
		return 0;
	}

	/**
	 * 
	 */
	function onApplyFilters(res:SQLResult):Void {

		refreshList(res);
		selectItem(0);
	}

	/**
	 * 
	 * @param	item
	 */
	public function selectItem(item:Int, bProg:Bool = false):Void
	{
		table.changeSelection(item, 1, false, bProg);
		table.ensureCellIsVisible(item, 1);
		scrollTable();
	}

	/**
	 * 
	 */
	public function selectLastItem():Void 
	{
		tableSorter.cancelSorting();
		selectItem(0, true);
	}

	/**
	 * 
	 */
	public function setCellFactory(colName:String, factory:Dynamic):Void
	{
		table.getColumn(DBTranslations.getText(colName)).setCellFactory(factory);
	}
	
	public function setCellRenderer() 
	{
		setCellFactory("V", new GeneralTableCellFactory(SelectionCell));		
	}
}