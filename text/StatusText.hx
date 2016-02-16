package text;

import flash.display.Sprite;
import org.aswing.ASColor;
import org.aswing.JLabel;
import statemachine.StateMachine.StateColor;
import widgets.WIndicator;

/**
 * ...
 * @author GM
 */
class StatusText extends Sprite
{
	public var txtTitle	:JLabel;
	public var txtUnit	:JLabel;
	var butIndicator	:WIndicator;

	public var W:Int;
	public var H:Int;
	var fontSize:Int;

	/**
	 * 
	 * @param	title
	 * @param	unit
	 */
	public function new(title:String = "", unit:String = "", wIn:Int, hIn:Int, fontSizeIn:Int) 
	{
		super();

		butIndicator = new WIndicator("ID_STATE_TEXT", "", StateColor.backColorInOUT, ASColor.CLOUDS, wIn, hIn, fontSizeIn);
		addChild(butIndicator);
		butIndicator.setEnabled(true);

		fontSize = fontSizeIn;

		if (title.length > 0)
			txtUnit = new JLabel(unit);

		if (title.length > 0)
		{
			txtTitle = new JLabel();
			addChild(txtTitle);
			txtTitle.setText(title);
		}
		
		init();
	}

	/**
	 * 
	 */
	public function init()
	{
		if (txtUnit != null)
		{
			txtUnit.setComBoundsXYWH(cast x + W - 22, cast x + 34, 32, 26);
			addChild(txtUnit);
		}
	}

	/**
	 * 
	 * @param	strIn
	 * @param	sizeIn
	 */
	public function setText(textIn:String):Void
	{
		if (textIn.length == 3)
			textIn = " " + textIn;

		butIndicator.setText(textIn);
	}

	/**
	 * 
	 * @param	col
	 */
	public function setTextolor(col:ASColor) 
	{
		butIndicator.setTextColor(col);
	}

	public function setBackgroundColor(col:ASColor) 
	{
		butIndicator.setBackgroundColor(col);
	}
}