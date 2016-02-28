package util;

import events.PanelEvents;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.filesystem.File;
import flash.net.URLRequest;
import openfl.display.BitmapData;
import util.BitmapUtils.BitmapGlyph;
import util.BitmapUtils.BitmapSmoothed;

/**
 * ...
 * @author GM
 */
@:bitmap("assets/img/menu.png")				class BmMenu extends BMData{}
@:bitmap("assets/img/floor_diffuse.jpg")	class BmFloor_Diffuse extends BMData{}
@:bitmap("assets/img/floor_specular.jpg")	class BmFloor_Specular extends BMData{}
@:bitmap("assets/img/floor_normal.jpg")		class BmFloor_Normal extends BMData{}
@:bitmap("assets/img/Scale.png")			class BmScale extends BMData{}
@:bitmap("assets/img/CheckBoxOn.png")		class BmCheckBoxOn extends BMData{}
@:bitmap("assets/img/CheckBoxOff.png")		class BmCheckBoxOff extends BMData{}
@:bitmap("assets/img/PhotoCamera.png")		class BmPhotoCamera extends BMData{}
@:bitmap("assets/img/Vibration.png")		class BmMotion extends BMData{}
@:bitmap("assets/img/Serial.png")			class BmSerial extends BMData{}
@:bitmap("assets/img/Levels.png")			class BmLevels extends BMData{}
@:bitmap("assets/img/Cancel.png")			class BmCancel extends BMData{}
@:bitmap("assets/img/TruckBlueIcon.png")	class BmTruckBlueIcon extends BMData{}
@:bitmap("assets/img/TruckYellowIcon.png")	class BmTruckYellowIcon extends BMData{}
@:bitmap("assets/img/Clock.png")			class BmLoadClock extends BMData{}
@:bitmap("assets/img/ButFirst.png")			class BmLoadFirst extends BMData{}
@:bitmap("assets/img/ButLast.png")			class BmLoadLast extends BMData{}
@:bitmap("assets/img/ButPrevious.png")		class BmLoadPrevious extends BMData{}
@:bitmap("assets/img/ButNext.png")			class BmLoadNext extends BMData{}

@:bitmap("assets/img/logScale.png")			class BmLogScale extends BMData{}
@:bitmap("assets/img/LinScale.png")			class BmLinScale extends BMData{}
@:bitmap("assets/img/SQLFilterOn.png")		class BmSQLFilterOn extends BMData{}
@:bitmap("assets/img/SQLFilterOff.png")		class BmSQLFilterOff extends BMData{}
@:bitmap("assets/img/SQLDate.png")			class BmSQLDate extends BMData{}
@:bitmap("assets/img/SQLDateFrom.png")		class BmSQLDateFrom extends BMData{}
@:bitmap("assets/img/SQLDateTo.png")		class BmSQLDateTo extends BMData{}
@:bitmap("assets/img/Reset.png")			class BmReset extends BMData{}
@:bitmap("assets/img/zoomplus.png")			class BmZoomPlus extends BMData{}
@:bitmap("assets/img/zoomminus.png")		class BmZoomMinus extends BMData{}
@:bitmap("assets/img/Deviation.png")		class BmDeviation extends BMData{}
@:bitmap("assets/img/Debug.png")			class BmDebug extends BMData{}
@:bitmap("assets/img/Average.png")			class BmAverage extends BMData{}
@:bitmap("assets/img/Chrono.png")			class BmChrono extends BMData{}
@:bitmap("assets/img/Encoder.png")			class BmEncoder extends BMData{}
@:bitmap("assets/img/Channel.png")			class BmChannel extends BMData{}
@:bitmap("assets/img/ReportFR.png")			class BmReportBitmapFR extends BMData{}
@:bitmap("assets/img/Wait.png")				class BmWait extends BMData{}
@:bitmap("assets/img/LogoMXT.png")			class BmLogoMXT extends BMData{}
@:bitmap("assets/img/Forbidden.png")		class BmForbidden extends BMData{}
@:bitmap("assets/img/Exclamation.png")		class BmExclamation extends BMData{}
@:bitmap("assets/img/Nuclear.png")			class BmNuclear extends BMData{}
@:bitmap("assets/img/Nuclear45.png")		class BmNuclear45 extends BMData{}
@:bitmap("assets/img/TruckWatermark.png")	class BmTruckWatermark extends BMData{}
@:bitmap("assets/img/TruckRA.png")			class BmNuclearBusy extends BMData{}
@:bitmap("assets/img/Go.png")				class BmGo extends BMData{}
@:bitmap("assets/img/View.png")				class BmView extends BMData{}
@:bitmap("assets/img/LED RA On1.png")		class BmLedRaOn extends BMData{}
@:bitmap("assets/img/LED RA On1Sel.png")	class BmLedRaOnSel extends BMData{}
@:bitmap("assets/img/LED RA Off1.png")		class BmLedRaOff extends BMData{}
@:bitmap("assets/img/LED RA Off1Sel.png")	class BmLedRaOffSel extends BMData{}
@:bitmap("assets/img/LEDNonOK.png")			class BmLedRepNonOK extends BMData{}
@:bitmap("assets/img/LEDNonOKSel.png")		class BmLedRepNonOKSel extends BMData{}
@:bitmap("assets/img/LED Off USB.png")		class BmLedSteel extends BMData{}
@:bitmap("assets/img/LED Green USB.png")	class BmLedGreenSteel extends BMData{}
@:bitmap("assets/img/Stop.png")				class BmStop extends BMData{}
@:bitmap("assets/img/InitBusy.png")			class BmInitBusy extends BMData{}
@:bitmap("assets/img/TruckGreen.png")		class BmTruckGreen extends BMData{}
@:bitmap("assets/img/TruckBlue.png")		class BmTruckBlue extends BMData{}
@:bitmap("assets/img/TruckWhite.png")		class BmTruckWhite extends BMData{}
@:bitmap("assets/img/TruckRed.png")			class BmTruckRed extends BMData{}
@:bitmap("assets/img/TruckYellow.png")		class BmTruckYellow extends BMData{}
@:bitmap("assets/img/Portal.png")			class BmPortal extends BMData { }

