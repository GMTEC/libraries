package db;

import db.DBBase.DBCommand;
import flash.data.SQLConnection;
import flash.data.SQLResult;
import flash.net.Responder;

/**
 * 
 */
class SQLCommand
{
	public var cmd			:DBCommand;
	public var statement	:String;
	public var parameters	:Array<Dynamic>;
	public var result		:Dynamic->Void;
	public var status		:Dynamic->Void;

	public function new(cmdIn:DBCommand, strStat:String, ?param:Array<Dynamic>, ?res:Dynamic->Void, ?stat:Dynamic->Void) 
	{
		cmd			= cmdIn;
		statement 	= strStat;
		parameters	= param;
		result		= res;
		status		= stat;
	}
}

/**
 * ...
 * @author GM
 */
class DBRPMData extends DBBase
{
	public static var dbBase:DBBase;
	public static var arrayStatements:Array<SQLCommand>;

	public function new(getData:Bool = false, async:Bool = false)
	{
		fName		= DBBase.getRPMDataName();

		if (!cast dbConnection)
		{
			dbConnection 	= new SQLConnection();
			arrayStatements = new Array<SQLCommand>();
		}

		super(getData, async);
	}

	/**
	 * 
	 * @param	count
	 */
	public override function setIntervalFromCount(?from:Int, ?count:Int, ?reverse:Bool, ?func:Dynamic->Void, ?stacked:Bool = true):Void
	{
		if (!stacked && DBRPMData.arrayStatements.length > 0)
		{
			trace("setIntervalFromCountNotStacked");
			DBRPMData.arrayStatements.splice(0, DBRPMData.arrayStatements.length); // Erase the Array
		}

		super.setIntervalFromCount(from, count, func, stacked);
	}

	/**
	 * 
	 * @param	res
	 */
	override function onGetRecordsResult(res:SQLResult) 
	{
	}

	/**
	 * 
	 * @param	sql
	 * @param	func
	 */
	public override function pushSQL(sql:String, param:Dynamic, ?respFunc:Dynamic->Void):Void
	{
		DBRPMData.arrayStatements.push(new SQLCommand(getRPMCommand(), sql, cast param, respFunc, onDBAsyncError));

		if (!dbStatement.executing)
			executeNextStatement();
	}


	/**
	 * 
	 */
	public override function areStackedActions():Bool 
	{
		return cast arrayStatements.length;
	}

	/**
	 * 
	 */
	function executeNextStatement(res:SQLResult = null):Void
	{
		if (cast nextStatementFunc)
			onNextFunction( nextStatementFunc, res);

		nextStatementFunc 				= null;

		if((cast res) && res.lastInsertRowID > 0)
			recordsNumber 				= cast res.lastInsertRowID;
		trace("Last Record: " + recordsNumber);

		if (areStackedActions())
		{
			var sqlCommand:SQLCommand 	= arrayStatements.pop();
			dbStatement.text 			= sqlCommand.statement;

			var index 					= 0;

			if (cast sqlCommand.parameters)
			{
				for (param in sqlCommand.parameters)
				{
					dbStatement.parameters[index++] = param;
				}
			}

			nextStatementFunc 			= sqlCommand.result;
			trace("Execute: " + dbStatement.text);
			dbStatement.execute( -1, new Responder(executeNextStatement, sqlCommand.status));
		}
	}

	/**
	 * 
	 * @param	func
	 * @param	res
	 */
	function onNextFunction(func:SQLResult->Void, res:SQLResult) 
	{
		if((cast res) && (cast res.data)) func(res);
	}
}