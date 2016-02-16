package db;

import flash.data.SQLResult;
import flash.utils.ByteArray;
import sys.db.Types.SId;
import tables.TableReport.MessagesTableData;

/**
 * ...
 * @author GM
 */
class ReportData
{
 	// Table Structure :
	public var ID : SId;
	public var ReportNumber : Int;
	public var ReportResult : Int;
	public var TimeIn : Date;
	public var TimeOut : Date;
	public var Duty : Int;
	public var Channels : Int;
	public var VehicleRegistration : String;
	public var Comment : String;
	public var Picture : ByteArray;
	public var VehicleID : String;
	public var LoadType : String;
	public var loadCode : String;
	public var DriverName : String;
	public var CMR : String;
	public var TransporterName : String;
	/**
	 * 
	 * @param	reportNumberIn
	 * @param	reportResultIn
	 * @param	timeInIn
	 * @param	timeOutIn
	 * @param	channelsIn
	 * @param	vehicleRegistrationIn
	 * @param	vehicleIDIn
	 * @param	driverNameIn
	 * @param	loadTypeIn
	 * @param	loadCodeIn
	 * @param	CMRIn
	 * @param	commentIn
	 * @param	pictureIn
	 */
	public function new(

		?reportNumberIn:Int = 0,
		?reportResultIn:Int = 0,
		?timeInIn:Date,
		?timeOutIn:Date,
		?duty:Int,
		?channels:Int = 0,
		?vehicleRegistrationIn:String = "",
		?transporterNameIn:String = "",
		?vehicleIDIn:String = "",
		?driverNameIn:String = "",
		?loadTypeIn:String = "",
		?loadCodeIn:String = "",
		?CMRIn:String = "",
		?commentIn:String = "",
		?pictureIn: ByteArray = null)

	{
		ReportNumber		= reportNumberIn;
		ReportResult		= reportResultIn;
		TimeIn				= timeInIn;
		TimeOut				= timeOutIn;

		Duty				= duty;
	 	//Duty				= (cast TimeIn) ? (cast((TimeOut.getTime() - TimeIn.getTime()) / 1000)) : 0;

		//trace("+++++++++++++++");
		//trace("Report : " + ReportNumber);
		//trace(TimeIn.toString());
		//trace(TimeOut.toString());
		//trace("Duty : " + Duty);
		//trace("+++++++++++++++");
	
		Channels 			= channels;
		VehicleRegistration = vehicleRegistrationIn;
		VehicleID 			= vehicleIDIn;
		DriverName 			= driverNameIn;
		LoadType 			= loadTypeIn;
		loadCode 			= loadCodeIn;
		CMR					= CMRIn;
		Comment				= commentIn;
		Picture 			= pictureIn;
		TransporterName		= transporterNameIn;
	}
}

/**
 * 
 */
class DBReports extends DBRPMData
{
	//public var reportsArray:Map<Int, ReportData>;
	public var lastReportData:ReportData;
	public static var channelsPattern:Int;
	var bSelectOKReports:Bool;
	var bSelectNonOKReports:Bool;
	var bSelectRAReports:Bool;

	public static var REP_NOT_OK:Int	= -1;
	public static var REP_OK:Int		= 0;
	public static var REP_RA:Int		= 1;

	function new():Void 
	{
		super(); // Sync Mode

		//reportsArray 	= new Map <Int, ReportData> ();
		tableName 		= "Reports";
		timeFieldName	= "TimeIn";

		lastReportData 	= new ReportData();
		getLastRecord(onGetResult);
 	}

	/**
	 * 
	 */
	function onGetResult(res:SQLResult):Void
	{
		var reportDataRow:ReportData;

		//for (value in reportsArray){ reportsArray.remove(value.ReportNumber); }

		if (cast res.data)
		{
			for (dao in res.data)
			{
				lastReportData = new ReportData
				(
					dao.ReportNumber,
					dao.ReportResult,
					dao.TimeIn,
					dao.TimeOut,
					dao.Duty,
					dao.Channels,
					dao.VehicleRegistration,
					dao.TransporterName,
					dao.VehicleID,
					dao.DriverName,
					dao.LoadType,
					dao.LoadCode,
					dao.CMR,
					dao.Comment,
					dao.Picture); // No pictures stored in memory

				//reportsArray.set(dao.ReportNumber, lastReportData);
				recordsNumber ++;
				checkData(lastReportData);
			}
		}
	}

	/**
	 * 
	 * @param	dao
	 */
	function checkData(dao:Dynamic) 
	{
		if (dao.Duty == 0) {
			dao.Duty = (dao.TimeOut.getTime() - dao.TimeIn.getTime()) / 1000;
			updateReportDuty(dao);
		}
	}

