package sound;

import db.DBSounds;
import flash.events.Event;
import flash.media.Sound;
import haxe.Timer;
import events.PanelEvents;
import sound.SoundPlay;

/**
 * ...
 * @author GM
 */
class SoundFile
{
	public var name		:String;
	public var file		:String;

	public function new(name:String, file:String) 
	{
		this.name = name;
		this.file = file;
	}
}

/**
 * 
 */
class Sounds extends DBSounds
{	
	static public var sndRAAlarm:SoundPlay;
	static public var sndPortalFree:SoundPlay;
	static public var sndBKGTimer:SoundPlay;
	static public var sndPortalBusy:SoundPlay;
	static public var sndTest:SoundPlay;
	static public var sndAlarm:SoundPlay;
	static public var sndGeiger:SoundPlay;
	static public var sndMotion:SoundPlay;
	static public var soundFiles:Array <SoundFile>;

	static var timer:Timer;

	/**
	 * 
	 */
	public function new():Void 
	{
		super();

		soundFiles = new Array <SoundFile>();
		soundFiles.push(new SoundFile("Horn", 		"SndShortHorn"));
		soundFiles.push(new SoundFile("Click", 		"SndClic"));
		soundFiles.push(new SoundFile("Nuclear", 	"SndNuclear"));
		soundFiles.push(new SoundFile("Belt", 		"SndBelt"));
		soundFiles.push(new SoundFile("Geiger", 	"SndGeiger"));
		soundFiles.push(new SoundFile("Beep", 		"SndTrut"));
		soundFiles.push(new SoundFile("Test", 		"SndTestBeep"));
		soundFiles.push(new SoundFile("Motion", 	"SndMotion"));

		init();
	}

	/**
	 * 
	 * @param	name
	 * @return
	 */
	public function getSoundFileName(name:String):String
	{
		for (dao in soundFiles)
		{
			if (dao.name == name)
				return dao.file;
		}
		
		return null;
	}

	/**
	 * 
	 */
	public function init()
	{
		sndRAAlarm		= new SoundPlay(DBSounds.soundsMap.get("IDS_SND_RAALARM"));
		sndPortalFree	= new SoundPlay(DBSounds.soundsMap.get("IDS_SND_PORTAL_FREE"));
		sndBKGTimer		= new SoundPlay(DBSounds.soundsMap.get("IDS_SND_CLICK"));
		sndPortalBusy	= new SoundPlay(DBSounds.soundsMap.get("IDS_SND_PORTAL_BUSY"));
		sndTest			= new SoundPlay(DBSounds.soundsMap.get("IDS_SND_TEST"));
		sndAlarm 		= new SoundPlay(DBSounds.soundsMap.get("IDS_SND_ERROR"));
		sndGeiger 		= new SoundPlay(DBSounds.soundsMap.get("IDS_SND_GEIGER"));
		sndMotion 		= new SoundPlay(DBSounds.soundsMap.get("IDS_SND_MOTION"));
  
		Main.root1.addEventListener(PanelEvents.EVT_TEST_MODE_ON, onTestOn);
		Main.root1.addEventListener(PanelEvents.EVT_TEST_MODE_OFF, onTestOff);
	}

	public static function onPortalBusy() 
	{
		Sounds.sndPortalBusy.play();
	}

	public static function onPortalFree() 
	{
		Sounds.sndPortalFree.play();
	}

	public static function onInitElapsed() 
	{
		onPortalFree();
	}

	static private function onTestOn(e:Event):Void 
	{
		sndTest.play();
	}

	static private function onTestOff(e:Event):Void 
	{
		sndTest.play();
	}

	static public function playBKGClic():Void 
	{
		sndBKGTimer.play();
	}

}
