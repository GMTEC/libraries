package db;

import flash.data.SQLConnection;
import flash.data.SQLStatement;

/**
 * ...
 * @author GM
 */
class SQLBase
{
	var connection:SQLConnection;
	var sql:String;
	var statement:SQLStatement;

	public function new() 
	{
		statement = new SQLStatement();
	}
	
}