@:bitmap("assets/img/Monitor.png")			class BmMonitor extends BMData { }
@:bitmap("assets/img/Measures.png")			class BmMeasures extends BMData { }
@:bitmap("assets/img/ReportBut.png")		class BmReport extends BMData { }
@:bitmap("assets/img/Printer.png")			class BmPrinter extends BMData { }
@:bitmap("assets/img/Keyboard.png")			class BmKeyboard extends BMData { }
@:bitmap("assets/img/Microphone.png")		class BmMicrophone extends BMData { }
@:bitmap("assets/img/History.png")			class BmHistory extends BMData { }
@:bitmap("assets/img/LogBook.png")			class BmLogBook extends BMData { }
@:bitmap("assets/img/Statistics.png")		class BmStatistics extends BMData { }
@:bitmap("assets/img/Contact.png")			class BmContacts extends BMData { }
@:bitmap("assets/img/DataBase.png")			class BmDataBase extends BMData { }
@:bitmap("assets/img/Settings.png")			class BmSettings extends BMData { }
@:bitmap("assets/img/User.png")				class BmUser extends BMData { }
@:bitmap("assets/img/Users.png")			class BmUsers extends BMData { }
@:bitmap("assets/img/Mute.png")				class BmMute extends BMData { }
@:bitmap("assets/img/Loudspeaker.png")		class BmLS extends BMData { }
@:bitmap("assets/img/Nuclear Ack.png")		class BmAck extends BMData { }
@:bitmap("assets/img/Nuclear Ack_dis.png")	class BmAckDis extends BMData { }
@:bitmap("assets/img/Test.png")				class BmTest extends BMData { }
@:bitmap("assets/img/Exit.png")				class BmExit extends BMData { }

@:bitmap("assets/img/FeuVert.png")			class BmSignalGreen extends BMData { }
@:bitmap("assets/img/FeuOrange.png")		class BmSignalOrange extends BMData { }
@:bitmap("assets/img/FeuNeutre.png")		class BmSignalNeutre extends BMData { }
@:bitmap("assets/img/FeuRouge.png")			class BmSignalRed extends BMData { }
@:bitmap("assets/img/BKGBusy.png")			class BmBKGBusy extends BMData { }
@:bitmap("assets/img/ButPortal.png")		class BmButPortal extends BMData { }
@:bitmap("assets/img/Camera.png")			class BmCamera extends BMData { }
@:bitmap("assets/img/Maximize.png")			class BmMaximize extends BMData { }

class BMData extends BitmapData
{

	public function new(transparent:Bool=true, fillColor:UInt=0xFFFFFFFF) 
	{
		super(0, 0, transparent, fillColor);
	}
	
}
class Images
{
	private var imgloader				:Loader; 
	static public var BmCustomerLogo	:Bitmap; 

