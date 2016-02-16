package db;

import db.DBTranslations;
import enums.Enums.ErrorCode;
import enums.Enums.ErrorOrigin;
import error.Errors;
import haxe.remoting.HttpAsyncConnection;
import openfl.events.EventDispatcher;
import org.aswing.util.DateAs;
import org.aswing.util.StringUtils;

#if sqlite
import flash.data.SQLConnection;
import flash.data.SQLMode;
import flash.data.SQLResult;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.filesystem.File;
import flash.net.Responder;
#end


enum DBCommand
{
	COMMAND_HISTORY;
	COMMAND_REPORTS;
	COMMAND_CHANNEL;
}

/**
 * ...
 * @author GM
 */
class DBBase extends EventDispatcher
{
	public var bFilterOn			:Bool;
	#if sqlite
	public var immediate			:Bool;
	public var nextStatementFunc	:SQLResult->Void;
	public var dateIntervalSQLText	:String = "";
	var strSQLFilter				:String = "";
	var strSQLConditions			:String = "";
	var strSQLOrder					:String = "";
	
	static private var TRANSLATIONS:String 	= "Translations.db";
	static private var CONFIG:String 		= "Configurations.db";
	static private var CONFIG_DEMO:String	= "Configurations-Demo.db";
	static private var RPMDATA:String 		= "Rpmdata.db";
	static private var RPMDATA_DEMO:String 	= "RpmData-Demo.db";
	static private var KEYGEN:String 		= "MXTKeyGen.db";

	public var dbConnection			:SQLConnection;
	public var dbStatement			:SQLStatement;
	var fName						:String;
	var dbFile						:File;
	var sqlResult					:SQLResult;
	var getRecordsCountResultFunc	:SQLResult->Void;
	public var onApplyFilters		:SQLResult->Void;

	#else
	public  var cnx:HttpAsyncConnection;
	#end
	
	var fileLastModifTime			:Date;
	public var recordsNumber		:Int;

	var tableName					:String;
	var timeFieldName				:String;
	var intervalSelSQLText			:String = "";


	public function new(getData:Bool = false, async:Bool = false) 
	{
		super();
	
		#if sqlite

		dbFile = File.applicationStorageDirectory.resolvePath(fName);

		dbConnection 		= new SQLConnection();
		dbStatement 		= new SQLStatement();
		fileLastModifTime 	= Date.now();
		
		if (!dbFile.exists)
		{
			File.applicationStorageDirectory.createDirectory();
		}

		if (async)
			dbConnection.openAsync(dbFile, SQLMode.UPDATE);
		else
			dbConnection.open(dbFile, SQLMode.UPDATE);

		dbStatement.sqlConnection = dbConnection;
		isModified();  // To get the last modificationDate
		immediate = !async;
 		if(getData) getFilteredData();

		#else
	
		cnx = haxe.remoting.HttpAsyncConnection.urlConnect("http://localhost:2000/PortalServer.n");
		cnx.setErrorHandler( function(err) { trace('Error form Server: $err'); } );
		#end
	}

	/**
	 * 
	 */
	public function areStackedActions():Bool 
	{
		return false;
	}
	
	#if sqlite
	function onGetRecordsResult(res:SQLResult) {
	}

	/**
	 * 
	 * @return
	 */
	public function isModified():Bool 
	{
		var bRet:Bool 		= dbFile.modificationDate.getTime() > fileLastModifTime.getTime();
		fileLastModifTime	= dbFile.modificationDate;
		
		return bRet;
	}

	/**
	 * 
	 * @param	result
	 * @param	status
	 */
	function onDBAsyncError(result:SQLError)
	{
		var str:String = result.message + ", " + result.details;
		str = StringUtils.replace(str, "'", '');
		str = StringUtils.replace(str, "Error", '');
		var errorInfo:ErrorInfo = new ErrorInfo(ErrorCode.ERROR_DB, str, ErrorOrigin.ORIGIN_DB);
		Errors.sendErrorInfoMessage(errorInfo);
		var strMsg:String = DBTranslations.getText("IDS_DATABASE") + " " + tableName + '\n' + str;
		Main.dialogWidget.setOKDialog(onClose, strMsg);
		Main.dialogWidget.setVisible(true);		
	}

	/**
	 * 
	 * @param	dateFrom
	 * @param	dateTo
	 */
	public function selectTimeInterval(from:DateAs = null, to:DateAs = null, ?getResult:SQLResult->Void) :Int
	{
		fillSQLConditions();

		_setDateIntervalSQLText(from, to);
		getFilteredData(getResult, true);

		return recordsNumber;
	}	
	
