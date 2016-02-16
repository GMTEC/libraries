package db;

import db.DBUsers.User;
import events.PanelEvents;
import flash.data.SQLConnection;
import flash.data.SQLResult;
import haxe.crypto.Md5;

/**
 * ...
 * @author GM
 */

class User
{
    public var ID:Int;
 	public var name : String;
 	public var password : String;
 	public var security : Int;

	public function new(nameIn:String, passwordIn:String, securityIn:Int)
	{
		name		= nameIn;
		password	= passwordIn;
		security	= securityIn;
	}
}

class DBUsers extends DBBase
{
	var errorMsg:String;
	public static var connection:SQLConnection;
	public static var UsersMap: Map<String, User>;  // Table for Users

	public function new():Void 
	{
		UsersMap 		= new Map <String, User> ();
		fName 			= DBBase.getConfigDataName();
		tableName		= "Users";

		super();

		getUsers();		
	}

	/**
	 * 
	 * @param	key
	 * @return
	 */
	public function getUser(key:String):User
	{
		return UsersMap.get(key);
	}

	public function addUser(name:String, pass:String, sec:Int):Void 
	{
		//UsersMap.set(name, new User(name, pass, sec));
		//connection.request("INSERT INTO Users(Name, Password, Security) VALUES ('"
			//+ name + "','"
			//+ pass + "',"
			//+ sec + ")");
	}

	/**
	 * Get the Users
	 * @param	lang
	 */
	public function getUsers ():Void
	{
		dbStatement.text =  ("SELECT * FROM " + tableName);

		dbStatement.execute();
		var sqlResult:SQLResult = dbStatement.getResult();

		for (dao in sqlResult.data)
		{
			UsersMap.set(dao.Name, new User(dao.Name, dao.Password, dao.Security));
		}
 	}

	/**
	 * 
	 * @param	name
	 * @param	pass
	 */
	public function checkNamePasswordOK(name:String, ?pass:String, nopassword:Bool = false) 
	{
		if(DBUsers.UsersMap.exists(name))
		{
			var user:User 	= DBUsers.UsersMap.get(name);

			if (nopassword || user.password == Md5.encode(name + pass))
			{
				Session.currentUser 		= user;
				Session.privilegeSuperUser 	= user.security > 1;
				Session.priviledgeAdmin 	= user.security >= 3;

				Main.root1.dispatchEvent(new ParameterEvent(PanelEvents.EVT_USER_LOGGING, user.name));

				return true;
			}
			errorMsg = "IDS_MSG_DLG_PASSWORD_ERROR";
		}
		else
			errorMsg = "IDS_MSG_DLG_USER_ERROR";
		return false;
	}

	/**
	 * 
	 * @param	name
	 * @param	pass
	 */
	public function updatePassword(userName:String, newPass:String) : Bool
	{
		dbStatement.clearParameters();

		dbStatement.text = ("UPDATE " + tableName + " SET Password = '" + newPass +  "' WHERE Name = '" + userName + "'");
		dbStatement.execute();

		var user:User = getUser(userName);
		user.password = newPass;
		UsersMap.set(userName, user);

		return true;
	}

	/**
	 * 
	 */
	public function getErrorMessage() 
	{
		return errorMsg;
	}
}
