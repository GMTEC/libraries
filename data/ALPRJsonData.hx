package data;

import events.PanelEvents;
import haxe.format.JsonParser;
import haxe.Json;
import openfl.events.Event;

/**
 * ...
 * @author GM
 */

 typedef Candidate = {
	 var plate:String;
	 var matches_template:Int;
	 var confidence:Float;
 }
 
 typedef Coordinate = {
	 var x:Int;
	 var y:Int; 
 }
 
 typedef Region = {
	 var coordinates:Array<Coordinate>;
 }
 
 typedef Result = {
	 var candidates:Array<Candidate>;
	 var coordinates:Array<Region>;
 }
 
 typedef ALPRData = {
	var data_type:String;
	var epoch_time:String;
	var img_hight:String;
	var img_width:String;
	var results:Array<Result>;
}

class ALPRJsonData
{
	var alprData:ALPRData;

	public function new() 
	{
	}

	/**
	 * 
	 * @param	s
	 * @return
	 */
	public function parse(s:String):Bool
	{
		if (s.indexOf('Frame') == -1)
		{
			trace (s);
			alprData = Json.parse(s);
			
			Main.root1.dispatchEvent(new Event(PanelEvents.EVT_ALPR_DETECTED));
			return true;
		}

		return false;
	}
	
	/**
	 * 
	 * @return
	 */
	public function getPlate():String
	{
		return alprData.results.length > 0 ?  alprData.results[0].candidates[0].plate : null;
	}
}