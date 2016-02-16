package comp;

import flash.display.Bitmap;
import org.aswing.JComboBox;

/**
 * ...
 * @author GM
 */
class JComboBox1 extends TitledContainer
{
	public var combobox:JComboBox;

	public function new(label:String, bmIn:Bitmap = null) 
	{
		super(label, bmIn);

		combobox = new JComboBox();
		addChild(combobox);
	}

	/**
	 * 
	 * @param	xIn
	 * @param	yIn
	 * @param	wIn
	 * @param	hIn
	 * @param	align
	 */
	public override function setComBoundsXYWHTopAlign(xIn:Int, yIn:Int, wIn:Int = 80, hIn:Int = 34):Void
	{
		if (wIn == 0)
			wIn = 200;
		super.setComBoundsXYWHTopAlign(xIn, yIn, wIn, hIn);
		combobox.setComBoundsXYWH(xIn, yIn, wIn, hIn);

	}
}