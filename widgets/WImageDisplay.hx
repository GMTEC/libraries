package widgets;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.ByteArray;
import org.aswing.ASColor;
import org.aswing.AssetPane;
import org.aswing.JLoadPane;
import util.Images;


/**
 * ...
 * @author GM
 */
class WImageDisplay extends WBase
{
	var loadPane	:JLoadPane;
	var imgBorder	:Sprite;
	var loader		:Loader;

	public function new(name:String, bFrame:Bool = false) 
	{
		super(name);

		if (bFrame) {
			_DrawFrame();
		}

		loadPane	= new JLoadPane(null, AssetPane.SCALE_STRETCH_PANE);
		loadPane.setWidth(cast this.W);
		loadPane.setHeight(cast this.H);
		loadPane.setScaleMode(AssetPane.SCALE_FIT_PANE);
		loadPane.setHorizontalAlignment(AssetPane.CENTER);
		addChild(loadPane);
		loader = new Loader();
		_setBitmap(Images.loadtruckRed());
	}

	/**
	 * 
	 */
	public function setBitmap(?ba:ByteArray, ?bm:Bitmap)
	{
		if(cast ba) {
			loader.loadBytes(ba);
			loader.contentLoaderInfo.addEventListener(Event.INIT, onPNGLoaded);
		}
		else {
			if (cast bm) {
				_setBitmap(bm);
			}
		}
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPNGLoaded(e:Event):Void 
	{
		var bmData:BitmapData = new BitmapData(496, 426);
		bmData.draw(loader);
		_setBitmap(new Bitmap(bmData));
	}

	/**
	 * 
	 */
	function _setBitmap(?bmIn:Bitmap)
	{
		loadPane.setAsset(bmIn);
		loadPane.doLayout();
	}

	/**
	 * 
	 */
	function _DrawFrame() 
	{
		imgBorder 	= new Sprite();
		var gfx 	= imgBorder.graphics;

		gfx.lineStyle(2, ASColor.BELIZE_HOLE.getRGB());
		gfx.beginFill(ASColor.CLOUDS.getRGB());
		gfx.drawRoundRect( 0, 0, W, H, 2);
		gfx.endFill();

		addChild(imgBorder);
	}

}