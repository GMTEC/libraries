package comp;
import db.DBTranslations;
import icon.MenuIcon;
import org.aswing.AbstractButton;
import org.aswing.event.AWEvent;
import org.aswing.JCheckBox;


/**
 * ...
 * @author GM
 */
class JCheckBox1 extends JCheckBox
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
		setHorizontalAlignment(AbstractButton.LEFT);

		if (func != null)
			addEventListener(AWEvent.ACT, func);
	}
}