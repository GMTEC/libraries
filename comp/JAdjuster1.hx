package comp;

import flash.display.Bitmap;
import org.aswing.ASColor;
import org.aswing.BoundedRangeModel;
import org.aswing.DefaultBoundedRangeModel;
import org.aswing.geom.IntRectangle;
import org.aswing.JAdjuster;

/**
 * ...
 * @author GM
 */
class JAdjuster1 extends TitledContainer
{
	public var adjuster	:JAdjuster;

	public function new(label:String, bmIn:Bitmap = null) 
	{
		super(label, bmIn);

		adjuster = new JAdjuster(1);

		//adjuster.setModel(new BoundedRangeModel());
		adjuster.setComBounds(new IntRectangle(0, 20, 100, 18));
		adjuster.setForeground(ASColor.CLOUDS);
		adjuster.scaleX = adjuster.scaleY = 1.4;
		addChild(adjuster);
	}

	public function getValue():Int
	{
		return adjuster.getValue();
	}

	/**
	 * 
	 * @param	xIn
	 * @param	yIn
	 * @param	wIn
	 * @param	hIn
	 * @param	align
	 */
	public override function setComBoundsXYWHTopAlign(xIn:Int, yIn:Int, wIn:Int = 80, hIn:Int = 24):Void
	{
		super.setComBoundsXYWHTopAlign(xIn, yIn, wIn, hIn);
		adjuster.setComBoundsXYWH(xIn, yIn, wIn, 24);
	}
}