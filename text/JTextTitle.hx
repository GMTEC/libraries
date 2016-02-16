package text;

import db.DBDefaults;
import org.aswing.JTextField;

/**
 * ...
 * @author GM
 */

class JTextTitle extends JTextField
{
	var X: Int;
	var Y: Int;
	var W: Int;

	public function new() 
	{
		super();

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
	public function setHtmlTextAndSize(textIn:String, sizeIn:Int = 16, centerIn:String = "center"):Void
	{
		//setHtmlText( "<html><p align=\"" + centerIn + "\"><font face=\"" + DBDefaults.prisonerFont + "\"><font size=\"" + sizeIn + "\"><b>" + textIn + "</b> </font </html>");
		setHtmlText( "<html><p align=\"" + centerIn + "\"><font face=\"" + DBDefaults.prisonerFont + "\"><font size=\"" + sizeIn + "\">" + textIn + " </font </html>");
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
		getAlignmentX();
		X = xIn;
		Y = yIn;
		W = wIn;
		setLocationXY(xIn, yIn);
		setSizeWH(wIn, hIn);
		scaleX = scaleIn;
		scaleY = scaleIn;
	}
}