package comp;

import flash.display.DisplayObject;
import org.aswing.JTextArea;

/**
 * ...
 * @author GM
 */
class LogConsole extends JTextArea
{

	public function new() 
	{
		super();
	}
	
	public function log(str:String)
	{
		appendText(str + '\n');
		//pack();
	}
	
}