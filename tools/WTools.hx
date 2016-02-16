package tools ;

import comp.JButtonFramed;
import db.DBTranslations;
import flash.display.Bitmap;
import icon.MenuIcon;
import org.aswing.AbstractButton;
import org.aswing.AsWingConstants;
import org.aswing.JToolBar;
import widgets.SpriteMenuButton;
import widgets.WBase;

/**
 * ...
 * @author GM
 */
class ToolButton extends JButtonFramed
{
	//var selected:Bool;
	public var id					:String;
	public var label				:String;
	public var toolTip				:String;
	public var spriteMenuButton		:SpriteMenuButton;

	/**
	 * 
	 * @param	idBut
	 * @param	bmEnabled
	 * @param	bmSel
	 * @param	bmSize
	 * @param	label
	 * @param	toolTip
	 * @param	funcPress
	 * @param	funcRelease
	 * @param	selected
	 */
	public function new(?idBut:String = "", x:Int, y:Int, w:Int, h:Int, bmEn:Bitmap, bmDis:Bitmap, ?bmSize:Int, label:String, toolTip:String, ?funcPress:Dynamic->Void,  ?funcRelease:Dynamic->Void, selected:Bool = false):Void 
	{
		super(idBut, x, y, 34, 34, funcPress, funcRelease);

		this.id				= idBut;
		spriteMenuButton	= new SpriteMenuButton(bmEn, bmDis);

		addChild(spriteMenuButton);
		spriteMenuButton.x -= 4;
		this.label			= DBTranslations.getText(label);
		this.toolTip		= DBTranslations.getText(toolTip);
		this.selected		= selected;
	}
}

/**
 * 
 */
class WTools extends WBase
{
	var toolArray			:Array<ToolButton>;
	var dY					:Int = 0;
	var dX					:Int = 0;
	var X					:Int = 0;
	var Y					:Int = 0;
	var toolBar				:JToolBar;

	/**
	 * 
	 * @param	name
	 */
	public function new(name:String, w:Int, h:Int) 
	{
		super(name);

		toolArray = new Array<ToolButton>();
		toolBar = new JToolBar(AsWingConstants.HORIZONTAL, 18);
		addChild(toolBar);

		super(name);

		this.W = w;
		this.H = h;
	}

	/**
	 * 
	 * @param	bmEn
	 * @param	bmDis
	 * @param	dX
	 * @param	lael
	 * @param	tooltip
	 * @param	func
	 * @param	selected
	 */
	public function push(?butName:String = "", bmEn:Bitmap, bmDis:Bitmap, label:String, tooltip:String, func:Dynamic->Void, selected:Bool = false) : ToolButton
	{
		var but:ToolButton = new ToolButton(butName, X, Y, 0, 0, bmEn, bmDis, H, label, tooltip, func, selected);
		X += dX;
		Y += dY;
		toolBar.append(but);
		toolArray.push(but);

		return but;
		//if(selected) setSelected(but.button);
	}

	/**
	 * 
	 * @param	enable
	 */
	function enableButtons(enabled:Bool = true)
	{
		//for (but in toolArray) {
			//but.button.setEnabled(enabled);
		//}
	}

	/**
	 * 
	 */
	function oninitButtons() 
	{
	}

	/**
	 * 
	 * @param	string
	 */
	public function setSelected(comp:AbstractButton = null) 
	{
		for (but in toolArray) // deselect all buttons
		{
			if(cast but) {
				but.setSelected(false);
				//but.x = 0;
			}
		}

		if (cast comp) {
			comp.setSelected(true);
			//comp.x -= 20;
		}
	}

	/**
	 * 
	 * @param	string
	 */
	public function getButton(idIn:String):JButtonFramed
	{
		for (but in toolArray)
		{
			if (but.id  == idIn)
				return but;
		}

		return null;
	}

	/**
	 * 
	 * @param	string
	 */
	public function invertSelection(name:String) : Bool
	{
		var selected:Bool = getButton(name).isSelected();
		getButton(name).setSelected(!selected);
		
		return !selected;
	}

	/**
	 * 
	 * @param	index
	 */
	public function setIconSprite(index:Int, selected:Bool) 
	{
		//var tool:ToolButton = toolArray[index];
		//tool.setIcon(new MenuIcon(selected ? tool.spriteMenuButton.spriteDisabled : tool.spriteMenuButton.spriteEnabled));
	}

	/**
	 * 
	 * @param	e
	 */
	public function initButtons(dXIn:Int, dYIn:Int):Void 
	{
		setSelected();
	}
}