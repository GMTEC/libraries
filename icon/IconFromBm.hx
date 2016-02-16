package icon;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import org.aswing.Component;
import org.aswing.graphics.Graphics2D;
import org.aswing.Icon;
import util.Images;

/**
 * 
 */
class IconFromBm implements Icon
{
	private var shape:Sprite;
	private var width:Int;
	private var height:Int;
	private var bitmap:Bitmap;

	public function new(bm:Bitmap, width:Int = 18, height:Int = 18){
		shape = new Sprite();
		bitmap = bm;
		bitmap.x += 1;
		bitmap.y += 1;
		Images.resize(bitmap, width, height);
		shape.addChild(bitmap);
	}

	public function updateIcon(com:Component, g:Graphics2D, x:Int, y:Int):Void{
	
	}

	public function getIconHeight(com:Component):Int{
		return height;
	}

	public function getIconWidth(com:Component):Int{
		return width;
	}

	public function getDisplay(com:Component):DisplayObject  
	{
		return shape;
	}
}