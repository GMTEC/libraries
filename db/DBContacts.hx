package db;

import flash.data.SQLConnection;
import flash.data.SQLResult;
import util.VCardReader;
import org.aswing.util.StringUtils;

/**
 * ...
 * @author GM
 */

 
class Contact
{
	public var name	:String;
	public var org		:String;
	public var address	:String;
	public var phone	:String;
	public var selected	:Bool;

	public function new(name:String, org:String, address:String, phone:String) 
	{
		this.name		= name;
		this.org		= org;
		this.address	= address;
		this.phone		= phone;
	}
}

/**
 * Table to store all text and their translations
 */
class DBContacts extends DBBase
{
	public static var contactsArray:Map<String, Contact>;

	/**
	 * Constructor (singleton)
	 */
	public function new() 
	{
		fName 			= DBBase.getConfigDataName();
		tableName		= "Contacts";
		contactsArray 	= new Map <String, Contact> ();

		super();
 	}

	/**
	 * 
	 * @param	contact
	 */
	public function addContact(contact:String, uid:String, update:Bool = false):Void 
	{
		if (uid == null)
			uid = StringUtils.createRandomIdentifier(32);

		dbStatement.clearParameters();
		dbStatement.text = "SELECT* FROM " + tableName + " WHERE UID = '" + uid + "'";
		dbStatement.execute();

		if (dbStatement.getResult().data == null)
		{
			dbStatement.text =  "INSERT INTO " + tableName + "(VCard, UID)" + "VALUES (?, ?)";

			dbStatement.parameters[0] = contact;
			dbStatement.parameters[1] = uid;
	
			dbStatement.execute();
		}
	}

	/**
	 * 
	 * @param	count
	 */
	public override function setIntervalFromCountNotStacked(?from:Int, ?count:Int, ?reverse:Bool, ?func:Dynamic->Void):Void
	{
		setIntervalFromCount(from, count, reverse, (cast func) ?  func : onApplyFilters, false);
	}

	/**
	 * 
	 * @param	obj
	 */
	public override function getData(obj:Dynamic):Dynamic
	{
		//var duty:Float = (obj.TimeOut.getTime() - obj.TimeIn.getTime()) / 1000;
		//return new MessagesTableData(obj.ReportNumber, obj.ReportResult, obj.TimeIn, cast duty);
		
		var vcard:VCard = VCardReader.ParseText(obj.VCard).pop();
		if (cast vcard)
			return  new Contact(vcard.getFullName(), vcard.getOrganization(), vcard.getAddress(), vcard.getPhone());
		else return null;
	}

	/**
	 * 
	 * @param	conditions
	 */
	public override function getFilteredData (?conditions:String = "", ?getResult:SQLResult->Void, ?fromTime:Bool = false):Int
	{
		var records:Int = super.getFilteredData(conditions, getResult);
		if (records > 0)
		{
			var vCardArray:Array<VCard>;

			if (cast sqlResult.data)
			{
				for (dao in sqlResult.data)
				{
					vCardArray = VCardReader.ParseText(dao.VCard);
					if (cast vCardArray.length)
						contactsArray.set(vCardArray[0].fullName, new Contact(vCardArray[0].getFullName(), vCardArray[0].getOrganization(), vCardArray[0].getAddress(), vCardArray[0].getPhone()));
				}
			}
		}

		return records;
 	}  
}
