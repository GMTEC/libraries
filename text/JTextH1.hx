package text;

import text.JTextHBase;
//import db.TableCSS;

/**
 * ...
 * @author GM
 */
class JTextH1 extends JTextHBase
{

	public function new(textIn:String="", columns:Int=0) 
	{
		super();

		setHtmlTextAndSize(textIn, 10);
	}
}