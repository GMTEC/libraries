package comp;

import flash.display.Bitmap;
import flash.display.Sprite;
import tweenx909.TweenX;

/**
 * ...
 * @author GM
 */
class BitmapsFaded extends Sprite
{
	var bmOld			:Bitmap;
	var bmNew			:Bitmap;

	public function new(bm:Bitmap = null) 
	{
		super();

		if (cast bm) addChild(bm);

		bmOld 			= new Bitmap();
		bmNew 			= new Bitmap();

		addChild(bmNew);
		addChild(bmOld);
	}

	/**
	 * 
	 * @param	bm
	 */
	public function animateBitmaps(bm1:Bitmap, bm2:Bitmap, repInterval:Float):Void
	{
		bmOld.bitmapData = bm1.bitmapData;
		bmNew.bitmapData = bm2.bitmapData;

		TweenX.parallel([
			TweenX.tweenFunc(fadeNewBitmap, [0] , [1], DefaultParameters.tweenTime),
			TweenX.tweenFunc(fadeOldBitmap, [1] , [0], DefaultParameters.tweenTime), ]).repeat().interval(repInterval);
	}

	/**
	 * 
	 */
	public function setNewBitmap(bm:Bitmap):Void
	{
		if (bmNew.bitmapData != bm.bitmapData)
		{
			bmNew.bitmapData = bm.bitmapData;

			TweenX.parallel([

				TweenX.tweenFunc(fadeNewBitmap, [0] , [1], DefaultParameters.tweenTime),
				TweenX.tweenFunc(fadeOldBitmap, [1] , [0], DefaultParameters.tweenTime)]).onFinish(swapBitmaps);
		}
	}

	/**
	 * 
	 */
	function swapBitmaps() :Void
	{
		bmOld.bitmapData = bmNew.bitmapData;
	}

	function fadeNewBitmap(alpha:Float) {bmNew.alpha = alpha;}
	function fadeOldBitmap(alpha:Float) {bmOld.alpha = alpha;}
}