package comp;

import comp.JTextTitleArea;
import flash.display.Bitmap;
import flash.events.KeyboardEvent;
import org.aswing.ASColor;
import org.aswing.AWKeyboard;
import org.aswing.Component;
import org.aswing.JTextArea;

/**
 * ...
 * @author GM
 */
class JTextTitleArea extends TitledContainer
{
	var prev:Component;
	var next:Component;
	var func:Dynamic->Void;
	var modified:Bool;
	public var textArea:JTextArea;

	public function new(titleID:String = "", bmIn:Bitmap = null, func:Dynamic->Void = null) 
	{
		super(titleID, bmIn);

		this.func = func;

		textArea = new JTextArea();
		addChild(textArea);

		if (cast func) {
			textArea.addEventListener(KeyboardEvent.KEY_DOWN, taListener);
		}

		textArea.setBackground(ASColor.PETER_RIVER);
		textArea.setForeground(ASColor.CLOUDS);
		textArea.setRestrict("-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_ ");
		textArea.setWordWrap(true);
		textArea.setRows(1);
	}

	public override function makeFocus():Void {
		textArea.makeFocus();
		func(null);
	}

	/**
	 * 
	 * @param	xIn
	 * @param	yIn
	 * @param	wIn
	 * @param	hIn
	 * @param	align
	 */
	public override function setComBoundsXYWHTopAlign(xIn:Int, yIn:Int, wIn:Int = 80, hIn:Int = 34):Void
	{
		super.setComBoundsXYWHTopAlign(xIn, yIn, wIn, hIn);
		textArea.setComBoundsXYWH(xIn, yIn, wIn, hIn);
	}

	/**
	 * 
	 * @param	key
	 */
	function taListener(key:KeyboardEvent) :Void
	{
		if (cast next)
		{
			if (key.charCode == cast AWKeyboard.TAB) next.makeFocus();
			if (key.charCode == cast AWKeyboard.ENTER) { key.preventDefault(); next.makeFocus(); }
		}
	}
	
	/**
	 * 
	 * @param	prev
	 * @param	next
	 */
	public function setPreviousNextControl(prev:Component, next:Component) 
	{
		this.next = next;
		this.prev = prev;
	}
}