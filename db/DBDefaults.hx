package db;

import db.DBDefaults.DefaultData;
import enums.Enums.Parameters;
import events.PanelEvents;
import openfl.events.Event;

#if sqlite
import flash.data.SQLResult;
#end
//import db.DBReports.ReportData;

/**
 * ...
 * @author GM
 */
class Brol1
{
	
}

class DefaultData
{
    public var ID:Int;
    public var ValueInt:Int;
    public var Min:Int;
    public var Max:Int;
    public var Default:Int;
    public var ValueText:String;
    public var Parameter:String;
    public var Comment:String;

	public function new(id:Int = 1) 
	{
		ID = id;
	}
}

/**
 * 
 */
class DBDefaults extends DBBase
{
	public static var prisonerFont:String = "Prisoner SF";
	public static var textFont:String;
	public static var defaultsMap: Map<String, DefaultData>;  //Table for all defaults parameters

	function new():Void 
	{
		defaultsMap 	= new Map<String, DefaultData>();
		
		
#if sqlite
		fName 		= DBBase.getConfigDataName();
		tableName	= "Defaults";
#end

		super(true);
	}

	/**
	 * 
	 */
	public function setIntParam(strParam:String, param:Int, refresh:Bool = false):Void
	{
		#if sqlite

		var defaultData:DefaultData = defaultsMap.get(strParam);
		defaultData.ValueInt = param;
		defaultsMap.set(strParam, defaultData);
		dbStatement.text =  ("UPDATE " + tableName + " SET ValueInt = '" + param + "' WHERE Parameter = '" + strParam + "'");
		dbStatement.execute();

		#else

		cnx.dbDefaults.setIntParam.call([strParam, param]);

		#end

		//if (refresh)
			//Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PARAM_UPDATED));
	}

	/**
	 * 
	 */
	public function setStringParam(strParam:String, param:String, refresh:Bool = false):Void
	{
		var defaultData:DefaultData = defaultsMap.get(strParam);
		defaultData.ValueText = param;
		defaultsMap.set(strParam, defaultData);
		dbStatement.text =  ("UPDATE Defaults SET ValueText = '" + param + "' WHERE Parameter = '" + strParam + "'");
		dbStatement.execute();

		if (refresh)
			Main.root1.dispatchEvent(new Event(PanelEvents.EVT_PARAM_UPDATED));
	}

	#if sqlite
	/**
	 * 
	 */
	public override function getFilteredData (?conditions:String = "", ?getResult:SQLResult->Void, ?fromTime:Bool = false):Int
	{
		super.getFilteredData(conditions, getResult);

		for (data in sqlResult.data)
		{
			var defaultData:DefaultData = new DefaultData(); // Defaults
			defaultData.Default		= data.Default;
			defaultData.Max 		= data.Max;
			defaultData.Min 		= data.Min;
			defaultData.ValueInt	= data.ValueInt;
			defaultData.ValueText	= data.ValueText;
			defaultsMap.set(data.Parameter, defaultData);
			//trace(data.Parameter);
		}

		textFont = getStringParam(Parameters.paramDefaultFont);
		
		return sqlResult.data.length;
	}

	#end
	/**
	 * 
	 * @param	name
	 * @return
	 */
	static public function getStringParam(name:String):String
	{
		var ret:String = defaultsMap.get(name).ValueText;
		return (cast ret) ? ret : "";
	}

	/**
	 * 
	 * @param	name
	 * @return
	 */
	static public function getMinParam(name:String):Int
	{
		return  defaultsMap.get(name).Min;
	}

	/**
	 * 
	 * @param	name
	 * @return
	 */
	static public function getMaxParam(name:String):Int
	{
		return  defaultsMap.get(name).Max;
	}

	/**
	 * 
	 * @param	name
	 * @return
	 */
	static public function getIntParam(name:String):Int
	{
		return defaultsMap.get(name).ValueInt;
	}

	/**
	 * 
	 * @param	name
	 * @return
	 */
	static public function getBoolParam(name:String):Bool
	{
		return getIntParam(name) == 0 ? false : true;
	}
}
