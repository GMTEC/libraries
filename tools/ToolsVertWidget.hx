package tools ;


/**
 * ...
 * @author GM
 */

class ToolsVertWidget extends WTools
{
	/**
	 * 
	 * @param	name
	 */
	public function new(name:String, w:Int = 32, h:Int = 32) 
	{
		super(name, w, h);

		dY = H - 4;
		dX = 0;
	}

	/**
	 * 
	 * @param	e
	 */
	public override function oninitButtons():Void 
	{
		super.initButtons(dX, dY);
	}
}