package tools;

import flash.display.Sprite;
import org.aswing.ASColor;
import tools.ToolsVertWidget;
import tools.WTools.ToolButton;
import util.Images;

/**
 * ...
 * @author GM
 */
class ToolsView extends ToolsVertWidget
{
	public var butPrint:ToolButton;
	public var butZoomPlus:ToolButton;
	public var butCancel:ToolButton;
	public var butZoomMin:ToolButton;
	var bgSprite	:Sprite;

	public function new(name:String, ?w:Int=32, ?h:Int=32, onButZoomPlus:Dynamic->Void, onButZoomMinus:Dynamic->Void, onButPrint:Dynamic->Void, onButCancel:Dynamic->Void) 
	{
		//scaleX = scaleY = 0.75;
		bgSprite 	= new Sprite();
		var gfx 	= bgSprite.graphics;
		gfx.beginFill(ASColor.WET_ASPHALT.getRGB());
		gfx.drawRoundRect(0, 0, w - 10, h*3.7, 8);
		gfx.endFill();
		addChild(bgSprite);

		super(name, w, h);
		x = y = 4;

		butZoomPlus = push(Images.loadZoomPlus(), null,	 " ", "IDS_TT_PLOT_ZOOM_PLUS", 	onButZoomPlus);
		butZoomMin 	= push(Images.loadZoomMinus(), null,  " ", "IDS_TT_PLOT_ZOOM_MINUS",onButZoomMinus);
		butPrint 	= push(Images.loadPrinter(), null,	 " ", "IDS_TT_REPORT_PRINT", 	onButPrint);
		butCancel 	= push(Images.loadCancel(), null,	  " ", "IDS_TT_CLOSE_PREVIEW", 	onButCancel);

		oninitButtons();
	}
}