	/**
	 * 
	 * @param	ids
	 * @return
	 */
	public function getReport (reportNumber:Int):ReportData
	{
		if (cast reportNumber)
		{
			dbStatement.clearParameters();
			dbStatement.text 		= "SELECT * FROM " + tableName + " WHERE ReportNumber = '" + reportNumber + "'";	
			dbStatement.execute();
			onGetResult(dbStatement.getResult());
		}

		return lastReportData;
	}

	/**
	 * 
	 * @param	obj
	 */
	public override function getData(obj:Dynamic):Dynamic
	{
		var duty:Float = (obj.TimeOut.getTime() - obj.TimeIn.getTime()) / 1000;
		return new MessagesTableData(obj.ReportNumber, obj.ReportResult, obj.TimeIn, cast duty);
	}

	/**
	 * 
	 */
	public function getStatistics()
	{
	}

	/**
	 * 
	 * @return
	 */
	public function getLastReportData():ReportData
	{
		return lastReportData;
	}

 	/**
	 * 
	 * @param	defaultData
	 */
	public function updateReportDuty(reportData:ReportData):Void
	{
		trace("updateReportDuty " + reportData.ReportNumber);
		var parameter:Array<Dynamic> = new Array<Dynamic>();
		
		dbStatement.text =  ("UPDATE " + tableName + " SET Duty = '" + reportData.Duty + "' WHERE ReportNumber = '" + reportData.ReportNumber + "'");
		dbStatement.execute();
	}

	/**
	 * 
	 * @param	defaultData
	 */
	public function createReport(reportData:ReportData):Void
	{
		trace("createReport");
		var parameter:Array<Dynamic> = new Array<Dynamic>();
		
		var stat:String = "INSERT INTO Reports (ReportNumber, Picture, ReportResult, TimeIn, TimeOut, Duty, Channels, VehicleRegistration, Comment, VehicleID, LoadType, LoadCode, DriverName, CMR)" + "VALUES (?, ?, ?, ? ,?, ?, ?, ? ,?,?, ?, ? ,?,?)";

		parameter[0] 	= reportData.ReportNumber;
		parameter[1] 	= reportData.Picture;
		parameter[2] 	= reportData.ReportResult;
		parameter[3] 	= reportData.TimeIn;
		parameter[4] 	= reportData.TimeOut;
		parameter[5] 	= reportData.Duty;
		parameter[6] 	= reportData.Channels;
		parameter[7] 	= reportData.VehicleRegistration;
		parameter[8] 	= reportData.Comment;
		parameter[9] 	= reportData.VehicleID;
		parameter[10] 	= reportData.LoadType;
		parameter[11] 	= reportData.loadCode;
		parameter[12] 	= reportData.DriverName;
		parameter[13] 	= reportData.CMR;
	
		pushSQL(stat, parameter, onUpdateReportDone);
		recordsNumber ++;

		//reportsArray.set(reportData.ReportNumber, reportData);
	}

	/**
	 * 
	 * @return
	 */
	override function getTimeIntervalFieldName() :String
	{
		return "TimeIn";
	}

	/**
	 * 
	 * @param	stat
	 */
	function onUpdateReportDone(stat:Dynamic) :Void
	{
		dbStatement.clearParameters();
	}

	/**
	 * 
	 */
	override function fillSQLConditions() 
	{
		if (bSelectOKReports && bSelectRAReports && bSelectNonOKReports) { strSQLConditions = ""; return; }

		strSQLConditions = " ReportResult ";

		if (bSelectOKReports || bSelectRAReports || bSelectNonOKReports)
		{
			if (bSelectOKReports && bSelectRAReports) 		{ strSQLConditions += ">='0'"; return; }
			if (bSelectOKReports && bSelectNonOKReports) 	{ strSQLConditions += "< '1'"; return; }
			if (bSelectRAReports && bSelectNonOKReports) 	{ strSQLConditions += "<> '0'"; return; }

			if (bSelectOKReports) 		{ strSQLConditions += "='0'"; return; }
			if (bSelectRAReports) 		{ strSQLConditions += ">'0'"; return; }
			if (bSelectNonOKReports)	{ strSQLConditions += "<'0'"; return; }
		}

		else { strSQLConditions += "<'-8'"; return; }
	}

	/**
	 * 
	 * @param	dateFrom
	 * @param	dateTo
	 */
	public function selectRAReports(select:Bool)
	{
		bSelectRAReports = select;
	}

	/**
	 * 
	 * @param	dateFrom
	 * @param	dateTo
	 */
	public function selectOKReports(select:Bool)
	{
		bSelectOKReports = select;
	}

	/**
	 * 
	 * @param	dateFrom
	 * @param	dateTo
	 */
	public function selectNonOKReports(select:Bool)
	{
		bSelectNonOKReports = select;
	}
}