	/**
	 * THIS FUNCTION GET THE DATA WITH ALL PREDEFINED FILTERS
	 * @param	conditions
	 */
	public function getFilteredData(?conditions:String = "", ?getResult:SQLResult->Void, ?fromTime:Bool = false):Int
	{
		var strConditions:String = "";
		var records:Int = 0;

		strSQLFilter = "";

		if (conditions + dateIntervalSQLText != "") {
			strSQLFilter += " WHERE ";
		}

		else {
			strSQLFilter		= conditions;
		}

		if ((cast dateIntervalSQLText.length) && (cast strSQLConditions.length)) {
			strConditions = strSQLConditions + " AND ";
		}
		else {
			strConditions = strSQLConditions;
		}

		if (fromTime)
		{
			dbStatement.text 	=  ("SELECT COUNT(*) ID FROM " + tableName + strSQLFilter + strConditions + dateIntervalSQLText);
			dbStatement.execute();
			sqlResult 			= dbStatement.getResult();

			records = (cast sqlResult.data) ? sqlResult.data.length : 0;
			//recordsNumber = records;
		}

		//trace("recordsNumber : " + recordsNumber);

		//if ((cast getResult) && recordsNumber == 0) {
			//getResult(null);
			//return false;
		//}

		dbStatement.clearParameters();
		dbStatement.text 	=  ("SELECT * FROM " + tableName + strSQLFilter + strConditions + dateIntervalSQLText + intervalSelSQLText);

		trace(dbStatement.text);

		if (cast getResult)
		{
			pushSQL(dbStatement.text, null, getResult);
		}
		else
		{
			if (immediate)
			{
				dbStatement.execute();
				sqlResult = dbStatement.getResult();
				records = (cast sqlResult.data) ? sqlResult.data.length : 0;
				if(cast getResult) getResult(sqlResult);
			}
			else {
				pushSQL(dbStatement.text, null, getResult);
			}

		}
		return records;
	}
	/**
	 * 
	 * @param	lang
	 */
	public function getRecords(?from:Int, ?count:Int = 0, ?immediate:Bool, ?getResult:SQLResult->Void):Void
	{
		return setIntervalFromCount(from, count, getResult);
 	}

	/**
	 * 
	 * @param	lang
	 */
	public function getRecordsCount(?getCountResult:SQLResult->Void):Void
	{
		var stat:String =  "SELECT COUNT(ID) AS count FROM " + tableName;
		getRecordsCountResultFunc = getCountResult;
		pushSQL(stat, null, onGetRecordsCount);
	}

	/**
	 * 
	 * @param	res
	 */
	public function onGetRecordsCount(res:SQLResult)
	{
		recordsNumber = res.data[0].count;

		if(cast getRecordsCountResultFunc) getRecordsCountResultFunc(res);
	}

	/**
	 * 
	 * @param	sql
	 * @param	resp
	 */
	public function pushSQL(sql:String, param:Dynamic, ?resp:Dynamic->Void):Void
	{
		//throw("pushSQL not implemented");
		dbStatement.text = sql;
		dbStatement.execute();
		sqlResult = dbStatement.getResult();
		if (cast resp) resp(sqlResult);
	}

	/**
	 * 
	 * @return
	 */
	public function getRPMCommand():DBCommand
	{
		return null;
	}
	
	/**
	 * 
	 */
	public function getLastRecord(?getResult:SQLResult->Void)
	{
		dbStatement.text =  "SELECT * FROM " + tableName + " ORDER BY ID DESC LIMIT 1";

		if(cast getResult)
			dbStatement.execute( -1, new Responder(getResult, onDBAsyncError));
		else
			dbStatement.execute();
	}
	
	#end

	function onClose() {
		Main.dialogWidget.setVisible(false);
	}

	function fillSQLConditions() {
	}

	function strartTransaction() {
	}



	/**
	 * 
	 * @param	from
	 * @param	to
	 */
	function _setDateIntervalSQLText(from:DateAs = null, to:DateAs = null) 
	{
		if (!cast from) {
			from	= new DateAs(0, 0, 0, 0);
			to		= DateAs.fromTime(Date.now().getTime());
		}

		dateIntervalSQLText = getTimeIntervalFieldName() + " BETWEEN julianday('" + from.getFullDate().toString() + "') AND julianday('" + to.getFullDate().toString() + "')";
	}

	/**
	 * 
	 * @return
	 */
	function getTimeIntervalFieldName() :String
	{
		return "Time";
	}

	/**
	 * 
	 * @param	count
	 */
	public function setIntervalFromCount(?from:Int, ?count:Int, ?reverse:Bool, ?func:Dynamic->Void, ?stacked:Bool = false):Void
	{
		//trace("From: " + from);
		if (cast reverse) {
			from = recordsNumber - from - count;
		}
		//trace("From: " + from);

		intervalSelSQLText = (cast count) ? strSQLOrder + " LIMIT " + count + " OFFSET " + from : "";
		trace(intervalSelSQLText);

		if (cast func) {
			getFilteredData(func, false);
		}
	}

	/**
	 * 
	 * @param	count
	 */
	public function setIntervalFromCountNotStacked(?from:Int, ?count:Int, ?reverse:Bool, ?func:Dynamic->Void):Void
	{
		setIntervalFromCount(from, count, reverse, (cast func) ?  func : onApplyFilters, false);
	}

 	/**
	 * 
	 * @param	defaultData
	 */
	public function updateSelected(id:Int, sel:Bool):Void
	{
		//trace("updateSelected " + sel);
		//var parameter:Array<Dynamic> = new Array<Dynamic>();
		//dbStatement.text =  ("UPDATE " + tableName + " SET Selected = '" + sel + "' WHERE ID = '" + id + "'");
		//dbStatement.execute();
	}

	/**
	 * 
	 */
	static public function getTranslationsDataName() 
	{
		return TRANSLATIONS;
	}

	/**
	 * 
	 */
	static public function getConfigDataName() 
	{
		return Session.demoMode ? CONFIG_DEMO : CONFIG;
	}

	static public function getRPMDataName() 
	{
		return Session.demoMode ? RPMDATA_DEMO : RPMDATA;
	}
	
	public function getData(obj:Dynamic) : Dynamic
	{
		return null;
	}

}