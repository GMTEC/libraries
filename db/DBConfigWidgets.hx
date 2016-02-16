package db;

import events.PanelEvents;
import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.events.Event;
import haxe.ds.ObjectMap;
import sys.db.Types.SId;

/**
 * ...
 * @author GM
 */

class ConfigWidgetData
{
	public var ID:Int;
	public var name:String;
	public var XPos:Int;
	public var Width:Int;
	public var Height:Int;
	public var YPos:Int;
	public var Scale:Float;
	public var Alpha:Float;
	public var Draggable:Bool;
	public var Visible:Bool;

	public function new(nameIn:String, xIn:Int, yIn:Int, wIn:Int, hIn:Int, scaleIn:Float, ?alphaIn:Float = 1, ?draggableIn:Bool = false, ?visibleIn:Bool = false) 
	{
		ID		= 0;
		name	= nameIn;
		XPos	= xIn;
		YPos	= yIn;
		Width	= wIn;
		Height	= hIn;
		Scale	= scaleIn;
		Alpha	= alphaIn;
		Draggable	= draggableIn;
		Visible	= visibleIn;
	}
}

/**
 * Table to store all Widgets Positions
 */
class DBConfigWidgets extends DBBase
{
	static var configWidgetsArray = new ObjectMap  <String, ConfigWidgetData> ();
	public static var connection:SQLConnection;
	public var id : SId;
    public var name : String;
    //public var X : String;
    //public var Y : String;
    public var Scale : String;

	function new():Void 
	{
		fName 		= DBBase.getConfigDataName();
		tableName	= "Widgets";

		super(true, false);

		Main.root1.addEventListener(PanelEvents.EVT_WIN_REFRESH, onGetFilteredData);
	}
	
	private function onGetFilteredData(e:Event):Void 
	{
		getFilteredData();
	}

	/**
	 * 
	 * @param	lang
	 */
	public override function getFilteredData (?conditions:String = "", ?getResult:SQLResult->Void, ?fromTime:Bool = false):Int
	{
		var records = super.getFilteredData(getResult);
		if (records > 0)
		{
			for (data in configWidgetsArray)
				configWidgetsArray.remove(data.name);

			for (data in sqlResult.data)
			{
				configWidgetsArray.set(data.name, new ConfigWidgetData(data.name, data.X, data.Y, data.W, data.H, data.Scale, data.Alpha, data.Draggable, data.Visible));
			}
		}
		return records;
 	}

	/**
	 * 
	 * @param	ids
	 * @return
	 */
	public function getConfigWidget (nameIn:String):ConfigWidgetData
	{
		return configWidgetsArray.get(nameIn);
	}

	/**
	 * 
	 * @param	name
	 * @return
	 */
	public function setConfigWidget(widget:ConfigWidgetData)
	{
		if (widget.name != "")
		{
			var data = configWidgetsArray.get(widget.name);

			// Create a new entry if doesn't exists
			if (data == null)
			{
				//trace("New Widget Added");
				widget.Draggable = true;

				dbStatement.text = ("INSERT INTO " + tableName + " (X, Y, W, H, Draggable, Visible, Scale, Alpha) VALUES ("
					+ widget.XPos + ","
					+ widget.YPos + ","
					+ widget.Width+ ","
					+ widget.Height + ","
					+ widget.Draggable + ","
					+ widget.Visible + ","
					+ widget.Scale + ","
					+ widget.Alpha + ")");

				dbStatement.execute();
				configWidgetsArray.set(widget.name, widget);
			}

			updateWidgetTable(widget);
		}
	}

	/**
	 * 
	 * @param	widget
	 */
	function updateWidgetTable(widget:ConfigWidgetData):Void
	{		
		dbStatement.text =  ("SELECT * FROM " + tableName + " WHERE name = '" + widget.name + "'");

		dbStatement.execute();
		var sqlResult:SQLResult = dbStatement.getResult();

		if (sqlResult.data == null)
		{
			dbStatement.text = ("INSERT INTO " + tableName + " (name, X, Y, Draggable, Visible, Scale, Alpha) VALUES ('" + widget.name + "'," + widget.XPos + "," + widget.YPos + "," + widget.YPos + "," + widget.Draggable + "," + widget.Visible + "," + widget.Alpha + ")");
		}
		else
		{
			dbStatement.text = ("UPDATE " + tableName + " SET X = '" + widget.XPos + "', Y = '" + widget.YPos + "', Draggable = '" + widget.Draggable + "', Visible = '" + widget.Visible + "', Scale = '" + widget.Scale + "', Alpha = '" + widget.Alpha  + "' WHERE name = '" + widget.name + "'");
		}

		dbStatement.execute();
	}
}
