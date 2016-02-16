package comp;

import db.DBTranslations;
import flash.events.MouseEvent;
import org.aswing.ASColor;
import org.aswing.ASFont;
import org.aswing.Icon;
import org.aswing.JRadioButton;

/**
 * ...
 * @author GM
 */
class JRadioButton1 extends JRadioButton
{
	var DEFFONT:String = "Microsoft Sans Serif";
	public function new(x:Int, y:Int, text:String = "", icon:Icon = null, func: Dynamic -> Void = null) 
	{
		super(DBTranslations.getText(text), icon);

		setFont(new ASFont(DEFFONT, 12, true));
		setFontValidated(true);
		//setComBoundsXYWH(x, y, 160, 32);
		//setSizeWH(160, 32);
		setBackground(new ASColor(0x0095ff, 1));
		alpha = 1;

		if (func != null)
			addEventListener(MouseEvent.CLICK, func);
	}
}