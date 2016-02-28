package widgets;

import comp.JButtonFramed;
import db.DBTranslations;
import events.PanelEvents;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import org.aswing.ASColor;
import org.aswing.AsWingConstants;
import org.aswing.AWKeyboard;
import org.aswing.JLabel;
import tweenx909.TweenX;
import util.BitmapUtils.BitmapSmoothed;
import util.Filters;

/**
 * ...
 * @author GM
 */
@:bitmap("assets/img/WinTop1.png") class WinTop extends flash.display.BitmapData{}

class WDialog extends WBase
{
	var OK_STR:String;
	var CANCEL_STR:String;
	var YES_STR:String;
	var NO_STR:String;
	var CLOSE_STR:String;

	//var butCancel		:ToolsVertWidget;
	var butLeft			:JButtonFramed;
	var butCenter		:JButtonFramed;
	var butRight		:JButtonFramed;
	var labelMessage	:JLabel;
	var onRightButPnt	:Void->Void;
	var onCenterButPnt	:Void->Void;
	var onCancelBut		:Void->Void;
	var onLeftBut		:Void->Void;
	var onOkOnError		:Void->Void;
	var compToFade		:DisplayObject;
	var compAddded		:DisplayObject;
	var oldVisible		:Bool;
	var bAutoFade		:Bool;
	var backImage		:BitmapSmoothed;
	static private inline var EASE:Float = 0.01;

	/**
	 * 
	 * @param	name
	 */
	public function new(compToFadeIn:Sprite, parent:Sprite) 
	{
		super("PopupDialog");
		
		W = 300; H = 220;

		//backImage = new BitmapSmoothed(new WinTop(0, 0));
		//Images.resize(backImage, W, H);
		//sp.addChild(backImage);
		var sp:Sprite 		= new Sprite();
		var gfx:Graphics 	= sp.graphics;
		gfx.beginFill(ASColor.CLOUDS.getRGB());
		gfx.drawRect(0, 0, W, H);
		sp.filters = Filters.centerWinFilters;

		Main.widgetBig.addChild(this);
		//bringToFront()
		//parent.addChild(this);

		sp.x += 14;
		sp.y += 14;
		addChild(sp);

		compToFade = compToFadeIn;

		alpha = 0;
		x += 200;
		y += 140;

		labelMessage 			= new JLabel("Test");
		//labelMessage.setForeground(ASColor.DARK_GRAY);
		labelMessage.setTextFilters(Filters.filterWhiteShadow);

		labelMessage.setHorizontalTextPosition(AsWingConstants.CENTER);
		labelMessage.setComBoundsXYWH(0, 80, cast this.width, 48);

		//butCancel 			= new ToolsVertWidget("ID_WDIALOG", 28, 28);
		//butCancel.push("", null, null, " ",  "IDS_TT",	onButCancel, false);

		//butCancel.x = W - 4;
		//butCancel.y = 16;

		butLeft 	= new JButtonFramed("ID_BUT_DIALOG_OK", 	60, H - 32, 100, 32, "IDS_NO", 	null, onButLeft);
		butCenter	= new JButtonFramed("ID_BUT_DIALOG_CENTER", 120, H - 32, 100, 32, "IDS_BUT_OK", null, onButCenter);
		butRight	= new JButtonFramed("ID_BUT_DIALOG_QUIT", 	180, H - 32, 100, 32, "IDS_YES", 	null, onButRight);

		butLeft.setBackground(ASColor.ALIZARIN);
		butCenter.setBackground(ASColor.EMERALD);
		butRight.setBackground(ASColor.EMERALD);

		//addChild(butCancel);
		addChild(butLeft);
		addChild(butCenter);
		addChild(butRight);
		addChild(labelMessage);
	
		onRightButPnt 	= onClose;
		onLeftBut 		= onClose;
		onCenterButPnt 	= onClose;
		onCancelBut 	= onClose;

		visible = false;
		Main.root1.addEventListener(PanelEvents.EVT_LANGUAGE_CHANGE, onLanguageChange);
		onLanguageChange();
	}
	/**
	 * 
	 * @param	e
	 */
	private function onLanguageChange(e:Event = null):Void 
	{
		OK_STR		=  DBTranslations.getText("IDS_BUT_OK");
		CANCEL_STR	=  DBTranslations.getText("IDS_BUT_CANCEL");
		YES_STR		=  DBTranslations.getText("IDS_YES");
		NO_STR		=  DBTranslations.getText("IDS_NO");
		CLOSE_STR	=  DBTranslations.getText("IDS_BUT_QUIT");
	}

