package widgets;

import enums.Enums.Parameters;
import flash.display.Sprite;
import util.Images;
import flash.display.Bitmap;
import util.Filters;

/**
 * ...
 * @author GM
 */
class WFrame extends WBaseLarge
{
	var frameWidget:Sprite;

	public function new(name:String) 
	{
		super(name);

		createBackground(Parameters.WIDTH_CENTERPANE, 352, this, false);
	}
}