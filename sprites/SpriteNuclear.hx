package sprites ;

import comp.BitmapsFaded;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;
import tweenx909.TweenX;
import util.Fading;
import util.Filters;
import util.Images;

/**
 * ...
 * @author GM
 */
class SpriteNuclear extends Sprite
{
	var bm1				:Bitmap;
	var bm2				:Bitmap;
	var toggle			:Bool;
	var bmToFade		:BitmapsFaded;

	public function new(top:Bool = false) 
	{
		super();

		bmToFade 	= new BitmapsFaded(Images.loadSignalNeutral());
		bm1 		= Images.loadNuclear();
		bm2 		= Images.loadNuclear45();
		bm2.visible = false;

		if (top)
		{
			Images.resize(bm1, 128, 128);
			Images.resize(bm2, 128, 128);

			bm1.x += 62;
			bm1.y -= 40;

			bm2.x += 62;
			bm2.y -= 40;
		}

		bm1.filters = Filters.glowFilters;
		bm2.filters = Filters.glowFilters;
		addChild(bm1);
		addChild(bm2);
		bmToFade.animateBitmaps(bm1, bm2, DefaultParameters.tweenTime);
	}

}