	/**
	 * 
	 * @param	e
	 */
	function onButCenter(e:Event = null) 
	{
		if (bAutoFade) setVisible(false);
		if(cast onCenterButPnt) onCenterButPnt();
		if(cast onRightButPnt) onRightButPnt();
	}

	/**
	 * 
	 * @param	e
	 */
	function onButRight(e:Event = null) 
	{
		if (bAutoFade) setVisible(false);
		if(cast onRightButPnt) onRightButPnt();
	}

	/**
	 * 
	 * @param	e
	 */
	function onButLeft(e:Event = null) 
	{
		if (bAutoFade) setVisible(false);
		if(cast onLeftBut) onLeftBut();
	}

	///**
	 //* 
	 //* @param	e
	 //*/
	//function onButCancel(e:Event = null) 
	//{
		//if (bAutoFade) setVisible(false);
		//if(cast onCancelBut) onCancelBut();
	//}

	/**
	 * 
	 * @param	onLeft
	 * @param	onRight
	 * @param	message
	 */
	public function setYesNoDialog(onLeft:Void->Void, onRight:Void->Void, message:String = " ", no:String, yes:String)
	{
		labelMessage.setText(DBTranslations.getText(message));
		labelMessage.foreground = ASColor.WET_ASPHALT;
		onCancelBut 		= onLeft;
		onLeftBut 			= onLeft;
		onRightButPnt 		= onRight;
		butLeft.setText(no);
		butRight.setText(yes);
		butLeft.visible 	= true;
		butCenter.visible 	= false;
		butRight.visible 	= true;
		if (bAutoFade) setVisible(true);
		bringToFront();
	}

	/**
	 * 
	 * @param	onLeft
	 * @param	onRight
	 * @param	message
	 */
	public function setOKDialog(onCenter:Void->Void, message:String = " ")
	{
		labelMessage.setText(DBTranslations.getText(message));
		labelMessage.foreground = ASColor.WET_ASPHALT;
		onCancelBut 		= onCenter;
		onCenterButPnt 		= onCenter;
		if (bAutoFade) setVisible(true);
		butLeft.visible 	= false;
		butCenter.visible 	= true;
		butRight.visible 	= false;
		butCenter.makeFocus();
		addEventListener(KeyboardEvent.KEY_DOWN, onKeybEvent);
		butCenter.repaint(); // Necessary
	}

	/**
	 * 
	 * @param	key
	 */
	private function onKeybEvent(key:KeyboardEvent):Void 
	{
		if (key.charCode == (cast AWKeyboard.NUMPAD_ENTER) || key.charCode == (cast AWKeyboard.ENTER))
		{
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeybEvent);
			onButCenter();
		}
	}

	/**
	 * 
	 * @param	onCenter
	 * @param	message
	 */
	public function setOKCancelDialog(onLeftIn:Void->Void = null, onRightIn:Void->Void = null, message:String = " ", ?autoFade:Bool = true) 
	{
		bAutoFade = autoFade;
		labelMessage.setText(DBTranslations.getText(message));
		if(cast onLeftIn) onLeftBut 		= onLeftIn;
		if(cast onRightIn) onRightButPnt 	= onRightIn;
		butLeft.visible 	= true;
		butCenter.visible 	= false;
		butRight.visible 	= true;
		butLeft.setText(CANCEL_STR);
		butRight.setText(OK_STR);
		addEventListener(KeyboardEvent.KEY_DOWN, onKeybEvent);

		if (autoFade)
			setVisible(true);
	}

	/**
	 * 
	 * @param	onCenter
	 * @param	message
	 */
	public function setEmptyDialog(comp:DisplayObject) 
	{
		compAddded			= comp;
		butLeft.visible 	= false;
		butCenter.visible 	= false;
		butRight.visible 	= false;

		addChild(comp);
		if (bAutoFade) setVisible(true);
	}

	/**
	 * 
	 */
	function onClose():Void 
	{
		setVisible(false);
	}

	/**
	 * 
	 */
	public override function setVisible(v:Bool):Void
	{
		if (v != oldVisible)
		{
			v ? TweenX.tweenFunc(fadeNewWin, [1], [0.4], EASE, EASE, DefaultParameters.tweenTime) : TweenX.tweenFunc(fadeNewWin, [0.4], [1], EASE, EASE, DefaultParameters.tweenTime);

			oldVisible = v;

			if ( compAddded != null && !v)
			{
				removeChild(compAddded);
				compAddded = null;
			}
			super.setVisible(v);
		}
	}

	/**
	 * 
	 */
	function fadeNewWin(alpha:Float) 
	{
		compToFade.alpha = alpha;
	}
}