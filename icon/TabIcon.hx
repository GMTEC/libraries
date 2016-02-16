package icon;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import org.aswing.Component;
	import org.aswing.graphics.Graphics2D;
	import org.aswing.Icon;
	import util.Filters;
	import util.Images;

	class TabIcon implements Icon
	{
		private var width:Int = 24;
		private var height:Int = 24;
		private var shape:Sprite;
		private var bitmap:Bitmap;

		/**
		 * 
		 * @param	bm
		 */
		public function new(bm:Bitmap)
		{
			shape = new Sprite();
			shape.x += 4;
			shape.y += 4;
			Images.resize(bm, width, height);
			shape.addChild(bm);
			//shape.alpha = 0.8;
			//shape.filters = Filters.filterWhiteShadow;
		}

		public function updateIcon(com:Component, gfx:Graphics2D, x:Int, y:Int):Void
		{
			//shape.graphics.clear();
			//gfx = new Graphics2D(shape.graphics);
			//
			//gfx.fillRectangle(bBrush, x, y, width, height);
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