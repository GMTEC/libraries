package comp;

import flash.events.MouseEvent;
import icon.MenuIcon;
import org.aswing.ASColor;
import org.aswing.JButton;
import db.DBTranslations;

/**
 * ...
 * @author GM
 */
class JButton2 extends JButton
{	
	public function new(x:Int, y:Int, wIn:Int, hIn:Int, label:String = "", iconIn:MenuIcon = null, func: Dynamic -> Void = null) 
	{
		super(label.indexOf("IDS") >= 0 ? DBTranslations.getText(label) : label, iconIn);

		//if ((cast iconIn) && cast iconIn.shape)
		//{
			//iconIn.shape.x += (this.width 	- iconIn.shape.width) / 2;
			//iconIn.shape.y += (this.height 	- iconIn.shape.height) / 2;
		//}

		setComBoundsXYWH(x, y, wIn, hIn);

		if (func != null)
			addEventListener(MouseEvent.CLICK, func);
	}

	/**
	 * 
	 * @param	text
	 */
	public override function setText(label:String)
	{
		super.setText(label.indexOf("IDS") >= 0 ? DBTranslations.getText(label) : label);
	}
}