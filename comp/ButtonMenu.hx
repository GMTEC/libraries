package comp;

import comp.JButtonFramed;
import flash.display.Bitmap;
import flash.display.Sprite;
import org.aswing.AsWingConstants;
import widgets.SpriteMenuButton;

/**
 * ...
 * @author GM
 */
class ButtonMenu extends JButtonFramed
{
	var butBitmap:			Sprite;
	var selected:			Bool;
	var bmFillOn:			Bitmap;
	var bmFillOff:			Bitmap;
	var bmLogo:				Bitmap;
	var W:					Float = 32;
	var H:					Float = 32;

	public function new(name:String, xIn:Int, yIn:Int, wIn:Int, hIn:Int, text:String = "", ?spriteIn:SpriteMenuButton = null, ?sprite:Sprite, iconSizeIn:Int = 0) 
	{
		super(name, xIn, yIn, wIn, hIn, text, spriteIn);

		setVerticalAlignment(AsWingConstants.BOTTOM);

		setSelected(false);
	}

}