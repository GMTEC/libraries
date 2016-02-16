package util;
import flash.display.DisplayObject;
import haxe.Timer;
import motion.Actuate;
import motion.actuators.IGenericActuator;

/**
 * ...
 * @author GM
 */
class Fading
{
	static private var spriteToFadeIn:DisplayObject;
	static private var spriteToFadeOut:DisplayObject;
	static private var finalFade:Float;
	static private var fadingOut:Bool;

	/**
	 * 
	 * @param	sprite
	 * @param	fade
	 * @param	time
	 */
	public static function fadeIn(spriteIn:DisplayObject, fade:Float = 1, time:Float = 0.5)
	{
		fadingOut = false;
		spriteToFadeIn = spriteIn;
		spriteToFadeIn.visible = true;
		finalFade = fade;

		return Actuate.tween (spriteToFadeIn, time, { alpha: fade }, false);
	}

	/**
	 * 
	 */
	static private function functionFadeOut() 
	{
		if (fadingOut)
		{
			if(spriteToFadeOut.alpha <= 0.1)
				spriteToFadeOut.visible = false;
		}
	}

	public static function fadeOut(spriteIn:DisplayObject, fade:Float = 0, time:Float = 0.5):IGenericActuator
	{
		fadingOut = true;
		finalFade = fade;
		spriteToFadeOut = spriteIn;
		Timer.delay(functionFadeOut, cast time * 1000);

		return Actuate.tween (spriteToFadeOut, time, { alpha: fade }, false);
	}

	/**
	 * 
	 * @param	sprite
	 * @param	inOut
	 * @param	fade
	 * @param	time
	 */
	public static function fadeRevert(sprite:DisplayObject, inOut: Int, fade:Float = 1, time:Float = 1):Void
	{
		time = 0.5;
		Actuate.tween (sprite, 1, { alpha: 1 }, false).delay (time).reverse ();
	}	
}