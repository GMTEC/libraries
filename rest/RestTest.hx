package rest;

#if sys
import Sys;
#end

class RestTest
{
	/**
	 * 
	 * @return
	 */
	static public function ledOff()
	{
		RestClient.postAsync("https://api.spark.io/v1/devices/53ff6b066667574821552567/toggleRelay-daccess_token=5612ac17c0889bfb26f7fb1a311a3258eb31e4c2-dcommand=LEDOFF", onData, null, onError);
	}
	
	public static function onData(err:String)
	{
		trace("On Data : " + err);
	}
	
	public static function onError(err:String)
	{
		trace("On Error : " + err);
	}
}

