package zibase;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import rest.RestClient;

/**
 * ...
 * @author GM
 */
class Zapi extends EventDispatcher
{
	var strLogin	:String = "guymenten";
	var strPassw	:String = "mortagne";
	var strID		:String = "ZIBASE00138b";
	var strToken	:String = "b24a15f48f";
	var strHeader	:String = "https://zibase.net/api/get/ZAPI.php?";
	var mapParams	:Map < String, String >;

	/**
	 * 
	 * @param	target
	 */
	public function new(?target:IEventDispatcher) 
	{
		super();
		
		RestClient.postAsync(_getUserData(), onData, onError);
	}

	/**
	 * 
	 */
	function onError(error:Dynamic) 
	{
		trace(error);
	}

	/**
	 * 
	 */
	function onData(data:Dynamic) 
	{
		trace(data);
	}

	/**
	 * 
	 */
	function _getUserData():String
	{
		return strHeader + "login=" + strLogin + "&password=" + strPassw + "&service=get&target=token";
	}
}