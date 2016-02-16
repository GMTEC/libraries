package tools;

import flash.data.SQLResult;
import util.Images;
import util.VCardImport;

/**
 * ...
 * @author GM
 */
class ToolSQLContacts extends ToolSQL
{
	public function new(name:String, ?w:Int=32, ?h:Int=32, func:SQLResult->Void) 
	{
		super(name, w, h, func);

		push(Images.loadReport(), 		Images.loadReport(),  				" ", "IDS_TT_MENU_RAOFF",	onButImport); // 6

		setDBTable(Session.dbContacts);

		oninitButtons();
	}

	/**
	 * 
	 */
	public override function init():Void {
		onButError(null); onButRA(null);
	}

	/**
	 * 
	 * @param	e
	 */
	function onButImport(e:Dynamic) :Void
	{
		var vcardImport:VCardImport = new VCardImport();
		vcardImport.importVCardFromFile();
		onGetResultFunc(null);
	}

	/**
	 * 
	 * @param	e
	 */
	function onButRA(e:Dynamic) :Void
	{
	}

	/**
	 * 
	 * @param	e
	 */
	function onButError(e:Dynamic) :Void
	{
	}
}