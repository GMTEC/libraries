package text;

import text.JTextHBase;

/**
 * ...
 * @author GM
 */
class JTextH2 extends JTextHBase
{

	public function new(textIn:String="", columns:Int=0) 
	{
		super();

		setHtmlTextAndSize(textIn, 14);
	}
}