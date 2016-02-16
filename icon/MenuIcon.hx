package icon;

import flash.display.BitmapData;
import flash.geom.Matrix;
import org.aswing.Icon;
import org.aswing.graphics.SolidBrush;
import flash.display.Sprite;
import org.aswing.Component;
import flash.display.DisplayObject;
import org.aswing.graphics.Graphics2D;
import org.aswing.AsWingUtils;
import flash.display.DisplayObjectContainer;
import flash.display.Bitmap;
import util.Images;
import widgets.SpriteMenuButton;

/**
 * 
 */
class MenuIcon implements Icon
{
	public var shape:SpriteMenuButton;
	private var width:Int;
	private var height:Int;
	var bmData:BitmapData;
	var bitmap:Bitmap;
	var mat:Matrix;

	public function new(spriteIn:SpriteMenuButton)
	{
		if (spriteIn != null)
		{
			shape = spriteIn;
		}
		else
		{
			//mat 	= new Matrix();
			////shape 	= new Sprite();
			//mat.translate(width, height);
			//bmData 	= new BitmapData(width, height);
			//bitmap = new Bitmap();
		}
	}

	/**
	 * 
	 * @param	anSprite
	 */
	public function setAnimatedSprite(animSprite:Sprite):Void
	{
		bmData.draw(animSprite, mat);
		bitmap.bitmapData = bmData;
	}

	/**
	 * 
	 * @param	com
	 * @param	g
	 * @param	x
	 * @param	y
	 */
	public function updateIcon(com:Component, g:Graphics2D, x:Int, y:Int):Void{
	
	}

	public function getIconHeight(com:Component):Int{
		return height;
	}

	public function getIconWidth(com:Component):Int{
		return width;
	}

	public function getDisplay(comp:Component):DisplayObject  
	{
		return (cast shape) ? shape.getComponent(comp) : null;
	}
}