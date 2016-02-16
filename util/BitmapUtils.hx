package util;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.geom.Point;
import org.aswing.ASColor;
import openfl.geom.ColorTransform;

//import flash.filters.ColorMatrixFilter;
	

/**
 * ...
 * @author GM
 */
class BitmapSmoothed extends Bitmap
{

	public function new(?bitmapData:BitmapData, ?pixelSnapping:PixelSnapping, smoothing:Bool=true) 
	{
		//filters = name[new ColorMatrixFilter ([
		
		super(bitmapData, PixelSnapping.AUTO, smoothing);
	}
}

class BitmapGlyph extends Bitmap
{
	static var ctI:ColorTransform = new ColorTransform(1, 1, 1, 1, ASColor.WET_ASPHALT.getRed(), ASColor.WET_ASPHALT.getGreen(), ASColor.WET_ASPHALT.getBlue());
	static var ct:ColorTransform = new ColorTransform(1, 1, 1, 1, ASColor.CLOUDS.getRed(), ASColor.CLOUDS.getGreen(), ASColor.CLOUDS.getBlue());

	public function new(?bitmapData:BitmapData, invert:Bool=false) 
	{
		bitmapData.colorTransform(bitmapData.rect, invert ? BitmapGlyph.ctI : BitmapGlyph.ct);
		
		super(bitmapData, PixelSnapping.AUTO, true);
	}
}