	/**
	 * 
	 */
	public function new() 
	{
		imgloader 				= new Loader();
		var file = File.applicationDirectory.resolvePath("img/Customer.png");

		if (file.exists)
		{
			imgloader.contentLoaderInfo.addEventListener(Event.COMPLETE, imgloader_completed);
			imgloader.load(new URLRequest(file.nativePath));
			BmCustomerLogo  		= untyped imgloader.content;
		}
	}

	/**
	 * 
	 * @param	evt
	 */
	function imgloader_completed(evt:Event):Void
	{
		var bmp:Bitmap = cast imgloader.content;
		BmCustomerLogo = new Bitmap(bmp.bitmapData);

		Main.root1.dispatchEvent(new Event(PanelEvents.EVT_IMAGES_LOADED));
	}

	/**
	 * 
	 * @return
	 */
	static public function loadMenu() :				Bitmap{return new BitmapGlyph(new BmMenu());}
	public static function loadFloor_Diffuse():		Bitmap{return new BitmapSmoothed(new BmFloor_Diffuse());}
	public static function loadfloor_specular():	Bitmap{return new BitmapSmoothed(new BmFloor_Specular());}
	public static function loadfloor_normal():		Bitmap{return new BitmapSmoothed(new BmFloor_Normal());}

	public static function loadScale():				Bitmap{return new BitmapSmoothed(new BmScale());}
	public static function loadCheckBoxOn():		Bitmap{return new BitmapSmoothed(new BmCheckBoxOn());}
	public static function loadCheckBoxOff():		Bitmap{return new BitmapSmoothed(new BmCheckBoxOff());}
	public static function loadPhotoCamera(?i:Bool):Bitmap{return new BitmapGlyph(new BmPhotoCamera(), i);}
	public static function loadMotion():			Bitmap{return new BitmapGlyph(new BmMotion());}
	public static function loadSerial(?i:Bool):		Bitmap{return new BitmapSmoothed(new BmSerial(), i);}
	public static function loadLevels(?i:Bool):		Bitmap{return new BitmapGlyph(new BmLevels(), i);}
	public static function loadCancel():			Bitmap{return new BitmapSmoothed(new BmCancel());}
	public static function loadtruckYellowIcon():	Bitmap{return new BitmapSmoothed(new BmTruckYellowIcon());}
	public static function loadtruckBlueIcon():		Bitmap{return new BitmapSmoothed(new BmTruckBlueIcon());}
	public static function loadClock():				Bitmap{return new BitmapSmoothed(new BmLoadClock());}
	public static function loadButFirst():			Bitmap{return new BitmapSmoothed(new BmLoadFirst());}
	public static function loadButLast():			Bitmap{return new BitmapSmoothed(new BmLoadLast());}
	public static function loadButNext():			Bitmap{return new BitmapSmoothed(new BmLoadNext());}
	public static function loadButPrevious():		Bitmap{return new BitmapSmoothed(new BmLoadPrevious());}

