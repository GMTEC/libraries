package util;

import flash.filters.DropShadowFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import enums.Enums;
import db.DBDefaults;
import flash.filters.GlowFilter;
import org.aswing.ASColor;

/**
 * ...
 * @author GM
 */
class Filters
{
	static var singleton = true;
	public static var filterWhiteShadow;
	public static var filterInnerFont;
	public static var winFilters;
	public static var centerWinFilters;
	public static var glowFilters;
	public static var portalFilter;
	
	public function new() 
	{
		if (singleton)
		{
			singleton = false;
			//trace("Static Constructor Filter()");
			winFilters 				= new Array<BitmapFilter>();
			glowFilters				= new Array<BitmapFilter>();
			centerWinFilters 		= new Array<BitmapFilter>();
			filterInnerFont 		= new Array<BitmapFilter>();
			filterWhiteShadow 		= new Array<BitmapFilter>();
			portalFilter	 		= new Array<BitmapFilter>();
	
			winFilters.push(getBitmapWinFilters());
	
			centerWinFilters.push(getDialogShadow(120));
			centerWinFilters.push(getDialogShadow(60));
		
			portalFilter.push(getRightBlurFilter());
			portalFilter.push(getLeftBlurFilter());
		
			filterWhiteShadow.push(getBitmapFilterWhiteShadow());
			filterInnerFont.push(getBitmapFilterInnerFont());

			glowFilters.push(new GlowFilter(0xffffff, 0.5, 40, 40, 8, 10, false, false));

			//centerWinFilters = null;
		}
	}

	/**
	 * 
	 * @return
	 */
	static private function getBitmapFilterWhiteShadow() :Dynamic
	{
		var color:Int = ASColor.CLOUDS.getRGB();
		var angle:Float = -45;
		var alpha:Float = 0.8;
		var blurX:Float = 8;
		var blurY:Float = 8;
		var distance:Float = 0;
		var strength:Float = 1;
		var inner:Bool = false;
		var knockout:Bool = DBDefaults.getBoolParam(Parameters.paramKnockoutPanels);
		var quality:Int = BitmapFilterQuality.HIGH;
		return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);	
	}

	static var colorBlur:Int = 0x888888;
	//static var colorBlur:Int = 0x9893b8;
	/**
	 * 
	 * @return
	 */
	public static function getRightBlurFilter():Dynamic
	{
		var color:Int = colorBlur;
		var angle:Float = 0;
		var alpha:Float = 1;
		var blurX:Float = 8;
		var blurY:Float = 8;
		var distance:Float = -4;
		var strength:Float = 1;
		var inner:Bool = true;
		var knockout:Bool = DBDefaults.getBoolParam(Parameters.paramKnockoutPanels);
		var quality:Int = BitmapFilterQuality.HIGH;
		return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
	}

	public static function getDialogShadow(angleIn:Float):Dynamic
	{
		var color:Int = ASColor.BLACK.getRGB();
		var angle:Float = angleIn;
		var alpha:Float = 0.4;
		var blurX:Float = 20;
		var blurY:Float = 20;
		var distance:Float = 30;
		var strength:Float = 1;
		var inner:Bool = false;
		var knockout:Bool = false;
		var quality:Int = BitmapFilterQuality.HIGH;
		return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
	}

	/**
	 * 
	 * @return
	 */
	public static function getLeftBlurFilter():Dynamic
	{
		var color:Int = colorBlur;
		var angle:Float = 180;
		var alpha:Float = 1;
		var blurX:Float = 8;
		var blurY:Float = 8;
		var distance:Float = -4;
		var strength:Float = 1;
		var inner:Bool = true;
		var knockout:Bool = DBDefaults.getBoolParam(Parameters.paramKnockoutPanels);
		var quality:Int = BitmapFilterQuality.HIGH;
		return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
	}

	public static function getBitmapWinFilters():Dynamic
	{
		//Main.trace("getBitmapWinFilters()");
		var color:Int = 0x000000;
		var angle:Float = 45;
		var alpha:Float = 0.8;
		var blurX:Float = 4;
		var blurY:Float = 4;
		var distance:Float = 4;
		var strength:Float = 0.65;
		var inner:Bool = false;
		var knockout:Bool = false;
		var quality:Int = BitmapFilterQuality.HIGH;
		return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
	}	

	public static function getBitmapFilterInnerFont():Dynamic
	{
		return getBitmapWinFilters();
		//trace("getBitmapWinFilters()");
		var color:Int = ASColor.CLOUDS.getRGB();
		var angle:Float = 225;
		var alpha:Float = 1;
		var blurX:Float = 0;
		var blurY:Float = 0;
		var distance:Float = 2;
		var strength:Float = 0.65;
		var inner:Bool = true;
		var knockout:Bool = false;
		var quality:Int = BitmapFilterQuality.HIGH;
		return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
	}
}
