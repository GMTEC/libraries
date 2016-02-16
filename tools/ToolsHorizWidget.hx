package tools ;

/**
 * ...
 * @author GM
 */

/**
 * 
 */
class ToolsHorizWidget extends WTools
{
	/**
	 * 
	 * @param	name
	 */
	public function new(name:String, w:Int, h:Int) 
	{
		super(name, w, h);

		dX = 32;
		dY = 0;
	}

	/**
	 * 
	 * @param	e
	 */
	private override function oninitButtons():Void 
	{
		dX = W + cast(W / 5);
		dY = 0;

		super.initButtons(dX, dY);
	}
}