	public static function loadLogScale(?i:Bool):	Bitmap{return new BitmapGlyph(new BmLogScale(), i);}
	public static function loadLinScale(?i:Bool):	Bitmap{return new BitmapGlyph(new BmLinScale(), i);}
	public static function loadSQLDate(?i:Bool):	Bitmap{return new BitmapGlyph(new BmSQLDate(), i);}
	public static function loadSQLDateFrom(?i:Bool):Bitmap{return new BitmapGlyph(new BmSQLDateFrom(), i);}
	public static function loadSQLDateTo(?i:Bool):	Bitmap{return new BitmapGlyph(new BmSQLDateTo(), i);}
	public static function loadSQLFilterOn(?i:Bool):Bitmap{return new BitmapSmoothed(new BmSQLFilterOn());}
	public static function loadSQLFilterOff(?i:Bool):Bitmap{return new BitmapSmoothed(new BmSQLFilterOff());}
	public static function loadReset(?i:Bool):		Bitmap{return new BitmapGlyph(new BmReset(), i);}
	public static function loadZoomPlus(?i:Bool):	Bitmap{return new BitmapGlyph(new BmZoomPlus(), i);}
	public static function loadZoomMinus(?i:Bool):	Bitmap{return new BitmapGlyph(new BmZoomMinus(), i);}
	public static function loadDebug(?i:Bool):		Bitmap{return new BitmapGlyph(new BmDebug(), i);}
	public static function loadDeviation():			Bitmap{return new BitmapSmoothed(new BmDeviation());}
	public static function loadAverage():			Bitmap{return new BitmapSmoothed(new BmAverage());}
	public static function loadChrono(?i:Bool):		Bitmap{return new BitmapGlyph(new BmChrono(), i);}
	public static function loadEncoder():			Bitmap{return new BitmapSmoothed(new BmEncoder());}
	public static function loadChannel():			Bitmap{return new BitmapSmoothed(new BmChannel());}
	public static function loadWait():				Bitmap{return new BitmapSmoothed(new BmWait());}
	public static function loadMXT():				Bitmap{return new BitmapSmoothed(new BmLogoMXT());}
	public static function loadExclamation():		Bitmap{return new BitmapSmoothed(new BmExclamation());}
	public static function loadNuclear():			Bitmap{return new BitmapSmoothed(new BmNuclear());}
	public static function loadNuclear45():			Bitmap{return new BitmapSmoothed(new BmNuclear45());}
	public static function loadTruckWatermark():	Bitmap{return new BitmapSmoothed(new BmTruckWatermark());}
	public static function loadNuclearBusy():		Bitmap{return new BitmapSmoothed(new BmNuclearBusy());}
	public static function loadGo():				Bitmap{return new BitmapSmoothed(new BmGo());}
	public static function loadView(i:Bool):		Bitmap{return new BitmapGlyph(new BmView(), i);}
	public static function loadLEDRAOn():			Bitmap{return new BitmapSmoothed(new BmLedRaOn());}
	public static function loadLEDRAOnSel():		Bitmap{return new BitmapSmoothed(new BmLedRaOnSel());}
	public static function loadLEDRAOff():			Bitmap{ return new BitmapSmoothed(new BmLedRaOff()); }
	public static function loadLEDRAOffSel():		Bitmap{ return new BitmapSmoothed(new BmLedRaOffSel()); }
	public static function loadLEDRepNonOK():		Bitmap{ return new BitmapSmoothed(new BmLedRepNonOK()); }
	public static function loadLEDRepNonOKSel():	Bitmap{ return new BitmapSmoothed(new BmLedRepNonOKSel()); }
	public static function loadLEDSteel(?i:Bool):	Bitmap{return new BitmapGlyph(new BmLedSteel(), i);}
	public static function loadLEDGreenSteel(?i:Bool):Bitmap{return new BitmapGlyph(new BmLedGreenSteel(), i);}
	public static function loadStop():				Bitmap{return new BitmapSmoothed(new BmStop());}
	public static function loadInitBusy():			Bitmap{return new BitmapSmoothed(new BmInitBusy());}
	public static function loadPortal():			Bitmap{return new BitmapSmoothed(new BmPortal());}
	public static function loadMonitor(?i:Bool):	Bitmap{return new BitmapGlyph(new BmMonitor(), i);}
	public static function loadMeasures(?i:Bool):	Bitmap{return new BitmapGlyph(new BmMeasures(), i);}
	public static function loadReport():			Bitmap{return new BitmapGlyph(new BmReport());}
	public static function loadButPortal():			Bitmap{return new BitmapSmoothed(new BmButPortal());}
	public static function loadPrinter(?i:Bool):	Bitmap{return new BitmapGlyph(new BmPrinter(), i);}
	public static function loadKeyboard():			Bitmap{return new BitmapSmoothed(new BmKeyboard());}
	public static function loadMicrophone():		Bitmap{return new BitmapGlyph(new BmMicrophone());}
	public static function loadHistory(?i:Bool):	Bitmap{return new BitmapGlyph(new BmHistory(), i);}
	public static function loadLogBook(?i:Bool):	Bitmap{return new BitmapGlyph(new BmLogBook(), i);}
	public static function loadStatistics(?i:Bool):	Bitmap{return new BitmapGlyph(new BmStatistics(), i);}
	public static function loadContacts(?i:Bool):	Bitmap{return new BitmapGlyph(new BmContacts(), i);}
	public static function loadDataBase():			Bitmap{return new BitmapGlyph(new BmDataBase());}
	public static function loadSettings(?i:Bool):	Bitmap{return new BitmapGlyph(new BmSettings(), i);}
	public static function loadUser(i:Bool):		Bitmap{return new BitmapGlyph(new BmUser(), i);}
	public static function loadUsers(?i:Bool):		Bitmap{return new BitmapGlyph(new BmUsers(), i);}
	public static function loadMute():				Bitmap{return new BitmapGlyph(new BmMute());}
	public static function loadLoudSpeaker(?i:Bool):Bitmap{return new BitmapGlyph(new BmLS(), i);}
	public static function loadAck():				Bitmap{return new BitmapGlyph(new BmAck());}
	public static function loadAckDis():			Bitmap{return new BitmapGlyph(new BmAckDis());}
	public static function loadTest(?i:Bool):		Bitmap{return new BitmapGlyph(new BmTest(), i);}
	public static function loadExit():				Bitmap{return new BitmapGlyph(new BmExit());}
	public static function loadReportFRBitmap():	Bitmap{return new BitmapSmoothed(new BmReportBitmapFR());}
	public static function loadSignalGreen():		Bitmap{return new BitmapSmoothed(new BmSignalGreen());}
	public static function loadSignalOrange():		Bitmap{return new BitmapSmoothed(new BmSignalOrange());}
	public static function loadSignalNeutral():		Bitmap{return new BitmapSmoothed(new BmSignalNeutre());}
	public static function loadSignalRed():			Bitmap{return new BitmapSmoothed(new BmSignalRed());}
	public static function loadBKGBusy():			Bitmap{return new BitmapSmoothed(new BmBKGBusy());}
	public static function loadCamera(?i:Bool):		Bitmap{return new BitmapGlyph(new BmCamera(), i);}
	public static function loadMaximize():			Bitmap{return new BitmapSmoothed(new BmMaximize());}

