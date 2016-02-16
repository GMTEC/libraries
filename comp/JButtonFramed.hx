package comp;

import comp.JButton2;
import flash.events.MouseEvent;
import icon.MenuIcon;
import org.aswing.ASColor;
import widgets.SpriteMenuButton;

/**
 * ...
 * @author GM
 */
class JButtonFramed extends JButton2
{
	var backGround : ASColor;

	public function new(name:String, xIn:Int, yIn:Int, wIn:Int, hIn:Int, text:String = "", spriteIn:SpriteMenuButton = null, funcPress: Dynamic -> Void = null, funcRelease: Dynamic -> Void = null) 
	{
		super(xIn, yIn, wIn, hIn, text, new MenuIcon(spriteIn), funcPress);

		setBackground(ASColor.ALIZARIN);

		if (funcPress != null)
			addEventListener(MouseEvent.CLICK, funcPress);
	
		if (funcRelease != null)
		{
			addEventListener(MouseEvent.MOUSE_OUT, funcRelease);
			addEventListener(MouseEvent.MOUSE_UP, funcRelease);
		}
	}

	/**
	 * 
	 * @param	scaleIn
	 */
	public function scale(scaleIn:Float):Void 
	{
		scaleX = scaleY = scaleIn;
	}

	/**
	 * 
	 * @param	sel
	 */
	public override function setSelected(sel:Bool) 
	{
		super.setSelected(sel);
		setBackground(sel ? ASColor.EMERALD : backGround);
	}
}