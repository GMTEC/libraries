package text;

import db.DBTranslations;
import org.aswing.ASColor;
import org.aswing.ASFont;
import org.aswing.Component;
import org.aswing.JLabel;
import org.aswing.UIManager;

/**
 * ...
 * @author GM
 */

class LabelValues extends Component
{
	var leftLabel:JLabel;
	var rightLabel:JLabel;
	var strRight:String;
	var strLeft:String;

	public function new(strLeftIn:String, strRightIn:String, sizeIn:Int = 16, dwIn:Int = 100, colIn:Int = 0, alphaIn:Float = 1) 
	{
		//trace("LabelThreshold");
		super();

		strLeft					= DBTranslations.getText(strLeftIn);
		strRight				= " " + DBTranslations.getText(strRightIn);
		var font:ASFont			= UIManager.getFont("systemFont");

		leftLabel	=  new JLabel();
		rightLabel	=  new JLabel();
		
		leftLabel.setText(strLeft);
		rightLabel.setText(strRight);

		if (!cast colIn)
			colIn = ASColor.CLOUDS.getRGB();

		leftLabel.setForeground(new ASColor(colIn, alphaIn));
		rightLabel.setForeground(leftLabel.getForeground());

		leftLabel.setComBoundsXYWH(0, 0, 80, 16);
		rightLabel.setComBoundsXYWH(dwIn, 0, 80, 16);
		leftLabel.setPreferredWidth(80);
		rightLabel.setPreferredWidth(80);
	
		leftLabel.setHorizontalAlignment(0);
		rightLabel.setHorizontalAlignment(1);
		leftLabel.setHorizontalTextPosition(0);
		rightLabel.setHorizontalTextPosition(1);
		
		leftLabel.setAlignmentX(0);
		rightLabel.setAlignmentX(1);

		addChild(leftLabel);
		addChild(rightLabel);
	}

	/**
	 * 
	 * @param	value
	 * @param	colIn
	 */
	public function setValue(value:String, ?colIn:Int):Void
	{
		rightLabel.textSnapshot.setSelectColor(colIn == null ? ASColor.MIDNIGHT_BLUE.getRGB() : colIn);
		rightLabel.setText(value + strRight);
	}
}