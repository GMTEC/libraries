package comp;

import flash.media.Video;
import flash.utils.Object;
import openfl.net.NetConnection;
import openfl.net.NetStream;
import widgets.WBase;

/**
 * ...
 * @author GM
 */
class VideoPlayer extends WBase
{
	var ns	:NetStream;
	var nc	:NetConnection;
	var vid	:Video;

	/**
	 * 
	 * @param	str
	 */
	public function new(str:String) 
	{
		super(str);

		vid		= new Video(550, 400);
		nc 		= new NetConnection();
		nc.connect(null);
		ns		= new NetStream(nc);
		ns.client = this;
		
		ns.client.onMetaData = ns_onMetaData;

		addChild(vid);
		vid.attachNetStream(ns);
	}

	/**
	 * 
	 */
	function ns_onMetaData(item:Object) 
	{
		trace("metaData");
		// Resize video instance.
		vid.width = item.width;
		vid.height = item.height;
		// Center video instance on Stage.
		vid.x = (stage.stageWidth - vid.width) / 2;
		vid.y = (stage.stageHeight - vid.height) / 2;		
	}

	/**
	 * 
	 * @param	strMovie
	 */
	public function play(strMovie:String)
	{
		ns.play(strMovie); 
	}
}