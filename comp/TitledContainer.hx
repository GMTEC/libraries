package comp;
import db.DBTranslations;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextFieldAutoSize;
import org.aswing.Container;
import text.JTextHBase;
import util.Images;

/**
 * ...
 * @author GM
 */
class TitledContainer extends Container
{
	public var tfTitle			:JTextHBase;
	public var	spriteLeft		:Sprite;

	public function new(label:String = "", bmIn:Bitmap = null) 
	{
		super();

		if (cast bmIn)
		{
			Images.resize(bmIn, 24, 24);
			spriteLeft = new Sprite();
			spriteLeft.addChild(bmIn);
			spriteLeft.alpha = 0.8;
			addChild(spriteLeft);
		}

		tfTitle = new JTextHBase(label.indexOf("IDS") >= 0 ? DBTranslations.getText(label) : label);
		tfTitle.getTextField().autoSize =  TextFieldAutoSize.LEFT;
		addChild(tfTitle);
	}

	/**
	 * 
	 * @param	str
	 */
	public function setTitle(str:String):Void {
		tfTitle.setHtmlTextAndSize(str);
	}

	/**
	 * 
	 * @param	xIn
	 * @param	yIn
	 * @param	wIn
	 * @param	hIn
	 * @param	align
	 */
	public function setComBoundsXYWHTopAlign(xIn:Int, yIn:Int, wIn:Int = 100, hIn:Int = 34):Void
	{
		if (cast tfTitle)
			tfTitle.setComBoundsXYWH(xIn, yIn - 24, 240, hIn);		

		if (cast spriteLeft)
		{
			spriteLeft.x = xIn - spriteLeft.width - 12;
			spriteLeft.y = yIn;
		}
	}	
}