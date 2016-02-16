package db;

import db.DBBase;
import db.DBDefaults;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.data.SQLResult;
import haxe.remoting.HttpAsyncConnection;
import openfl.events.Event;


/**
 * ...
 * @author GM
 */
class DBTranslations extends DBBase 
{
	static public var IDSStringMap:Map <String, String>;

	public function new():Void 
	{
	#if sqlite
		IDSStringMap = new Map <String,  String > ();

		fName 		= DBBase.getTranslationsDataName();
		tableName	= "Translations";

	#end
		super();
	#if sqlite
		getTranslations(DBDefaults.getIntParam(Parameters.paramLanguage));
	#else
		getTranslations(1);
	#end
		trace("START REMOTING");
	}

	/**
	 * 
	 * @param	list
	 */
	function onGetTranslations(map: Map <String, String>) 
	{
		IDSStringMap = map;
		trace("END REMOTING");
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_REMOTING_INITIALIZED)); // 0 for all channels		return true;
	}

	/**
	 * 
	 * @param	res
	 */
	static function onGetResult(res) 
	{
		trace(res);
	}

	/**
	 * 
	 * @param	lang
	 */
	public function getTranslations (lang:Int):Void
	{
#if sqlite
		var strFilter:String;

		switch (lang)
		{
			case 0: strFilter = "French";
			case 1: strFilter = "English";
			case 2: strFilter = "Dutch";
			case 3: strFilter = "German";

			default: strFilter = "English";
		}
		_getTranslations(lang, strFilter);
#else
		cnx.dbTranslations.getTranslations.call([lang], onGetTranslations);
#end
	}
#if sqlite
	/**
	 * Get the text strings for the lang from 0 to ...
	 * @param	lang<
	 */
	function _getTranslations (lang:Int, strFilter:String):Void
	{
		dbStatement.text =  ("SELECT Name, " + strFilter + " FROM " + tableName);
		dbStatement.execute();
		var sqlResult:SQLResult = dbStatement.getResult();
		var text:String = "";

		for (data in sqlResult.data)
		{
			switch (lang)
			{
				case 0: text = data.French;
				case 1: text = data.English;
				case 2: text = data.Dutch;
				case 3: text = data.German;
				default: text = data.English;
			}

			IDSStringMap.set (data.name, text);
		}
	
		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_REMOTING_INITIALIZED)); // 0 for all channels		return true;
 	}
#end
	/**
	 * 
	 * @param	key
	 * @return
	 */
	public static function getText (keyIn:String):String
	{
		if((cast keyIn) && (keyIn.indexOf("IDS_") == 0)) {
			if(keyIn.length > 0 && keyIn != null)
		return IDSStringMap.get(keyIn);}

		return keyIn;
	}

	/**
	 * 
	 */
	static public function getDayNames() :Array<String>
	{
		return DBTranslations.getText("IDS_DAYS").split(',');
	}

	/**
	 * 
	 */
	static public function getMonthNames() :Array<String>
	{
		return DBTranslations.getText("IDS_MONTHES").split(',');
	}

	/**
	 * 
	 */
	static public function getReportLegend():Array < String >
	{
		var ar:Array < String > = new Array < String >();
		ar.push(getText("IDS_THRESHOLD"));
		ar.push(getText("IDS_SIGNAL"));
		ar.push(getText("IDS_BKG"));

		return ar;
	}	
}