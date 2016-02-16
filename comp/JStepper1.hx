package comp;

import flash.display.Bitmap;
import org.aswing.geom.IntRectangle;
import org.aswing.JStepper;

/**
 * ...
 * @author GM
 */
class JStepper1 extends TitledContainer
{
	public var stepper	:JStepper;

	public function new(label:String, bmIn:Bitmap = null) 
	{
		super(label, bmIn);

		stepper = new JStepper(1);
		stepper.setComBounds(new IntRectangle(0, 20, 100, 24));
		addChild(stepper);
	}

	public function getValue():Int
	{
		return stepper.getValue();
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
		super.setComBoundsXYWHTopAlign(xIn, yIn, wIn, hIn);
		stepper.setComBoundsXYWH(xIn, yIn, wIn, hIn);
	}
}