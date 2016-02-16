package db;

import enums.Enums.ErrorCode;
import error.Errors.Error;
import events.PanelEvents;
import flash.data.SQLResult;
import flash.events.EventDispatcher;
import flash.net.Responder;
import tables.Table;
import util.DateUtil;

/**
 * ...
 * @author GM
 */
class DBLog extends DBRPMData
{
	var strFilterReport		:String = "";
	var strFilterRA			:String = "";
	var strFilterError		:String = "";

	public function new() 
	{
		super();

		tableName 		= "Log";
		timeFieldName	= "Time"; // Time for data Selection
		immediate		= false;
	}

	/**
	 * 
	 */
	override function fillSQLConditions() 
	{
		strSQLConditions = strFilterReport;
		strSQLConditions += strFilterRA;
		strSQLConditions += strFilterError;

		//if (!cast strSQLConditions.length){
			//strSQLConditions = " Code = 0";
		//}
		//else {
			//strSQLConditions = " (";
			//if (cast strFilterReport.length) strSQLConditions += " Code = " + ErrorCode.MSG_REPORT_CREATED + " OR ";
			//if (cast strFilterRA.length)	 strSQLConditions += " Code = " + ErrorCode.MSG_RA_DETECTED + " OR ";
			//if (cast strFilterError.length)	 strSQLConditions += " (Code  > " + ErrorCode.ERROR_SUCCESS + " AND Code < " + ErrorCode.MSG_REPORT_CREATED + ")";
			//if (strSQLConditions.lastIndexOf(" OR ") == strSQLConditions.length - 4) strSQLConditions = strSQLConditions.substr(0, strSQLConditions.length - 4);
			//strSQLConditions += ")";
		//}
	}

	/**
	 * 
	 * @param	obj
	 * @return
	 */
	public override function getData(dao:Dynamic):Dynamic
	{
		var er:Error = new Error(dao.Code, dao.Origin, dao.State, dao.Severity, dao.Parameter);

		return new MessagesTableData(null, null, dao.Time, er.getLabelText(), dao.Selected);
	}

	/**
	 * 
	 * @param	logData
	 */
	public function logMessage(logError:Error):Void
	{
		Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_LOG, logError));
		updateLog(logError);
	}

	/**
	 * 
	 * @param	defaultData
	 */
	public function updateLog(logData:Error):Void
	{
		trace("Log : " + logData.logMsg);
		pushSQL("INSERT INTO " + tableName + "(Code, Origin, State, Severity, Parameter, Time) VALUES ("
			+ logData.code + ","
			+ cast logData.origin + ","
			+ cast logData.status + ","
			+ cast logData.severity + ",'"
			//+ logData.logMsg + "','"
			+ logData.param + "','"
			+ logData.time + "')", null, updateLogDone);
	}

	function updateLogDone(stat:Dynamic) :Void
	{
		trace("updateLogDone()");
	}

	public function selectFilterReport(bFilterReport:Bool) 
	{
		//strFilterReport = bFilterReport ? " OR Code = " + ErrorCode.MSG_REPORT_CREATED : "";
	}

	public function selectFilterRA(bFilterRA:Bool) 
	{
		//strFilterRA = bFilterRA ? " OR Code = " + ErrorCode.MSG_RA_DETECTED : "";
	}

	public function selectFilterError(bFilterError:Bool) 
	{
		//strFilterError = bFilterError ? " OR Code > " + ErrorCode.ERROR_SUCCESS + " AND Code < " + ErrorCode.MSG_REPORT_CREATED: "";
	}
}