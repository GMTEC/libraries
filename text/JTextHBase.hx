package text;

import db.DBDefaults;
import db.DBTranslations;
import org.aswing.JTextField;

/**
 * ...
 * @author GM
 */

class JTextHBase extends JTextField
{
	public function new(?str:String) 
	{
		super(str);

		setEditable(false);
		setBorder(null);
		setOpaque(false);
		setEnabled(false);
	}

	public function setTextolor(colIn:Int)
	{
		this.textField.textColor = colIn;
	}
	/**
	 * 
	 * @param	strIn
	 * @param	sizeIn
	 */
	public function setHtmlTextAndSize(textIn:String, sizeIn:Int = 12, centerIn:String = "left"):Void
	{
		setHtmlText( "<html><p align=\"" + centerIn + "\"><font face=\"" + DBDefaults.textFont + "\"><font size=\"" + sizeIn + "\"><b>" + DBTranslations.getText(textIn) + "</b> </font </html>");
	}

	/**
	 * 
	 * @param	xin
	 * @param	yIn
	 * @param	wIn
	 * @param	hIn
	 * @param	scalein
	 */
	public function setPosition(xIn:Int, yIn:Int, wIn:Int, hIn:Int, scaleIn:Float = 1)
	{
		var test:Dynamic;

		setLocationXY(xIn, yIn);
		setSizeWH(wIn, hIn);
		scaleX = scaleIn;
		scaleY = scaleIn;
	}
}