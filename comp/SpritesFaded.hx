package comp;

import flash.display.Bitmap;
import flash.display.Sprite;
import tweenx909.TweenX;

/**
 * ...
 * @author GM
 */
class SpritesFaded extends Sprite
{
	var spOld			:Sprite;
	var spNew			:Sprite;

	public function new(bm:Bitmap = null) 
	{
		super();

		if (cast bm) addChild(bm);

		spOld 			= new Sprite();
		spNew 			= new Sprite();

		addChild(spNew);
		addChild(spOld);
	}

	/**
	 * 
	 */
	public function setNewSprite(bm:Sprite):Void
	{
		if (spNew != bm)
		{
			bm.visible = true;
			addChild(bm);
			spNew = bm;

			TweenX.parallel([
				TweenX.tweenFunc(fadeNewBitmap, [0] , [1]),
				TweenX.tweenFunc(fadeOldBitmap, [1] , [0]), ]).onFinish(swapBitmaps);
		}
	}

	/**
	 * 
	 */
	function swapBitmaps() :Void
	{
		spOld = spNew;
	}

	function fadeNewBitmap(alpha:Float) {spNew.alpha = alpha;}
	function fadeOldBitmap(alpha:Float) {spOld.alpha = alpha;}
}