	public static function loadtruckWhite():		Bitmap{return new BitmapSmoothed(new BmTruckWhite());}
	public static function loadtruckGreen():		Bitmap{return new BitmapSmoothed(new BmTruckGreen());}
	public static function loadtruckBlue():			Bitmap{return new BitmapSmoothed(new BmTruckBlue());}
	public static function loadtruckYellow():		Bitmap{return new BitmapSmoothed(new BmTruckYellow());}
	public static function loadtruckRed():			Bitmap{return new BitmapSmoothed(new BmTruckRed());}

	/**
	 * 
	 * @param	bitmap
	 * @return
	 */
	public static function getBM(bm1:Bitmap, bm2:Bitmap = null):Sprite
	{
		var spriteLogo = new Sprite();

		Images.addResizedBitmap(new Bitmap(bm1.bitmapData), spriteLogo, 256, 256);
		if(cast bm2)
			Images.addResizedBitmap(new Bitmap(bm2.bitmapData), spriteLogo, 256, 256);

		return spriteLogo;
	}	

	/**
	 * 
	 * @param	bitmap
	 * @return
	 */
	public static function addResizedBitmap(bitmap:Bitmap, sprite:Sprite, w:Int, h:Int):Void
	{
		if (bitmap != null)
		{
			bitmap.x = 0;
			bitmap.y = 0;
			bitmap.filters = Filters.winFilters;
			bitmap.alpha = 1;
			resize(bitmap, w, h);
			sprite.x = 0;
			sprite.y = 0;
			sprite.addChild(bitmap);
			sprite.visible = false;
		}
	}

	/**
	 * 
	 * @param	source
	 * @param	width
	 * @param	height
	 * @return
	 */
	public static function resize(source:Bitmap, width:Int, ?height:Int, ?x:Int=0, ?y:Int=0) : Bitmap
	{
		source.smoothing = true;
		source.scaleX = source.scaleY = width / Math.min(source.bitmapData.height, source.bitmapData.height);
		source.x = x;
		source.y = y;
		
		return source;
	}

	/**
	 * 
	 * @param	bitmap
	 * @param	w
	 * @param	h
	 */
	static public function centerBitmap(bitmap:Bitmap, w:Int, h:Int) 
	{
		bitmap.x = (w - bitmap.width) / 2;
		bitmap.y = (h - bitmap.height) / 2;
	}
	
	/**
	 * 
	 * @param	spriteNuclear
	 */
	static public function getSP(spr1:Sprite, spr2:Sprite) 
	{
		
	}
	
	static public function getBMSP(bm:Bitmap, sprite:Sprite) 
	{
		var spriteLogo = new Sprite();

		Images.resize(bm, 256, 256);
		spriteLogo.addChild(bm);
		spriteLogo.addChild(sprite);

		return spriteLogo;
		
	}

}
