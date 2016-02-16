package print;

import db.DBDefaults;
import db.DBTranslations;
import enums.Enums.Parameters;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PNGEncoderOptions;
import flash.display.Sprite;
import flash.external.ExternalInterface;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import pdf.FPDF;
import pdf.Tuto1;

/**
 * ...
 * @author GM
 */
class BuildFPDF extends FPDF
{
	public function new(?orientation='P', ?unit='mm', ?format:Dynamic='A4') 
	{
		super(orientation, unit, format);
	}

	/**
	 * 
	 */
	public function printBitmap(spriteToPrint:Sprite):Void 
	{
		var options 		= new PNGEncoderOptions();
		var dx:Float 		= 793;
		var dy:Float 		= 1123;
		var rect 			= new Rectangle(0, 0, dx, dy);
		var hInfo:ImageInfo = new ImageInfo();

		hInfo.type 			= "png";
		hInfo.w 			= dx ;
		hInfo.h 			= dy;
		hInfo.bpc 			= 8;
		hInfo.cs			= "DeviceRGB";
		hInfo.f				= "FlateDecode";
		hInfo.parms			= "/DecodeParms <</Predictor 15 /Colors 3 /BitsPerComponent 8 /Columns 793>>";

		var bmData 			= new BitmapData(cast dx, cast dy);
		var mat 			= new Matrix();
		mat.scale(0.64, 0.64);

		bmData.draw(spriteToPrint, mat);
		hInfo.data			= bmData.encode(rect, options);

		var reportName 		= DBTranslations.getText("IDS_REPORT");
		//trace("Creating PDF ...");

		try {
	
			addPage('P', 'A4');                   //<- this is a 'FPDF' public function
			setCompression(false);
			setLeftMargin(0);
			addImageData("ReportImage", hInfo, 0, 0);
		}

		catch (unknown : Dynamic) {
			trace("Catch in PDF " + unknown);
		}

		output(reportName, 'F');
	}
}