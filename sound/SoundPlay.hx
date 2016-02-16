package sound;

import com.haxepunk.Sfx;
import com.haxepunk.tweens.sound.SfxFader;
import db.DBSounds.SoundData;
import flash.events.EventDispatcher;
import flash.media.Sound;
import haxe.Timer;

@:sound("assets/snd/trut.wav" )			class SndTrut extends Sound { }
@:sound("assets/snd/clic.wav" )			class SndClic extends Sound { }
@:sound("assets/snd/chrono.wav" )		class SndShortHorn extends Sound { }
@:sound("assets/snd/Bip Belt.wav" )		class SndBelt extends Sound { }
@:sound("assets/snd/Test Bip.wav" )		class SndTestBeep extends Sound { }
@:sound("assets/snd/Nuclear Horn.wav" )	class SndNuclear extends Sound { }
@:sound("assets/snd/geiger.mp3" )		class SndGeiger extends Sound { }
@:sound("assets/snd/Whip.wav" )			class SndWhip extends Sound { }

/**
 * ...
 * @author GM
 */
class SoundPlay extends EventDispatcher
{
	public var sndFader:SfxFader;
	var updateTimer:Timer;
	var loopSound:Bool;
	var soundData:SoundData;
	var sndCallback:Dynamic;

	/**
	 * 
	 * @param	soundDataIn
	 * @param	timesIn
	 */
	public function new(soundDataIn:SoundData) 
	{
		super();

		soundData = soundDataIn;
		soundDataIn.soundPlay = this;

		sndFader = new SfxFader(new Sfx(getSoundClass(soundData.FileName)));
	}

	function getSoundClass(fileName:String):Sound
	{
		switch (fileName)
		{
			case "SndNuclear": 		return new SndNuclear();
			case "SndTrut": 		return new SndTrut();
			case "SndClic": 		return new SndClic();
			case "SndShortHorn": 	return new SndShortHorn();
			case "SndBelt": 		return new SndBelt();
			case "SndTestBeep": 	return new SndTestBeep();
			case "SndGeiger": 		return new SndGeiger();
			case "SndWhip": 		return new SndWhip();

			default: 				return null;
		}
	}

	/**
	 * 
	 */
	public function play():Void
	{
		if (soundData.Volume > 0)
		{
			loopSound = false;
			sndFader.sfx.play(soundData.Volume / 100);
		}
	}

	/**
	 * 
	 */
	public function loop():Void
	{
		trace("loop()");
		loopSound = true;
		sndCallback = loopComplete.bind();
		sndFader.sfx.complete = sndCallback;
		sndFader.sfx.loop(soundData.Volume / 100);
		trace("loop");
	}

	/**
	 * 
	 */
	function loopComplete(): Void
	{
		if(!loopSound)
			sndFader.sfx.stop();
			
		sndFader.sfx.volume = soundData.Volume / 100;
	}

	/**
	 * 
	 */
	public function stop():Void
	{
		loopSound = false;
	}
}