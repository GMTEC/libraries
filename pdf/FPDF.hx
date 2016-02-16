
/******* original source code **************
** FPDF.php
*
*  Version :  1.6
*  Date    :  2008-08-03
*  Auteur  :  Olivier PLATHEY
*
** Gradients.php
*  Auteur  :  Andreas Würmser
*
** ViewPref.php
*  Auteur  :  Michel Poulain
*
** .php
*  Auteur  :  
*
********************************************
*     Transcription in haXe language :
*
*  Version :  1.56.5
*  Date    :  2011-03-12
*  Auteur  :  Michel OSTER
********************************************/
package pdf;

import flash.filesystem.File;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import format.zip.Writer;


//core fonts usable with FPDF :
import pdf.font.Courier;
import pdf.font.Helvetica;  //<- = Arial
import pdf.font.Symbol;
import pdf.font.Zapfdingbats;
import haxe.zip.Compress;
import flash.filesystem.FileStream;
import flash.filesystem.FileMode;

class FPDF {
	static inline var PDFVersion = '1.3';  //default PDF version number
	static inline var RadPDF_VERSION = '1.56.5';
	var fcc: Int -> String;
	var replace: String -> String -> String -> String;

	var numPage: Int;             //current page number
	var n: Int;                   //current object number
	var hOffsets: IntHash<Int>;   //array of object offsets

	var sBuffer: ByteArray;          //buffer holding in-memory PDF
	var hPages: IntHash<String>;  //array containing pages
	var state: Int;               //current document state
	var compress: Bool;           //compression flag

	var k: Float;                 //scale factor (number of points in user unit)
	var sDefOrientation: String;  //default orientation
	var sCurOrientation: String;  //current orientation

	var hPageFormats: Hash<Array<Float>>;   //available page formats
	var aDefPageFormat: Array<Float>;       //default page format
	var aCurPageFormat: Array<Float>;       //current page format

	var hPageSizes: IntHash<Array<Float>>;  //array storing non-default page sizes
	var wPt: Float; var hPt: Float;         //dimensions ( width & height ) of current page in points
	var w: Float; var h: Float;             //dimensions ( width & height ) of current page in user unit

	var lMargin: Float;  //left margin
	var tMargin: Float;  //top margin
	var rMargin: Float;  //right margin
	var bMargin: Float;  //page break margin
	var cMargin: Float;  //cell margin

	var x: Float; var y: Float;  //current position in user unit
	var lastH: Float;            //height of last printed cell
	var lineWidth: Float;        //line width in user unit

	var fpdf_charwidths: Hash<Array<Int>>;

	var hCoreFonts: Hash<String>;  //array of standard font names
	var hFonts: Hash< FontInfo >;  //array of used fonts
	var currentFont: FontInfo;     //current font info
	var hFontFiles: Hash< FontFile >;  //array of font files
	var aDiffs: Array<Dynamic>;    //array of encoding differences

	var sFontFamily: String;  //current font family
	var sFontStyle: String;   //current font style
	var bUnderline: Bool;     //underlining flag
	var fFontSizePt: Float;   //current font size in points
	var fFontSize: Float;     //current font size in user unit

	var sDrawColor: String;   //commands for drawing color
	var sFillColor: String;   //commands for filling color
	var sTextColor: String;   //commands for text color
	var bColorFlag: Bool;     //indicates whether fill and text colors are different

	var fWordSpace: Float;    //word spacing

	var hImages: Hash< ImageInfo >;   //array of used images

	var numLink: Int;  //nombre de liens-stop ( potentiels )
	var hStopLinks: IntHash< StopLink >;  //array of internal links
	var hPageLinks: IntHash< IntHash< StartLink >>;  //array of links in pages
	var numRect: Int;  //nombre de liens-start <--> tableaux [x, y, w, h]

	var bAutoPageBreak: Bool;      //automatic page breaking
	var fPageBreakTrigger: Float;  //threshold used to trigger page breaks

	var bInHeader: Bool;  //flag set when processing header
	var bInFooter: Bool;  //flag set when processing footer

	var sZoomMode: String;    //zoom display mode
	var sLayoutMode: String;  //layout display mode

	var sTitle: String;     //title
	var sSubject: String;   //subject
	var sAuthor: String;    //author
	var sKeywords: String;  //keywords
	var sCreator: String;   //creator
	var sAliasNbPages: String;  //alias for total number of pages

  //paramétrages du 'Reader'
	public var reader: Reader;
  //gestion des dégradés de couleurs
	var aGradients: Array< Gradient >;
	var aGradPatchs: Array< GradientPatch >;

	/*******************************************************************************
	*                                                                              *
	*                               Public methods                                 *
	*                                                                              *
	*******************************************************************************/
	public function new( ?orientation = 'P', ?unit = 'mm', ?format: Dynamic = 'A4') {
		fcc = String.fromCharCode;
		replace = StringTools.replace;
		//Initialization of properties :
		//Scale factor
		var hUnit = new Hash<Float>();
		hUnit.set( 'pt', 1 );
		hUnit.set( 'mm', 72 / 25.4 );
		hUnit.set( 'cm', 72 / 2.54 );
		hUnit.set( 'in', 72 );
		if( unit == null || unit == '' || ! hUnit.exists( unit ) ) unit = 'mm';
		this.k = hUnit.get( unit );

		numPage = 0;
		this.n = 2;
		sBuffer = new ByteArray();
		hOffsets = new IntHash();

		hPages = new IntHash();
		hPageSizes = new IntHash();
		state = 0;

		hImages = new Hash();

		numLink = 0;
		hStopLinks = new IntHash();
		hPageLinks = new IntHash();
		numRect = 0;

		bInHeader = false;
		bInFooter = false;
		lastH = 0;

		sDrawColor = '0 G';
		sFillColor = '0 g';
		sTextColor = '0 g';
		bColorFlag = false;

		fWordSpace = 0;

		hFonts = new Hash();
		hFontFiles = new Hash();
		aDiffs = new Array();  //<- quel type ?

		//currentFont = new FontInfo;  //<- initialisée en appelant 'setFont()'
		sFontFamily = '';  //<- variable initialisée en appelant 'setFont()' !
		sFontStyle = '';
		bUnderline = false;
		fFontSizePt = 12.0;

		fpdf_charwidths = new Hash();
		//Standard fonts
		hCoreFonts = new Hash();
		hCoreFonts.set('courier',   'Courier');
		hCoreFonts.set('courierB',  'Courier-Bold');
		hCoreFonts.set('courierI',  'Courier-Oblique');
		hCoreFonts.set('courierBI', 'Courier-BoldOblique');
		hCoreFonts.set('helvetica',   'Helvetica');
		hCoreFonts.set('helveticaB',  'Helvetica-Bold');
		hCoreFonts.set('helveticaI',  'Helvetica-Oblique');
		hCoreFonts.set('helveticaBI', 'Helvetica-BoldOblique');
		hCoreFonts.set('times',   'Times-Roman');
		hCoreFonts.set('timesB',  'Times-Bold');
		hCoreFonts.set('timesI',  'Times-Italic');
		hCoreFonts.set('timesBI', 'Times-BoldItalic');
		hCoreFonts.set('symbol', 'Symbol');
		hCoreFonts.set('zapfdingbats', 'ZapfDingbats');

		//Page format
		hPageFormats = new Hash();
		hPageFormats.set('a3',     [841.89, 1190.55]);
		hPageFormats.set('a4',     [595.28, 841.89]);
		hPageFormats.set('a5',     [420.94, 595.28]);
		hPageFormats.set('letter', [612.00, 792.00]);
		hPageFormats.set('legal',  [612.00, 1008.00]);

		if( ! isPageFormat( format ) ) format = 'A4';
		if( Std.is( format, String ) ) format = _getpageformat( format );
		aDefPageFormat = format;
		aCurPageFormat = format;

		//Page orientation
		if( ! isOrientation( orientation ) ) orientation = 'P';
		orientation = orientation.charAt(0).toLowerCase();
		if(orientation == 'p') {  // || orientation == 'portrait'
			sDefOrientation = 'P';
			this.w = aDefPageFormat[0];
			this.h = aDefPageFormat[1];
		}
		else if(orientation == 'l') {  // || orientation == 'landscape'
			sDefOrientation = 'L';
			this.w = aDefPageFormat[1];
			this.h = aDefPageFormat[0];
		}
		sCurOrientation = sDefOrientation;

		this.wPt = this.w * this.k;
		this.hPt = this.h * this.k;

		var margin = 28.35 / this.k;         //Page margins (1 cm)
		setMargins(margin, margin);
		cMargin = margin / 10;               //Interior cell margin (1 mm)
		lineWidth = .567 / this.k;           //Line width (0.2 mm)
		setAutoPageBreak(true, 2 * margin);  //Automatic page break
		setDisplayMode('fullwidth');         //Full width display mode

		compress = true;  //Enable compression

		sTitle = '';
		sSubject = '';
		sAuthor = '';
		sKeywords = '';
		sCreator = '';
		sAliasNbPages = '';  //'{nb}';

		reader = new Reader();  //paramétrages du 'Reader'
		aGradients = new Array();
		aGradPatchs = new Array();
	}

	public function setMargins(left: Float, top: Float, ?right: Float) {  //Set left, top and right margins
		if( left < 0 ) left = 0;
		if( top < 0 ) top = 0;
		if(right == null)
			right = left;
		if( right < 0 ) right = 0;

		lMargin = left;
		tMargin = top;
		rMargin = right;
	}

	public function setLeftMargin(margin: Float) {  //Set left margin
		if( margin < 0 ) margin = 0;
		lMargin = margin;
		if(numPage > 0 && this.x < margin)
			this.x = margin;
	}

	public function setTopMargin(margin: Float) {  //Set top margin
		if( margin < 0 ) margin = 0;
		tMargin = margin;
	}

	public function setRightMargin(margin: Float) {  //Set right margin
		if( margin < 0 ) margin = 0;
		rMargin = margin;
	}

	public function setAutoPageBreak(auto: Bool, ?margin = 0.0) {  //Set auto page break mode and triggering margin
		if( margin < 0 ) margin = 0;
		bAutoPageBreak = auto;
		bMargin = margin;
		fPageBreakTrigger = this.h - margin;
	}

	public function setDisplayMode(zoom: Dynamic, ?layout = 'continuous') {  //Set display mode in viewer
		var ok = switch zoom {
			case null: false;
			case 'fullpage', 'fullwidth', 'real', 'default': true;
			default: {
				var z = Std.parseInt(zoom);
				if( z != null ) {
					if( z < 0 ) z *= -1;
					zoom = Std.string( z / 100 );  //<- chiffre exprimé en pourcentage
					true;
				}
				else false;
			}
		}
		if( ok )
			sZoomMode = zoom;
		else
			sZoomMode = 'fullwidth';  //throw 'Incorrect zoom display mode : ' + zoom;

		sLayoutMode = switch layout {
			case 'single', 'two', 'default': layout;
			default: 'continuous';  //throw 'Incorrect layout display mode : ' + layout;
		}
	}

	public function setCompression(zlib: Bool) {  //Set page compression
		compress = zlib;
	}

	public function setTitle(s: String, ?isUTF8 = false) {  //Title of document
		if(s == null) s = '';
		if(isUTF8)
			s = _UTF8toUTF16( s );
		sTitle = s;
	}

	public function setSubject(s: String, ?isUTF8 = false) {  //Subject of document
		if(s == null) s = '';
		if(isUTF8)
			s = _UTF8toUTF16( s );
		sSubject = s;
	}

	public function setAuthor(s: String, ?isUTF8 = false) {  //Author of document
		if(s == null) s = '';
		if(isUTF8)
			s = _UTF8toUTF16( s );
		sAuthor = s;
	}

	public function setKeywords(s: String, ?isUTF8 = false) {  //Keywords of document
		if(s == null) s = '';
		if(isUTF8)
			s = _UTF8toUTF16( s );
		sKeywords = s;
	}

	public function setCreator(s: String, ?isUTF8 = false) {  //Creator of document
		if(s == null) s = '';
		if(isUTF8)
			s = _UTF8toUTF16( s );
		sCreator = s;
	}

	public function aliasNbPages(?alias = '{nb}') {  //Define an alias for total number of pages
		if(alias == null) alias = '';
		sAliasNbPages = alias;
	}

	function open() {  //Begin document
		state = 1;
	}

	public function close() {  //Terminate document
		if(state == 3)
			return;
		if(numPage == 0)
			addPage();
		//Page footer
		bInFooter = true;
		footer();
		bInFooter = false;
		//Close page
		_endpage();
		//Close document
		_enddoc();
	}

	public function addPage(?orientation = '', ?format: Dynamic = '') {  //Start a new page
		if(state == 0)
			open();
		var family = sFontFamily;
		var style = sFontStyle + (bUnderline ? 'U' : '');
		var size = fFontSizePt;
		var lw = lineWidth;
		var dc = sDrawColor;
		var fc = sFillColor;
		var tc = sTextColor;
		var cf = bColorFlag;
		if(numPage > 0) {			//Page footer
			bInFooter = true;
			footer();
			bInFooter = false;
			_endpage();  //<- Close page
		}

		//Start new page
		//if( ! isOrientation( orientation ) ) orientation = '';
		if( ! isPageFormat( format ) ) format = '';
		_beginpage(orientation, format);

		//Set line cap style to square
		_out('2 J');
		lineWidth = lw;
		_out(sculpt('%.2F w', [lw * this.k], [], []));

		//Set font
		if(family != '')
			setFont(family, style, size);
		//Set line width
		//Set colors
		sDrawColor = dc;
		if(dc != '0 G')
			_out(dc);
		sFillColor = fc;
		if(fc != '0 g')
			_out(fc);
		sTextColor = tc;
		bColorFlag = cf;
		//Page header
		bInHeader = true;
		header();
		bInHeader = false;
		//Restore line width
		if(lineWidth != lw) {
			lineWidth = lw;
			_out(sculpt('%.2F w', [lw * this.k], [], []));
		}
		//Restore font
		if(family != '')
			setFont(family, style, size);
		//Restore colors
		if(sDrawColor != dc) {
			sDrawColor = dc;
			_out(dc);
		}
		if(sFillColor != fc) {
			sFillColor = fc;
			_out(fc);
		}
		sTextColor = tc;
		bColorFlag = cf;
	}

	public function header() {  //To be implemented in your own inherited class
	}

	public function footer() {  //To be implemented in your own inherited class
	}

	public function pageNo() {  //Get current page number
		return numPage;
	}

	public function setDrawColor(r: Int, ?g = -1, ?b = -1) {  //Set color for all stroking operations
		sDrawColor = getStringColor( 'RG', r, g, b );
		if(numPage > 0)
			_out( sDrawColor );
	}
	public function setFillColor(r: Int, ?g = -1, ?b = -1) {  //Set color for all filling operations
		sFillColor = getStringColor( 'rg', r, g, b );
		bColorFlag = (sFillColor != sTextColor);
		if(numPage > 0)
			_out(sFillColor);
	}
	public function setTextColor(r: Int, ?g = -1, ?b = -1) {  //Set color for text
		sTextColor = getStringColor( 'rg', r, g, b );
		bColorFlag = (sFillColor != sTextColor);
	}
	function getStringColor(typ: String, r: Int, ?g = -1, ?b = -1) {
		return
			if( (g < 0 || b < 0) || (r == 0 && g == 0 && b == 0) )
				sculpt('%.3F ' + typ.charAt(1), [r / 255], [], []);
			else {
				if( r < 0 ) r = 0;
				else if( r > 255 ) r = 255;
				if( g < 0 ) g = 0;
				else if( g > 255 ) g = 255;
				if( b < 0 ) b = 0;
				else if( b > 255 ) b = 255;
				sculpt('%.3F %.3F %.3F ' + typ, [r / 255, g / 255, b / 255], [], []);
			}
	}

	public function getStringWidth( s: String ) {  //Get width of a string in the current font
		if(s == null) s = '';
		var aCharWidths = currentFont.cw;
		var w = 0;
		var end = s.length;
		for( i in 0...end ) {
			w += aCharWidths[ s.charCodeAt(i) ];
		}
		return w * fFontSize / 1000;
	}

	public function setLineWidth(width: Float) {  //Set line width
		if( width < 0 ) width = 0;
		lineWidth = width;
		if(numPage > 0)
			_out(sculpt('%.2F w', [width * this.k], [], []));
	}

	public function line(x1: Float, y1: Float, x2: Float, y2: Float) {  //Draw a line
		//if( x1 < 0 ) x1 = 0; if( y1 < 0 ) y1 = 0; if( x2 < 0 ) x2 = 0; if( x2 < 0 ) y2 = 0;
		_out(sculpt('%.2F %.2F m %.2F %.2F l S', [x1 * this.k, (this.h - y1) * this.k, x2 * this.k, (this.h - y2) * this.k], [], []));
	}

	public function rect(x: Float, y: Float, w: Float, h: Float, ?style = '') {  //Draw a rectangle
		//if( x < 0 ) x = 0; if( y < 0 ) y = 0; if( w < 1 ) w = 1; if( h < 1 ) h = 1;
		if(style == null) style = '';
		var op = switch style {
			case 'F': 'f';
			case 'FD', 'DF': 'B';
			default: 'S';
		}
		_out(sculpt('%.2F %.2F %.2F %.2F re %s', [x * this.k, (this.h - y) * this.k, w * this.k, -h * this.k], [], [op]));
	}

/* TODO
	public function addFont(family: String, ?style = '', ?file = '') {  //Add a TrueType or Type1 font
		family = family.toLowerCase();
		if(file == null || file == '')
			file = family.split(' ').join('') + style.toLowerCase() + '.php';
		if(family == 'arial')
			family = 'helvetica';
		style = style.toUpperCase();
		if(style == 'IB')
			style = 'BI';
		var fontkey = family + style;
		if( hFonts.exists(fontkey) ) return;

		include(this._getfontpath() + file);  //<-
		if(!isset($name))
			throw 'Could not include font definition file';

		var i = Lambda.count(hFonts) + 1;
		var fi = new FontInfo();
		fi.i = i;
		fi.type = type;
		fi.name = name;
		fi.up = up;
		fi.ut = ut;
		fi.cw = cw;

		fi.file = file;
		fi.desc = desc;  //<- Hash<String> ?
		fi.enc = enc;  //<- quel type ?

		if($diff) {  //Search existing encodings
			var d = 0;
			var nb = aDiffs.length;
			for(i in 1...(nb + 1); i++) {
				if(aDiffs[i] == $diff) {  //<- 1 à nb inclus ??
					d = i;
					break;
				}
			}
			if(d == 0) {
				d = nb + 1;
				aDiffs[d] = $diff;
			}
			fi.diff = d;
		}
		hFonts.set(fontkey, fi);

		if( file != '' ) {
			var fntFile = new FontFile();
			if(type == 'TrueType') {
				fntFile.length1 = $originalsize;  //array('length1'=>$originalsize);
			} else {
				fntFile.length1 = $size1;  //array('length1'=>$size1, 'length2'=>$size2);
				fntFile.length2 = $size2;
			}
			hFontFiles.set(file, fntFile);
		}
	}
*/

	function isFontkey( s: String ) {
		return
			if(s == null || s == '') false;
			else if( hFonts.exists( s ) ) true;
			else if( hCoreFonts.exists( s ) ) true;
			else false;
	}

	public function setFont(family: String, ?style = '', ?size = 0.0) {  //Select a font; size given in points
		if(family == null || family == '') family = sFontFamily;
		if(style == null) style = '';

		family = family.toLowerCase();
		switch family {
			case 'arial': family = 'helvetica';
			case 'symbol', 'zapfdingbats': style = '';
		}

		style = style.toUpperCase();
		bUnderline = ( style.indexOf('U') > -1 );
		if( bUnderline ) style = style.split('U').join('');
		if(style == 'IB') style = 'BI';

		if(size < 4 || size > 72) size = fFontSizePt;  //<- test du paramètre

		if( ! isFontkey( family + style ) ) {  //<- test des paramètres de la fonction
			//fixe des valeurs par défaut :
			if(sFontFamily == '') {
				family = 'helvetica';
				style = '';
				bUnderline = false;
			} else {
				family = sFontFamily;
				style = sFontStyle;
			}
		}

		//Test if font is already selected
		if(sFontFamily == family && sFontStyle == style && fFontSizePt == size)
			return;

		//Test if used for the first time
		var fontkey = family + style;
		if( ! hFonts.exists( fontkey ) ) {  //Check if one of the standard fonts
			if( hCoreFonts.exists(fontkey) ) {
				if( ! fpdf_charwidths.exists( fontkey ) ) {  //Load metric file
					var clName = 'pdf.font.' + fontkey.charAt(0).toUpperCase() + fontkey.substr(1);
					var cl = Type.resolveClass( clName );
					if( cl != null && Reflect.hasField(cl, 'cw') ) {
						var aCharWidths: Array<Int> = Reflect.field(cl, 'cw');
						fpdf_charwidths.set( fontkey, aCharWidths );
					}
					else throw 'Could not include font metric file';
				}
				var fi = new FontInfo();
				fi.i = Lambda.count(hFonts) + 1;
				fi.type = 'core';
				fi.name = hCoreFonts.get(fontkey);
				fi.up = -100.0;
				fi.ut = 50.0;
				fi.cw = fpdf_charwidths.get(fontkey);

				hFonts.set(fontkey, fi);
			}
			//else throw 'Undefined font : ' + family + ' ' + style;
		}
		//Select it
		sFontFamily = family;
		sFontStyle = style;
		fFontSizePt = size;
		fFontSize = size / this.k;
		currentFont = hFonts.get(fontkey);
		if(numPage > 0) {
			_out( sculpt('BT /F%d %.2F Tf ET', [fFontSizePt], [currentFont.i], []) );
		}
	}

	public function setFontSize(size: Float) {  //Set font size in points
		if(size < 4 || size > 72) size = fFontSizePt;  //<- test du paramètre
		if(fFontSizePt == size)
			return;
		fFontSizePt = size;
		fFontSize = size / this.k;
		if(numPage > 0) {
			_out(sculpt('BT /F%d %.2F Tf ET', [fFontSizePt], [currentFont.i], []));
		}
	}

	public function addLink() {  //Create a new internal link
		if( ++numLink > 9999 ) throw 'The maximum of 9999 links in a document is reached !';
		return numLink;
	}

	public function setLink(link: Int, ?y = -1.0, ?page = -1) {  //Set destination of internal link
		if( link < 1 || link > numLink ) throw 'not a valid link : ' + link + ' ( 1...' + numLink + ' )';

		if( y < 0 ) y = this.y;
		if( page < 1 ) page = numPage;

		var o = 
			if( hStopLinks.exists( link ) ) hStopLinks.get(link);
			else new StopLink();  //<- [ NoPage = 0, posY = 0.0 ]
		o.page = page;
		o.y = y;
		hStopLinks.set(link, o);
	}

	function isLink( link: Dynamic ) {
		//note : 'link' est soit un 'numéro' ( indice de 'hStopLinks' ), soit une URL ( essai concluant sous neko 'localhost' )
		return
			if(link == null ) false;
			else if( Std.is(link, Int) ) {
				hStopLinks.exists( link );
			}
			else if( Std.is(link, String) ) {
				//var s = Std.string( link );
				//if( s.indexOf('http://') == 0 ) true else false;  // TODO || s.indexOf('file://') == 0
				( link != '' );
			}
			else false;
	}

	public function link(x: Float, y: Float, w: Float, h: Float, link: Dynamic) {  //Put a link on the page
		var sStopLink = Std.string( link );
		if( ! isLink( link ) ) throw 'not a valid link : ' + sStopLink;

		if( Std.is(link, Int) ) {
			while( sStopLink.length < 4 ) sStopLink = '0' + sStopLink;  //<- formaté sur 4 chiffres : '9999'
		}
		x *= this.k;
		y = this.hPt - y * this.k;
		w *= this.k;
		h *= this.k;

		var hStartLinks =
			if( hPageLinks.exists(numPage) )
				hPageLinks.get(numPage);
			else new IntHash();

		var doIt = true;
		for( iKey in hStartLinks.keys() ) {
			var lk = hStartLinks.get( iKey );
			var r = lk.rect;  //<- 'r' = une instance de 'LinkRect' [x, y, w, h]
			if( x <= r.x && y <= r.y && (x + w) >= (r.x + r.w) && (y + h) >= (r.y + r.h) ) {
				lk.stopLink == sStopLink;  //<- soit on modifie l'enregistrement en conservant 'numRect'
				hStartLinks.set( iKey, lk );
				doIt = false;
				//hStartLinks.remove( iKey );  //<- soit on supprime l'enregistrement ?!
				break;
			}
		}
		if( doIt ) {
			var r = new LinkRect( x, y, w, h );
			hStartLinks.set( ++numRect, new StartLink( sStopLink, r ) );
		}
		hPageLinks.set(numPage, hStartLinks);
	}

	public function text(x: Float, y: Float, txt: String) {  //Output a string
		if( txt == null ) txt = '';
		var s = sculpt('BT %.2F %.2F Td (%s) Tj ET', [x * this.k, (this.h - y) * this.k], [], [_escape(txt)]);
		if(bUnderline && txt != '')
			s += ' ' + _dounderline(x, y, txt);
		if(bColorFlag)
			s = 'q ' + sTextColor + ' ' + s + ' Q';
		_out(s);
	}

	public function acceptPageBreak() {  //Accept automatic page break or not
		return bAutoPageBreak;
	}

	function isBorder( border: Dynamic ) {
		//note : 'border' peut être soit un nombre ( 0 ou 1 ), soit une chaîne ( 'LTRB' ) :
		return
			if(border == null ) false;
			else if( Std.is(border, Int) ) {
				( border == 0 || border == 1 );
			}
			else if( Std.is(border, String) && border != '' ) true;
			else false;
	}

	public function cell(w: Float, ?h = 0.0, ?txt = '', ?border: Dynamic = 0, ?ln = 0, ?align = '', ?fill = false, ?link: Dynamic = '') {  //Output a cell
		if( ! isBorder( border ) ) border = false;  // throw 'not a border-value : ' + Std.string( border );

		var k = this.k;
		if(this.y + h > fPageBreakTrigger && !bInHeader && !bInFooter && acceptPageBreak()) {  //Automatic page break
			var x = this.x;
			var ws = fWordSpace;
			if(ws > 0) {
				fWordSpace = 0;
				_out('0 Tw');
			}
			addPage(sCurOrientation, aCurPageFormat);
			this.x = x;
			if(ws > 0) {
				fWordSpace = ws;
				_out(sculpt('%.3F Tw', [ws * k], [], []));
			}
		}
		if(w <= 0)  //if(w == 0)
			w = this.w - rMargin - this.x;

		var s = '';
		if(fill || border == 1) {
			var op = if(fill) {
				(border == 1) ? 'B' : 'f';
			}
			else 'S';
			s = sculpt('%.2F %.2F %.2F %.2F re %s ', [this.x * k, (this.h - this.y) * k, w * k, -h * k], [], [op]);
		}
		if( Std.is(border, String) ) {
			var bord: String = border;
			var x = this.x;
			var y = this.y;
			var fmt = '%.2F %.2F m %.2F %.2F l S ';
			if( bord.indexOf('L') > -1 )
				s += sculpt(fmt, [x * k, (this.h - y) * k, x * k, (this.h - (y + h)) * k], [], []);
			if( bord.indexOf('T') > -1 )
				s += sculpt(fmt, [x * k, (this.h - y) * k, (x + w) * k, (this.h - y) * k], [], []);
			if( bord.indexOf('R') > -1 )
				s += sculpt(fmt, [(x + w) * k, (this.h - y) * k, (x + w) * k, (this.h - (y + h)) * k], [], []);
			if( bord.indexOf('B') > -1 )
				s += sculpt(fmt, [x * k, (this.h - (y + h)) * k, (x + w) * k, (this.h - (y + h)) * k], [], []);
		}

		if(txt == null) txt = '';
		if(txt != '') {
			var sw = getStringWidth(txt);
			var dx = switch align {
				case 'R': w - cMargin - sw;
				case 'C': (w - sw) / 2;
				default: cMargin;
			}
			if(bColorFlag)
				s += 'q ' + sTextColor + ' ';
			var txt2 = replace( replace( replace(txt, '\\', '\\\\'), '(', '\\('), ')', '\\)');
			s += sculpt('BT %.2F %.2F Td (%s) Tj ET', [(this.x + dx) * k, (this.h - (this.y + .5 * h + .3 * fFontSize)) * k], [], [txt2]);
			if(bUnderline)
				s += ' ' + _dounderline(this.x + dx, this.y +.5 * h + .3 * fFontSize, txt);
			if(bColorFlag)
				s += ' Q';
			if( isLink( link ) )
				this.link(this.x + dx, this.y + .5 * h - .5 * fFontSize, sw, fFontSize, link);
		}
		if(s != '')
			_out(s);
		lastH = h;
		if(ln > 0) {  //Go to next line
			this.y += h;
			if(ln == 1)
				this.x = lMargin;
		}
		else
			this.x += w;
	}

	public function multiCell(w: Float, h: Float, s: String, ?border: Dynamic = 0, ?align = 'J', ?fill = false) {
		//Output text with automatic or explicit line breaks
		if( ! isBorder( border ) ) border = false;  //throw 'not a border-value : ' + Std.string( border );

		if(s == null) s = '';
		s = replace( s, "\r", '' );
		var nb = s.length;
		if(nb > 0 && s.charAt(nb - 1) == "\n")
			nb--;

		var aCharWidths = currentFont.cw;
		if(w == 0)
			w = this.w - rMargin - this.x;
		var wmax = (w - 2 * cMargin) * 1000 / fFontSize;

		var b: Dynamic = 0;
		var b2 = '';  //<- ligne rajoutée
		if(border == false)
			false;
		else if(border == 1) {
			border = 'LTRB';
			b = 'LRT';
			b2 = 'LR';
		}
		else {
			b2 = '';
			var bord = Std.string( border );
			if( bord.indexOf('L') > -1 )
				b2 += 'L';
			if( bord.indexOf('R') > -1 )
				b2 += 'R';
			b = ( bord.indexOf('T') > -1 ) ? b2 + 'T' : b2;
		}

		var sep = -1;
		var i = 0;
		var j = 0;
		var l = 0;
		var ls = 0;  //<- ligne rajoutée
		var ns = 0;
		var nl = 1;
		while(i < nb) {  //Get next character
			var c = s.charAt(i);
			if(c == "\n") {  //Explicit line break
				if(fWordSpace > 0) {
					fWordSpace = 0;
					_out('0 Tw');
				}
				cell(w, h, s.substr( j, i - j), b, 2, align, fill);
				i++;
				sep = -1;
				j = i;
				l = 0;
				ns = 0;
				nl++;
				if(border != false && nl == 2)
					b = b2;
				continue;
			}
			if(c == ' ') {
				sep = i;
				ls = l;
				ns++;
			}
			l += aCharWidths[ c.charCodeAt(0) ];
			if(l > wmax) {  //Automatic line break
				if(sep == -1) {
					if(i == j)
						i++;
					if(fWordSpace > 0) {
						fWordSpace = 0;
						_out('0 Tw');
					}
					cell(w, h, s.substr( j, i - j), b, 2, align, fill);
				}
				else {
					if(align == 'J') {
						fWordSpace = (ns > 1) ? (wmax - ls) / 1000 * fFontSize / (ns - 1) : 0;
						_out(sculpt('%.3F Tw', [fWordSpace * this.k], [], []));
					}
					cell(w, h, s.substr( j, sep - j), b, 2, align, fill);
					i = sep + 1;
				}
				sep = -1;
				j = i;
				l = 0;
				ns = 0;
				nl++;
				if(border != false && nl == 2)
					b = b2;
			}
			else
				i++;
		}
		//Last chunk
		if(fWordSpace > 0) {
			fWordSpace = 0;
			_out('0 Tw');
		}
		if( Std.is(border, String) ) {
			var s = Std.string( border );
			if( s.indexOf('B') > -1 )
				b += 'B';
		}
		cell(w, h, s.substr( j, i - j), b, 2, align, fill);
		this.x = lMargin;
	}

	public function write(h: Float, s: String, ?link: Dynamic = '') {  //Output text in flowing mode
		if(s == null) s = '';
		s = replace( s, "\r", '' );

		var aCharWidths = currentFont.cw;
		var w = this.w - rMargin - this.x;
		var wmax = (w - 2 * cMargin) * 1000 / fFontSize;
		var nb = s.length;
		var sep = -1;
		var i = 0;
		var j = 0;
		var l = 0;
		var nl = 1;
		while(i < nb) {  //Get next character
			var c = s.charAt(i);
			if(c == "\n") {  //Explicit line break
				cell(w, h, s.substr( j, i - j), 0, 2, '', false, link);
				i++;
				sep = -1;
				j = i;
				l = 0;
				if(nl == 1) {
					this.x = lMargin;
					w = this.w - rMargin - this.x;
					wmax = (w - 2 * cMargin) * 1000 / fFontSize;
				}
				nl++;
				continue;
			}
			if(c == ' ')
				sep = i;
			l += aCharWidths[ c.charCodeAt(0) ];
			if(l > wmax) {  //Automatic line break
				if(sep == -1) {
					if(this.x > lMargin) {
						//Move to next line
						this.x = lMargin;
						this.y += h;
						w = this.w - rMargin - this.x;
						wmax = (w - 2 * cMargin) * 1000 / fFontSize;
						i++;
						nl++;
						continue;
					}
					if(i == j)
						i++;
					cell(w, h, s.substr( j, i - j), 0, 2, '', false, link);
				}
				else {
					cell(w, h, s.substr( j, sep - j), 0, 2, '', false, link);
					i = sep + 1;
				}
				sep = -1;
				j = i;
				l = 0;
				if(nl == 1) {
					this.x = lMargin;
					w = this.w - rMargin - this.x;
					wmax = (w - 2 * cMargin) * 1000 / fFontSize;
				}
				nl++;
			}
			else
				i++;
		}
		//Last chunk
		if(i != j)
			cell(l / 1000 * fFontSize, h, s.substr( j ), 0, 0, '', false, link);
	}

	public function ln( ?h: Float = null) {  //Line feed; default value is last cell height
		this.x = lMargin;

		if(h == null || h < 0)
			this.y += lastH;
		else
			this.y += h;
	}

	public function image( file: String, ?x: Float = null, ?y: Float = null, ?w = 0.0, ?h = 0.0, ?type = '', ?link: Dynamic = '') {
		//Put an image on the page
		var hInfo: ImageInfo;  // = new ImageInfo();

		if(file == null || file == '')
			throw 'Image file name must be notify !';
		if(type == null) type == '';

		if( ! hImages.exists( file ) ) {  //First use of this image, get info
			if(type == '') {
				var i = file.lastIndexOf('.') + 1;
				if( i == 0 )
					throw 'Image file has no extension and no type was specified : ' + file;
				type = file.substr(i);
			}
			type = type.toLowerCase();
			if(type == 'jpeg')
				type = 'jpg';
			switch type {
			case 'jpg', 'png': true;  // TODO , 'gif'
			default:
				throw 'unsupported image type : ' + type;
			}

			hInfo = 
				switch type {
				case 'jpg': _parsejpg( file );
				case 'png': _parsepng( file );
				//case 'gif': _parsegif( file );  // TODO
				default: null;
				}

			if( hInfo == null || hInfo.type == '' )
				throw 'Unavailable image file : ' + file;

			hInfo.i = Lambda.count( hImages ) + 1;
			hImages.set( file, hInfo );
		}
		else hInfo = hImages.get( file );

		addImageData(hInfo, x, y);
	}

	public function getX() {  //Get x position
		return this.x;
	}
	public function setX(x: Float) {  //Set x position
		if(x >= 0)
			this.x = x;
		else
			this.x = this.w + x;
	}
	public function getY() {  //Get y position
		return this.y;
	}
	public function setY(y: Float) {  //Set y position and reset x
		this.x = lMargin;
		if(y >= 0)
			this.y = y;
		else
			this.y = this.h + y;
	}

	/**
	 * 
	 * @param	x
	 * @param	y
	 */
	public function setXY(x: Float, y: Float) {  //Set x and y positions
		setY(y);
		setX(x);
	}

	/**
	 * 
	 * @param	fileName
	 * @param	data
	 * @param	isBinary
	 */
	function saveToDisk( fileName: String, data: ByteArray, isBinary: Bool)
	{
		var stream:FileStream = new FileStream();
		var appDir:String = File.applicationDirectory.nativePath;
		var file:File = new File( appDir + "\\" + fileName);
		stream.open(file, FileMode.WRITE);
		var ba:ByteArray = new ByteArray();
		ba.writeObject(data);
		ba.position = 0;
		stream.writeBytes(ba);
		stream.close();
	}

	/**
	 * 
	 * @param	name = ''
	 * @param	dest = ''
	 */
	public function output(?name = '', ?dest = '') {  //Output PDF to some destination
		if(state < 3)
			close();

		//saves on disk in the currentPath/file.pdf :
		if( name == null || name == '' )
			name = 'doc.pdf';
		var i = name.length - 4;
		var j = name.lastIndexOf('.pdf');
		if( i != j ) name += '.pdf';
		saveToDisk( name, sBuffer, true );

/* TODO
		dest = dest.toUpperCase();
		if(dest == '') {
			if(name == '') {
				name = 'doc.pdf';
				dest = 'I';
			}
			else
				dest = 'F';
		}
		switch( dest ) {
		case 'I':  //Send to standard output
			if(ob_get_length())
				throw 'Some data has already been output, can\'t send PDF file';
			if(php_sapi_name() != 'cli') {  //We send to a browser
				header('Content-Type: application/pdf');
				if(headers_sent())
					throw 'Some data has already been output, can\'t send PDF file';
				header('Content-Length: ' + sBuffer.length);
				header('Content-Disposition: inline; filename="' + name + '"');
				header('Cache-Control: private, max-age=0, must-revalidate');
				header('Pragma: public');
				ini_set('zlib.output_compression', '0');
			}
			Lib.print( sBuffer );  //echo sBuffer;
		case 'D':  //Download file
			if(ob_get_length())
				throw 'Some data has already been output, can\'t send PDF file';
			header('Content-Type: application/x-download');
			if(headers_sent())
				throw 'Some data has already been output, can\'t send PDF file';
			header('Content-Length: ' + sBuffer.length);
			header('Content-Disposition: attachment; filename="' + name + '"');
			header('Cache-Control: private, max-age=0, must-revalidate');
			header('Pragma: public');
			ini_set('zlib.output_compression', '0');
			Lib.print( sBuffer );  //echo sBuffer;
		case 'F':  //Save to local file
			saveToDisk( 'pdf', Bytes.ofString( sBuffer ), true );
		case 'S':  //Return as a string
			return sBuffer;
		default:
			throw 'Incorrect output destination : ' + dest;
		}
		return '';
*/
	}

	/**
	linear gradient : voir linear_gradient_coords.jpg
	* x : abscisse du coin supérieur gauche du rectangle.
	* y : ordonnée du coin supérieur gauche du rectangle.
	* w : largeur du rectangle.
	* h : hauteur du rectangle.
	* twoColors : les 2 couleurs du dégradé (composantes RVB)
	* twoXY : tableau qui définit la direction du dégradé, par défaut de la gauche vers la droite [x1=0, y1=0, x2=1, y2=0]
	**/
	public function gradient( x: Float, y: Float, w: Float, h: Float, ?twoColors: Array<Int>, ?twoXY: Array<Float> ) {
		var grad = new Gradient( gtLinear, twoColors, twoXY, null );
		aGradients.push( grad );

		clipToString( x, y, w, h );
	}

	/**
	radial gradient : voir radial_gradient_coords.jpg
	* x : abscisse du coin supérieur gauche du rectangle.
	* y : ordonnée du coin supérieur gauche du rectangle.
	* w : largeur du rectangle.
	* h : hauteur du rectangle.
	* twoColors : les 2 couleurs du dégradé (composantes RVB)
	* twoXY : tableau[ fx, fy, cx, cy ] où (fx, fy) est le point de départ du dégradé de couleur 1, (cx, cy) est le centre du cercle de couleur 2.
	* radius : le rayon du cercle
	**/
	public function gradientRadial( x: Float, y: Float, w: Float, h: Float, ?twoColors: Array<Int>, ?twoXY: Array<Float>, ?radius: Float ) {
		var grad = new Gradient( gtRadial, twoColors, twoXY, radius );
		aGradients.push( grad );

		clipToString( x, y, w, h );
	}

	/**
	* minValue : valeur minimale de toutes les valeurs de coordonnées entrant dans un 'gradientMesh'
	* maxValue : valeur maximale de toutes les valeurs de coordonnées entrant dans un 'gradientMesh'
	**/ 
	public function setMeshCoordinatesRange( ?minValue = 0.0, ?maxValue = 1.0 ) {
		if( maxValue <= minValue )
			throw "Coordinate's range : maxValue can't be less than or equal minValue";
		GradientPatch.minValue = minValue;
		GradientPatch.maxValue = maxValue;
	}
	/**
	* x : abscisse du coin supérieur gauche du rectangle.
	* y : ordonnée du coin supérieur gauche du rectangle.
	* w : largeur du rectangle.
	* h : hauteur du rectangle.
	* fourColors : les 4 couleurs du dégradé (composantes RVB)
	* note : un 'gradientMesh' est composé de 1 à 4 'GradientPatch' ( 1 par défaut )
	**/ 
	public function gradientMesh( x: Float, y: Float, w: Float, h: Float, ?fourColors: Array<Int> ) {
		if( aGradPatchs.length == 0 ) {
			GradientPatch.minValue = 0.0;
			GradientPatch.maxValue = 1.0;
			aGradPatchs = [ new GradientPatch( 0, fourColors ) ];  //<- single default patch
		}

		var s = '';  //builds the data stream and stores it :
		var bpcd = 65535;  //16 BitsPerCoordinate
		var min = GradientPatch.minValue;
		var dif = GradientPatch.maxValue - min;

		for( patch in aGradPatchs ) {  //<- multi patch array
			s += fcc( patch.f );  //start with the edge flag as 8 bit
			for( p in patch.points ) {  //each point as 16 bit
				p = (p - min) / dif * bpcd;
				if( p < 0 ) p = 0;
				else if( p > bpcd )
					p = bpcd;
				s += fcc( Std.int( p / 256 ) );  //Math.floor( p / 256 )
				s += fcc( Std.int( p % 256 ) );  //Math.floor( p % 256 )
			}
			for( c in patch.colors )  //each color component as 8 bit
				s += rgbToString( c );
		}
		var grad = new Gradient( gtMesh );  //<- coons patch mesh
		grad.stream = s;
		aGradients.push( grad );
		aGradPatchs = new Array();  //<- reset ( patchs end-of-use )

		clipToString( x, y, w, h );
	}
	/**
	* edge : niveau du patch ( de 0 à 3 ) dans la composition du 'gradientMesh'
	* fourColors : les 4 couleurs du patch (composantes RVB)
	* twelveXY : 12 paires de coordonnées qui spécifient les points de contrôle de la courbe de Bézier
	* note : pour le patch de niveau 0, il faut 12 paires; pour les niveaux 1 à 3, 8 paires suffisent
	*/
	public function addGradientPatch( edge: Int, fourColors: Array<Int>, twelveXY: Array<Float> ) {
		var t = 'bad gradient patch : ';
		var s = '';
		if( aGradPatchs.length == 0 && edge != 0 )
			s = "( the first one must have edge equal 0 )";
		else if( edge < 0 || edge > 3 )
			s = 'is outside range 0-3';
		else
			for( patch in aGradPatchs )  //<- vérifie si 'edge' existe déjà
				if( patch.f == edge ) {
					s = 'already exists';
					break;
				}
		if( s != '' )
			throw t + 'edge = ' + edge + ' ' + s;

		var topPoints = ( edge == 0 ) ? 24 : 16;
		var topColors = ( edge == 0 ) ? 4 : 2;
		if( twelveXY.length < topPoints )
			s = (topPoints >> 1) + ' X-Y coordinates';
		if( fourColors.length < topColors )
			s = topColors + ' colors';
		if( s != '' )
			throw t + s + ' are required';

		fourColors = fourColors.slice( 0, topColors );
		twelveXY = twelveXY.slice( 0, topPoints );
		//creates a single patch :
		aGradPatchs.push( new GradientPatch( edge, fourColors, twelveXY ) );
	}

	function clipToString( x: Float, y: Float, w: Float, h: Float ) {
		var s = 'q';  //<- save current Graphic State
		//set clipping area
		s += sculpt(' %.2F %.2F %.2F %.2F re W n', [ x * k, (this.h - y) * k, w * k, -h * k ], [], [] );
		//set up transformation matrix for gradient
		s += sculpt(' %.3F 0 0 %.3F %.3F %.3F cm', [ w * k, h * k, x * k, (this.h - (y + h)) * k ], [], [] );
		s += '\n';

		s += '/Sh' + aGradients.length + ' sh\n';  //<- paint the gradient
		s += 'Q';  //<- restore previous Graphic State
		_out( s );
	}
	function rgbToString( c: Int ) {
		return fcc( (c >> 16) & 0xFF ) + fcc( (c >> 8) & 0xFF ) + fcc( c & 0xFF );
	}

	/*******************************************************************************
	*                                                                              *
	*                              Protected methods                               *
	*                                                                              *
	*******************************************************************************/
/* TODO
	function _getfontpath() {
		if(!defined('FPDF_FONTPATH') && is_dir(dirname(__FILE__) + '/font'))
			define('FPDF_FONTPATH',dirname(__FILE__) + '/font/');
		return defined('FPDF_FONTPATH') ? FPDF_FONTPATH : '';
	}
*/

	function isOrientation( s: String ) {
		return
			if( s == null || s == '' ) false;
			else {
				s = s.charAt(0).toUpperCase();
				( 'PL'.indexOf( s ) > -1 );
			}
	}
	function isPageFormat( fmt: Dynamic ): Bool {
		//note : 'format' est soit un tableau[ width, height ], soit une chaîne ( 'A4' ) :
		return 
			if(fmt == null || fmt == '') false;
			else if( Std.is(fmt, Array) && fmt.length > 1 && Std.is(fmt[0], Float) ) {
				fmt = [ fmt[0] + 0.0, fmt[1] + 0.0 ];  //<- conversion en 'Float'
				( fmt[0] > 0 && fmt[1] > 0 );
			}
			else if( Std.is(fmt, String) && hPageFormats.exists( fmt ) ) true;
			else false;
	}

	function _getpageformat( fmt: String ): Array<Float> {
		fmt = fmt.toLowerCase();
		if( !hPageFormats.exists( fmt ) )
			throw 'Unknown page format : ' + fmt;
		var a = hPageFormats.get( fmt );
		a[0] /= this.k;
		a[1] /= this.k;
		return a;
	}

	function _beginpage(orientation: String, format: Dynamic) {
		numPage++;
		hPages.set( numPage, '' );
		state = 2;
		this.x = lMargin;
		this.y = tMargin;
		sFontFamily = '';
		//Check page size
		if( ! isOrientation( orientation ) )
			orientation = sDefOrientation;
		else
			orientation = orientation.charAt(0).toUpperCase();

		if( Std.is(format, String) ) {
			format = 
				if(format == '') aDefPageFormat;
				else _getpageformat( format );
		}

		if(orientation != sCurOrientation || format[0] != aCurPageFormat[0] || format[1] != aCurPageFormat[1]) {  //New size
			if(orientation == 'P') {
				this.w = format[0];
				this.h = format[1];
			}
			else {
				this.w = format[1];
				this.h = format[0];
			}
			this.wPt = this.w * this.k;
			this.hPt = this.h * this.k;
			fPageBreakTrigger = this.h - bMargin;
			sCurOrientation = orientation;
			aCurPageFormat = format;
		}
		if(orientation != sDefOrientation || format[0] != aDefPageFormat[0] || format[1] != aDefPageFormat[1])
			hPageSizes.set( numPage, [this.wPt, this.hPt] );
	}

	function _endpage() {
		state = 1;
	}

	function _escape(s: String) {  //Escape special characters in strings
		s = replace(s, '\\', '\\\\');
		s = replace(s, '(', '\\(');
		s = replace(s, ')', '\\)');
		s = replace(s, "\r", '\\r');
		return s;
	}

	function _textstring(s: String) {  //Format a text string
		return '(' + _escape(s) + ')';
	}

	function _UTF8toUTF16(s) {  //Convert UTF-8 to UTF-16BE with BOM
		var res = "\xFE\xFF";
		var nb = s.length;
		var i = 0;
		while(i < nb) {
			var c1 = s.charCodeAt( i++ );
			if(c1 >= 224) {  //3-byte character
				var c2 = s.charCodeAt( i++ );
				var c3 = s.charCodeAt( i++ );
				res += fcc( ((c1 & 0x0F)<<4) + ((c2 & 0x3C)>>2) );
				res += fcc( ((c2 & 0x03)<<6) + (c3 & 0x3F) );
			}
			else if(c1 >= 192) {  //2-byte character
				var c2 = s.charCodeAt( i++ );
				res += fcc( (c1 & 0x1C) >> 2 );
				res += fcc( ((c1 & 0x03) << 6) + (c2 & 0x3F) );
			}
			else {  //Single-byte character
				//res += "\0" + fcc( c1 );
				res += fcc( 0 ) + fcc( c1 );
			}
		}
		return res;
	}

	function _dounderline(x: Float, y: Float, txt: String) {  //Underline text
		var up: Float = currentFont.up;
		var ut: Float = currentFont.ut;
		var w = getStringWidth(txt) + fWordSpace * (txt.split(' ').length - 1);  //substr_count(txt, ' ');
		return sculpt('%.2F %.2F %.2F %.2F re f', [x * this.k, (this.h - (y - up / 1000 * fFontSize)) * this.k, w * this.k, -ut / 1000 * fFontSizePt], [], []);
	}

	function load( fileName: String ):ByteArray
	{  //<- TODO soit un chemin/fichier, soit une "URL"
		if ( true )
		{
			var stream:FileStream = new FileStream();
			var appDir:String = File.applicationDirectory.nativePath;
			var file:File = new File( appDir + "\\" + fileName);
			stream.open(file, FileMode.READ);
			var ba:ByteArray 	= new ByteArray();
			stream.readBytes(ba);
			
			return ba;
		}
		return null;
	}

	function _parsejpg( file: String ) {  // Extract info from a JPEG file
		// TODO analyse incomplète du 'jpg'
		var hInfo: ImageInfo = null;
		var data = load( file );
		var len = data.length;
		if( len < 22 ) return null;

		var w = -1.0;
		var h = -1.0;
		var bpc = -1;
		var cs = '';

		var ok = 0;
		var mark = 0;
		var byte = 0;
		var i = 0;
		while( (cast i) < len ) {
			byte = cast data[ i++ ];
			if( byte == 0xFF )
				mark = 0xFF;
			else if( mark == 0xFF ) {
				mark = (mark << 8) | byte;
				switch mark {
				case 0xFFD8: ok++;  //<- 1 marqueur
				case 0xFFC0:  //<- 1 marqueur
					var j = i;
					byte = cast data[ j++ ];
					byte = (byte << 8) | data[ j++ ];
					i += byte;
					if( (cast i) < len ) {
						bpc =  data[ j++ ];
						byte = cast data[ j++ ];
						byte = (byte << 8) | data[ j++ ];
						h = byte;
						byte = cast data[ j++ ];
						byte = (byte << 8) | data[ j++ ];
						w = byte;
						byte = cast data[ j++ ];
						cs = switch byte { case 3: 'DeviceRGB'; case 4: 'DeviceCMYK'; default: ''; };
						ok++;
					}
				}
				mark = 0;
			}
			if( ok == 2 ) {
				hInfo = new ImageInfo( len );
				hInfo.type = 'jpg';
				hInfo.w = w;
				hInfo.h = h;
				hInfo.bpc = bpc;
				hInfo.cs = cs;
				hInfo.f = 'DCTDecode';
				hInfo.data = cast data;
				break;
			}
		}
		return hInfo;
/*
		//if( a[2] != 2 )
		//	throw 'Not a JPEG file : ' + file;
		var colspace = '';
		if(!isset(a['channels']) || a['channels'] == 3)
			colspace = 'DeviceRGB';
		else if(a['channels'] == 4)
			colspace = 'DeviceCMYK';
		else
			colspace = 'DeviceGray';
		var bpc = isset(a['bits']) ? a['bits'] : 8;

		//Read whole file
		var f = fopen(file, 'rb');
		var data = '';
		while( !feof( f ) )
			data += fread(f, 8192);
		fclose(f);

		return array('w'=>$a[0], 'h'=>$a[1], 'cs'=>$colspace, 'bpc'=>$bpc, 'f'=>'DCTDecode', 'data'=>$data);
*/
	}

	function _parsepng(file) {  //Extract info from a PNG file
		var data = load( file );
		var len = data.length;
		if( len < 8 ) return null;

		//Check signature
		if( data.readUTFBytes(8) != ( fcc(137) + 'PNG' + fcc(13) + fcc(10) + fcc(26) + fcc(10) ) )
			throw 'Not a PNG file: ' + file;

		//Read header chunk
		data.position = 12;
		if( data.readUTFBytes( 4 ) != 'IHDR' )
			throw 'Incorrect PNG file: ' + file;

		var w = 0;
		var h = 0;
		var i = 16;
		while((cast i) < len ) {
			w = (w << 8) | data[ i++ ];
			if(i == 20) break;
		}
		while( (cast i) < len ) {
			h = (h << 8) |  data[ i++ ];
			if(i == 24) break;
		}
		var bpc = data[ i++ ];
		if( bpc > 8 ) throw '16-bit depth not supported : ' + file;

		var ct = data[ i++ ];
		var colspace = switch ct {
			case 0: 'DeviceGray';
			case 2: 'DeviceRGB';
			case 3: 'Indexed';
			default: '';
		}
		if( colspace == '' ) throw 'Alpha channel not supported : ' + file;

		if( cast ( data[ i++ ]) != 0 ) throw 'Unknown compression method : ' + file;
		if( cast ( data[ i++ ]) != 0 ) throw 'Unknown filter method : ' + file;
		if( cast ( data[ i++ ]) != 0 ) throw 'Interlacing not supported : ' + file;

		i += 4;
		var parms = '/DecodeParms <</Predictor 15 /Colors ' + (ct == 2 ? 3 : 1) + ' /BitsPerComponent ' + bpc + ' /Columns ' + w + '>>';
		//Scan chunks looking for palette, transparency and image data
		var palLength = 0;
		var pal = new BytesBuffer();
		var trns = new BytesBuffer();
		var data2 = new ByteArray();

		while( (cast i) < len ) {
			var n = 0;
			var j = i + 4;
			while( (cast i) < len ) {
				n = (n << 8) | data[ i++ ];
				if(i == j) break;
			}

			j = i + 4;
			if ( (cast j) <= len ) {
				data.position = i;
				var type = data.readUTFBytes(4 );
				i = j;
				j += n;
				if ( (cast j) <= len ) {
					data.position = i;
					var stream = new ByteArray();
					data.readBytes(stream, 0, n);
					//var count = stream.length;
					//trace( type + ' length = ' + count );
					switch type {
					case 'PLTE':  //Read palette
						palLength += stream.length;
						pal.add( cast stream );
					case 'tRNS':  //Read transparency info
						switch ct {
						case 0:
							trns.addByte( cast  stream[ 1 ] );
						case 2:
							trns.addByte( cast  stream[ 1 ] );
							trns.addByte( cast  stream[ 3 ] );
							trns.addByte( cast  stream[ 5 ] );
						default:
							for( pos in 0...stream.length )
								if( cast ( stream[ pos ]) == 0 ) {
									trns.addByte( pos );
									break;
								}
						}
					case 'IDAT':  //Read image data block
						stream.readBytes(data2);
					case 'IEND': break;
					}
					j += 4;
				}
			}
			i = j;
		}

		if( colspace == 'Indexed' && palLength == 0 )
			throw 'Missing palette in ' + file;

		var hInfo = new ImageInfo();
		hInfo.type = 'png';
		hInfo.w = w;
		hInfo.h = h;
		hInfo.cs = colspace;
		hInfo.bpc = bpc;
		hInfo.f = 'FlateDecode';
		hInfo.parms = parms;
		hInfo.pal = pal.getBytes();
		hInfo.trns = trns.getBytes();
		hInfo.data = data2;
		return hInfo;
	}

/* TODO
	function _parsegif(file) {  //Extract info from a GIF file (via PNG conversion)
		if(!function_exists('imagepng'))
			throw 'GD extension is required for GIF support';
		if(!function_exists('imagecreatefromgif'))
			throw 'GD has no GIF read support';
		$im = imagecreatefromgif(file);
		if(!im)
			throw 'Missing or incorrect image file : ' + file;
		imageinterlace(im, 0);
		$tmp = tempnam('.', 'gif');
		if(!tmp)
			throw 'Unable to create a temporary file';
		if(!imagepng(im, tmp))
			throw 'Error while saving to temporary file';
		imagedestroy(im);
		$info = _parsepng(tmp);
		unlink(tmp);
		return info;
	}
*/

	function _newobj() {  //Begin a new object
		this.n++;
		hOffsets.set( this.n, sBuffer.length );
		_out(this.n + ' 0 obj');
	}

	function _putstream(s: String) {
		_out('stream');
		_out(s);
		_out('endstream');
	}

	function _putimagestream(s: ByteArray) {
		_out('stream');
		_out(s);
		_out('endstream');
	}

	function _out(?s: ByteArray, ?text:String) {  //Add a line to the document
		if(state == 2)
			if (cast s)
				hPages.set( numPage, hPages.get( numPage ) + s + '\n' );
			else
				hPages.set( numPage, hPages.get( numPage ) + text + '\n' );

		else
		{
			if (cast text) 
			{
				sBuffer.writeUTFBytes(text + '\n');
			}
			else
			{
				sBuffer.writeBytes(s, 41);
				//sBuffer.writeBytes(s);
				sBuffer.writeUTFBytes('\n');
			}
		}
	}

	/**
	 * 
	 */
	function _putpages() {
		var nb = numPage;
		if(sAliasNbPages.length > 0) {  //Replace number of pages
			var by = Std.string( numPage );
			var n = 0;
			while( n < nb ) {
				n++;  //<- l'indice de page commence à 1
				hPages.set( n, replace( hPages.get( n ), sAliasNbPages, by ));
			}
		}
		var ptWidth: Float;
		var ptHeight: Float;
		if(sDefOrientation == 'P') {
			ptWidth = aDefPageFormat[0] * this.k;
			ptHeight = aDefPageFormat[1] * this.k;
		}
		else {
			ptWidth = aDefPageFormat[1] * this.k;
			ptHeight = aDefPageFormat[0] * this.k;
		}
		var filter = (compress) ? '/Filter /FlateDecode ' : '';
		for(n in 1...(nb + 1)) {  //Page
			_newobj();
			_out('<</Type /Page');
			_out('/Parent 1 0 R');
			if( hPageSizes.exists( n ) ) {
				var xy = hPageSizes.get( n );
				_out(sculpt('/MediaBox [0 0 %.2F %.2F]', [xy[0], xy[1]], [], []));
			}
			_out('/Resources 2 0 R');
			if(hPageLinks.exists( n )) {  //Links
				var cl = StartLink;
				var annots = cl.s1;  //'/Annots [';

				var hStartLinks = hPageLinks.get(n);
				for( lk in hStartLinks ) {
					var sLink = lk.stopLink;
					var r = lk.rect;  //<- 'r' = tableau [x, y, w, h]
					var isNumber = true;
					for( i in 0...sLink.length ) {
						if( '0123456789'.indexOf( sLink.charAt(i) ) == -1 ) {
							isNumber = false;
							break;
						}
					}
					var sRect = sculpt('%.2F %.2F %.2F %.2F', [ r.x, r.y, r.x + r.w, r.y - r.h ], [], []);
					annots += cl.s2 + sRect + cl.s3;

					if( isNumber ) {
						var link = Std.parseInt( sLink );
						var o = hStopLinks.get(link);
						var page = o.page;
						var h: Float = hPageSizes.exists( page ) ? hPageSizes.get( page )[1] : ptHeight;
						annots += sculpt(cl.s4, [h - o.y * this.k], [1 + 2 * page], []);
					}
					else  //s'il s'agit d'une URL de type 'http://' :
						annots += cl.s5 + _textstring( sLink ) + cl.s6;
				}
				_out(annots + cl.s7);
			}
			_out('/Contents ' + (this.n + 1) + ' 0 R>>');
			_out('endobj');

			//Page content
			var p = (compress) ? Compress.run( Bytes.ofString(hPages.get( n )), 9 ).toString() : hPages.get( n );

			_newobj();
			_out('<<' + filter + '/Length ' + p.length + '>>');
			_putstream(p);
			_out('endobj');
		}
		//Pages root
		hOffsets.set( 1, sBuffer.length );
		_out('1 0 obj');
		_out('<</Type /Pages');
		var kids = '/Kids [';
		for(i in 0...nb)
			kids += (3 + 2 * i) + ' 0 R ';
		_out(kids + ']');
		_out('/Count ' + nb);
		_out(sculpt('/MediaBox [0 0 %.2F %.2F]', [ptWidth, ptHeight], [], []));
		_out('>>');
		_out('endobj');
	}

	function _putfonts() {
		var nf = this.n;
		for( diff in aDiffs ) {  //Encodings
			_newobj();
			_out('<</Type /Encoding /BaseEncoding /WinAnsiEncoding /Differences [' + diff + ']>>');
			_out('endobj');
		}
/* TODO
		for( file in hFontFiles.keys() ) {  //Font file embedding
			_newobj();

			var info: FontFile = hFontFiles.get( file );
			info.n = this.n;
			//hFontFiles.set(file, info);  //<- inutile de sauvegarder ?

			var font = '';
			var f = fopen(_getfontpath() + file, 'rb', 1);
			if(!f)
				throw 'Font file not found';

			while(!feof(f))
				font += fread(f, 8192);
			fclose(f);

			var ziped = (substr(file, -2) == '.z');
			if( ! ziped && info.length2 > 0 ) {  //<- && isset(info['length2'])
				var header = font.charCodeAt(0) == 128;
				if(header) {  //Strip first binary header
					font = font.substr(6);
				}
				if(header && font.charCodeAt( info.length1 ) == 128) {  //Strip second binary header
					font = font.substr(0, info.length1 ) + font.substr( info.length1 + 6 );
				}
			}
			_out('<</Length ' + font.length);
			if(ziped)
				_out('/Filter /FlateDecode');
			_out('/Length1 ' + info.length1);
			if(isset(info.length2))
				_out('/Length2 ' + info.length2 + ' /Length3 0');
			_out('>>');
			_putstream(font);
			_out('endobj');
		}
*/
		for( fontkey in hFonts.keys()) {  //Font objects : as k=>font
			var font = hFonts.get( fontkey );
			font.n = this.n + 1;
			//hFonts.set( fontkey, font );  <- inutile de sauvegarder ?

			var type = font.type;
			var name = font.name;
			switch type {  //Standard font
			case 'core':
				_newobj();
				_out('<</Type /Font');
				_out('/BaseFont /' + name);
				_out('/Subtype /Type1');
				if(name != 'Symbol' && name != 'ZapfDingbats')
					_out('/Encoding /WinAnsiEncoding');
				_out('>>');
				_out('endobj');
/* TODO
			case 'Type1', 'TrueType':  //Additional Type1 or TrueType font
				_newobj();
				_out('<</Type /Font');
				_out('/BaseFont /' + name);
				_out('/Subtype /' + type);
				_out('/FirstChar 32 /LastChar 255');
				_out('/Widths ' + (this.n + 1) + ' 0 R');
				_out('/FontDescriptor ' + (this.n + 2) + ' 0 R');
				if( font.exists('enc') ) {  //<- TODO
					if( font.diff > 0 )  //<- indice de "aDiffs" ( à Base 1 )   if(isset(font['diff']))
						_out('/Encoding ' + (nf + font.diff) + ' 0 R');
					else
						_out('/Encoding /WinAnsiEncoding');
				}
				_out('>>');
				_out('endobj');
				//Widths
				_newobj();
				var aCharWidths = font.cw;  //$cw = &$font['cw'];
				var s = '[';
				for( i in 32...256 )
					s += aCharWidths[ i ] + ' ';  //$s += $cw[chr($i)] + ' ';
				_out(s + ']');
				_out('endobj');
				//Descriptor
				_newobj();
				var s = '<</Type /FontDescriptor /FontName /' + name;

				//foreach(font['desc'] as k=>v) s += ' /' + k + ' ' + v;
				var hDesc: Hash<String> = font.desc;  //<- 'hDesc' est-il de type 'String' ??
				for( k in hDesc.keys() ) s += ' /' + k + ' ' + hDesc.get( k );

				var file = font.file;
				if( file != '' )
					s += ' /FontFile' + (type == 'Type1' ? '' : '2') + ' ' + hFontFiles.get( file ).n + ' 0 R';
				_out(s + '>>');
				_out('endobj');
*/
			default:  //Allow for additional types
				var ok = false;
				var mtd = '_put' + type.toLowerCase();
				if( Reflect.hasField(this, mtd) ) {
					var fct = Reflect.field(this, mtd);
					if( Reflect.isFunction( fct ) ) {
						Reflect.callMethod(this, fct, [font] );
						ok = true;
					}
				}
				if(!ok)
					throw 'Unsupported font type : ' + type;
			}
		}
	}

	function _putimages() {
		var filter = (compress) ? '/Filter /FlateDecode ' : '';
		//reset( hImages ); <- mis en commentaire
		for( hInfo in hImages)  {  //<- TODO faut-il trier les keys() ?
			_newobj();

			hInfo.n = this.n;
			//hImages.set( file , hInfo );  <- inutile de sauvegarder ?

			_out('<</Type /XObject');
			_out('/Subtype /Image');
			_out('/Width ' + hInfo.w);
			_out('/Height ' + hInfo.h);
			if( hInfo.cs == 'Indexed' )
				//$this->_out('/ColorSpace [/Indexed /DeviceRGB '.( strlen($info['pal']) / 3 - 1 ).' '.($this->n+1).' 0 R]');
				_out('/ColorSpace [/Indexed /DeviceRGB ' + (hInfo.pal.length / 3 - 1) + ' ' + (this.n + 1) + ' 0 R]');  // TODO ?
			else {
				_out('/ColorSpace /' + hInfo.cs);
				if(hInfo.cs == 'DeviceCMYK')
					_out('/Decode [1 0 1 0 1 0 1 0]');
			}
			_out('/BitsPerComponent ' + hInfo.bpc);
			if( hInfo.f != '' )
				_out('/Filter /' + hInfo.f);

			if( hInfo.parms != '' )  //if( hInfo.exists( 'parms' ) )
				_out( hInfo.parms );

			if( hInfo.trns.length > 0 ) {
				var trns = '';
				var t = hInfo.trns;
				for( i in 0...t.length )
					trns += t.get(i) + ' ' + t.get(i) + ' ';

				_out('/Mask [' + trns + ']');
			}

			_out('/Length ' + hInfo.data.length + '>>');
			_putimagestream( hInfo.data);
			//unset( hImages[ file ]['data'] ); <- mis en commentaire

			_out('endobj');

			//Palette
			if(hInfo.cs == 'Indexed') {
				_newobj();
				var pal = (compress) ? Compress.run( hInfo.pal, 9 ).toString() : hInfo.pal.toString();
				_out('<<' + filter + '/Length ' + pal.length + '>>');
				_putstream( pal );
				_out('endobj');
			}
		}
	}

	function _putxobjectdict() {
		for( imgInfo in hImages )
			_out('/I' + imgInfo.i + ' ' + imgInfo.n + ' 0 R');
	}

	function _putresourcedict() {
		_out('/ProcSet [/PDF /Text /ImageB /ImageC /ImageI]');
		_out('/Font <<');
		for( fontInfo in hFonts )
			_out('/F' + fontInfo.i + ' ' + fontInfo.n + ' 0 R');
		_out('>>');
		_out('/XObject <<');
		_putxobjectdict();
		_out('>>');

		if( aGradients.length > 0 ) {
			var n = 1;
			_out('/Shading <<');
			for( grad in aGradients )
				_out('/Sh' + (n++) + ' ' + grad.id + ' 0 R');
			_out('>>');
		}
	}

	function _putresources() {
		_putfonts();
		_putimages();
		_putshaders();
		//Resource dictionary
		hOffsets.set( 2, sBuffer.length );
		_out('2 0 obj');
		_out('<<');
		_putresourcedict();
		_out('>>');
		_out('endobj');
	}

	function _putinfo() {
		_out('/Producer ' + _textstring('radPDF ' + RadPDF_VERSION));
		if(sTitle.length > 0)
			_out('/Title ' + _textstring(sTitle));
		if(sSubject.length > 0)
			_out('/Subject ' + _textstring(sSubject));
		if(sAuthor.length > 0)
			_out('/Author ' + _textstring(sAuthor));
		if(sKeywords.length > 0)
			_out('/Keywords ' + _textstring(sKeywords));
		if(sCreator.length > 0)
			_out('/Creator ' + _textstring(sCreator));
		//@date('YmdHis') = '20090131235959' ( en clair : '2009 01 31 23 59 59' )
		var d = Date.now().toString().split('-').join('').split(' ').join('').split(':').join('');
		_out('/CreationDate ' + _textstring('D:' + d ));
	}

	function _putcatalog() {
		_out('/Type /Catalog');
		_out('/Pages 1 0 R');

		switch sZoomMode {
		case 'fullpage': _out('/OpenAction [3 0 R /Fit]');
		case 'fullwidth': _out('/OpenAction [3 0 R /FitH null]');
		case 'real': _out('/OpenAction [3 0 R /XYZ null null 1]');
		case 'default': false;  //<- rien n'est écrit
		default:   //<- un chiffre en pourcentage
			_out('/OpenAction [3 0 R /XYZ null null ' + sZoomMode + ']');  //<- (this.ZoomMode / 100)
		}

		switch sLayoutMode {
		case 'single': _out('/PageLayout /SinglePage');
		case 'continuous': _out('/PageLayout /OneColumn');
		case 'two': _out('/PageLayout /TwoColumnLeft');
		}

		var s = reader.toString();
		if( s != '' ) _out( s );
	}

	function _putheader() {
		_out('%PDF-' + PDFVersion);
	}

	function _puttrailer() {
		_out('/Size ' + (this.n + 1));
		_out('/Root ' + this.n + ' 0 R');
		_out('/Info ' + (this.n - 1) + ' 0 R');
	}

	function _putshaders() {
		var f1 = 0;  //<- valeur fictive
		for( g in aGradients ) {
			var type = g.type;
			switch type {
			case gtLinear, gtRadial:
				_newobj();
				_out( g.stream );
				_out('endobj');
				f1 = this.n;
			case gtMesh:
			}

			var t = switch type { case gtLinear: 2; case gtRadial: 3; case gtMesh: 6; }
			_newobj();
			_out('<<');
			_out('/ShadingType ' + t);
			_out('/ColorSpace /DeviceRGB');

			switch type {
			case gtLinear:
				_out( sculpt( '/Coords [%.3F %.3F %.3F %.3F]', [ g.x0, g.y0, g.x1, g.y1 ], [], [] ));
				_out('/Function ' + f1 + ' 0 R');
				_out('/Extend [true true] ');
				_out('>>');
			case gtRadial:
				//x0, y0, r0, x1, y1, r1
				//at this time radius of inner circle is 0
				_out( sculpt('/Coords [%.3F %.3F 0 %.3F %.3F %.3F]', [ g.x0, g.y0, g.x1, g.y1, g.radius ], [], [] ));
				_out('/Function ' + f1 + ' 0 R');
				_out('/Extend [true true] ');
				_out('>>');
			case gtMesh:
				_out('/BitsPerCoordinate 16');
				_out('/BitsPerComponent 8');
				_out('/Decode[0 1 0 1 0 1 0 1 0 1]');
				_out('/BitsPerFlag 8');
				_out('/Length ' + g.stream.length);
				_out('>>');
				_putstream( g.stream );
			}
			_out('endobj');
			g.id = this.n;
		}
	}

	function _enddoc() {
		_putheader();
		_putpages();
		_putresources();
		//Info
		_newobj();
		_out('<<');
		_putinfo();
		_out('>>');
		_out('endobj');
		//Catalog
		_newobj();
		_out('<<');
		_putcatalog();
		_out('>>');
		_out('endobj');
		//Cross-ref
		var len = sBuffer.length;
		_out('xref');
		_out('0 ' + (this.n + 1));
		_out('0000000000 65535 f ');
		for( i in 1...(this.n + 1) ) {
			var seek: Int = hOffsets.get( i );
			_out( sculpt('%010d 00000 n ', [], [seek], []) );
		}
		//Trailer
		_out('trailer');
		_out('<<');
		_puttrailer();
		_out('>>');
		_out('startxref');
		_out( Std.string(len) );
		_out('%%EOF');
		state = 3;
	}

	function sculpt(fmt: String, aFloats: Array<Float>, aInts: Array<Int>, aStrings: Array<String>):String {
		var count = aFloats.length;
		if( count > 0 ) {
			var a = fmt.split('%.2F');
			if( a.length == (count + 1) ) {
				for( i in 0...count ) {
					var val = Std.int( aFloats[i] * 100 ) / 100;
					a[i] += Std.string( val );
				}
				fmt = a.join('');
			}
			a = fmt.split('%.3F');
			if( a.length == (count + 1) ) {
				for( i in 0...count ) {
					var val = Std.int( aFloats[i] * 1000 ) / 1000;
					a[i] += Std.string( val );
				}
				fmt = a.join('');
			}
		}
		count = aInts.length;
		if( count > 0 ) {
			var a = fmt.split('%d');
			if( a.length == (count + 1) ) {
				for( i in 0...count ) {
					a[i] += Std.string( aInts[i] );
				}
				fmt = a.join('');
			}
			var a = fmt.split('%010d');
			if( a.length == (count + 1) ) {
				for( i in 0...count ) {
					var sNum = Std.string( aInts[i] );
					while( sNum.length < 10 )
						sNum = '0' + sNum;
					a[i] += sNum;
				}
				fmt = a.join('');
			}
		}
		count = aStrings.length;
		if( count > 0 ) {
			var a = fmt.split('%s');
			if( a.length == (count + 1) ) {
				for( i in 0...count ) {
					a[i] += aStrings[i];
				}
				fmt = a.join('');
			}
		}
		return fmt;
	}
	
	function addImageData(?file:String, hInfo:ImageInfo, ?x: Float = null, ?y: Float = null):Void 
	{
		if (cast file)
			hImages.set( file, hInfo );
		//Automatic width and height calculation if needed
		var ww = hInfo.w;
		var hh = hInfo.h;
		if(w <= 0.0 && h <= 0.0) {  //Put image at 72 dpi
			w = ww / this.k;
			h = hh / this.k;
		}
		else if(w <= 0.0)
			w = h * ww / hh;
		else if(h <= 0.0)
			h = w * hh / ww;
	
		//Flowing mode
		if(y == null) {
			if(this.y + h > fPageBreakTrigger && !bInHeader && !bInFooter && acceptPageBreak()) {  //Automatic page break
				var x2 = this.x;
				addPage(sCurOrientation, aCurPageFormat);
				this.x = x2;
			}
			y = this.y;
			this.y += h;
		}
		if(x == null)
			x = this.x;
		_out(sculpt('q %.2F 0 0 %.2F %.2F %.2F cm /I%d Do Q', [w * this.k, h * this.k, x * this.k, (this.h - (y + h)) * this.k], [hInfo.i], []));
		if( isLink( link ) )
			this.link(x, y, w, h, link);
	}
}  //End of class FPDF

/* <- mis en commentaire
	//Handle special IE contype request
	if(isset($_SERVER['HTTP_USER_AGENT']) && $_SERVER['HTTP_USER_AGENT'] == 'contype') {
		header('Content-Type: application/pdf');
		exit;
	}
*/

private class Reader {
	var fs: Bool;
	var hReader: Hash<Bool>;  //Etats du 'Reader'

	public function new() {
		fs = false;
		hReader = new Hash();
	}
	/**
	* 
	*/ 
	public function fullScreen( ?b = true ) {
		fs = b;
	}
	public function hideMenubar( ?b = true ) {
		hReader.set( 'HideMenubar', b );
	}
	public function hideToolbar( ?b = true ) {
		hReader.set( 'HideToolbar', b );
	}
	public function hideWindowUI( ?b = true ) {
		hReader.set( 'HideWindowUI', b );
	}
	public function displayDocTitle( ?b = true ) {
		hReader.set( 'DisplayDocTitle', b );
	}
	public function centerWindow( ?b = true ) {
		hReader.set( 'CenterWindow', b );
	}
	public function fitWindow( ?b = true ) {
		hReader.set( 'FitWindow', b );
	}
	public function toString() {
		var s1 = ( fs ) ? '/PageMode /FullScreen' : '';

		var aReader = new Array<String>();
		for( k in hReader.keys() ) aReader.push( k );
		aReader.sort( increasing );
		var s2 = '';
		for( view in aReader ) {
			if( hReader.get( view ) )
				s2 += ' /' + view + ' true';
		}
		if( s2 != '' ) {
			s2 = '/ViewerPreferences<<' + s2 + ' >>';
			if( s1 != '' ) s1 += '\n';
		}
		return s1 + s2;
	}
	function increasing(s1: String, s2: String) { return if( s1.toLowerCase() > s2.toLowerCase() ) 1 else -1; }
}

private class StopLink {
	public var page: Int;
	public var y: Float;
	public function new( ?pg = 0, ?y = 0.0 ) {
		page = pg;
		this.y = y;
	}
}
private class StartLink {
	public static inline var s1 = '/Annots [';
	public static inline var s2 = '<</Type /Annot /Subtype /Link /Rect [';
	public static inline var s3 = '] /Border [0 0 0] ';
	public static inline var s4 = '/Dest [%d 0 R /XYZ 0 %.2F null]>>';  //<- si stopLink est 'numLink'
	public static inline var s5 = '/A <</S /URI /URI ';  //<- si stopLink est une URL
	public static inline var s6 = '>>>>';
	public static inline var s7 = ']';

	public var stopLink: String;  //<- soit "4 chiffres", soit une "URL"
	public var rect: LinkRect;

	public function new( lk: String, r: LinkRect ) {
		stopLink = lk;
		rect = r;
	}
}
private class LinkRect {
	public var x: Float;
	public var y: Float;
	public var w: Float;
	public var h: Float;
	public function new( x: Float, y: Float, w: Float, h: Float ) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
}
private class FontInfo {
	//pour les polices 'core' :
	public var i: Int;  //<- numéro d'ordre des polices utilisées dans le document PDF
	public var n: Int;
	public var type: String;  //'core', 'TrueType', 'Type1', ...
	public var name: String;  //'courier', ...
	public var up: Float;  //<- quel type : Int ou Float ?
	public var ut: Float;  //<- quel type ?
	public var cw: Array<Int>;  //<- charWidths ( 0...255 )

	//TODO pour les polices rajoutées : TrueType1, Type1, ...
	public var file: String;  //<- nom du fichier sur disque
	public var desc: Hash<String>;  //description <- quel type ?
	public var enc: String;  //<- quel type ?
	public var diff: Int;  //<- indice du tableau 'aDiffs'

	public function new() {
		i = -1;
		n = -1;
		type = '';
		name = '';
		up = -100.0;
		ut = 50.0;
		cw = new Array();

		file = '';
		desc = new Hash();
		enc = '';  //'cp1252'
		diff = 0;  //<- '0' si Base_1 ( et '-1' si Base_0 )
	}
}
private class FontFile {
	public var n: Int;
	public var length1: Int;
	public var length2: Int;

	public function new() {
		n = -1;
		length1 = 0;
		length2 = 0;
	}
}
class ImageInfo {
	public var i:     Int;     //<- numéro d'ordre des images utilisées dans le document PDF
	public var n:     Int;     //<- 
	public var type:  String;  //'jpg', 'png', ...
	public var w:     Float;   //<- largeur
	public var h:     Float;   //<- hauteur
	public var cs:    String;  //<- colorSpace : 
	public var bpc:   Int;     //<- BitsPerComponent
	public var f:     String;  //<- Filter : 'DCTDecode', 'FlateDecode', ...

	public var parms: String;
	public var pal:   Bytes;  //<- palette de couleurs
	public var trns:  Bytes;  //<- transparence
	public var data:  ByteArray;  //<- données d'image

	public function new( ?len = 0 ) {
		i = -1;
		n = -1;
		type = '';
		w = -1.0;
		h = -1.0;
		cs = '';  //<- 'Indexed', 'DeviceCMYK', ...
		bpc = -1;
		f = '';  //<- 

		parms = '';  //<- 
		pal = Bytes.alloc(0);   //<- palette de couleurs
		trns = Bytes.alloc(0);  //<- transparence

		if( len < 0 ) len = 0;
		data = new ByteArray();
	}
}

enum GradiantType {
	gtLinear;
	gtRadial;
	gtMesh;
}

private class Gradient {
	public var id: Int;
	public var type(default, null): GradiantType;

	static var minValue = 0.0;
	static var maxValue = 1.0;
	public var x0: Float;
	public var y0: Float;
	public var x1: Float;
	public var y1: Float;
	public var radius: Float;

	public var stream: String;

	public function new( gType: GradiantType, ?twoColors: Array<Int>, ?twoXY: Array<Float>, ?radius: Float ) {
		var aXY: Array<Float> = [];
		id = 0;  //<- valeur fictive ( numéro d'objet 'this.n' )
		type = gType;
		this.radius = 1.0;

		switch type {
		case gtLinear:  // 2;
			aXY = [ 0.0, 0, 1, 0 ];
		case gtRadial:  // 3;
			aXY = [ 0.5, 0.5, 0.5, 0.5 ];
			if( radius == null || radius < 0 )
				radius = 1.0;
			this.radius = radius;
		case gtMesh:  // 6;
			stream = '';
		}

		switch type {
		case gtLinear, gtRadial:
			if( twoColors == null ) twoColors = [];
			if( twoXY == null ) twoXY = [];

			stream =
				'<<\n' +
				'/FunctionType 2\n' +
				'/Domain [0.0 1.0]\n';  //<- minValue et maxValue ?
			var top = 2;
			var len = twoColors.length;
			for( i in 0...top ) {
				var c =
					if( i < len ) twoColors[ i ]
					else (Std.random(256) << 16) | (Std.random(256) << 8) | Std.random(256);

				stream += '/C' + i + '[';
				var shr = 16;  //sculpt( '%.3F %.3F %.3F', [ r, g, b ], [], [] );
				while( shr >= 0 ) {
					stream += ' ' + Std.int( ( (c >> shr) & 0xFF ) / 255 * 1000 ) / 1000;
					shr -= 8;
				}
				stream += ']\n';
			}
			stream +=
				'/N 1\n' +
				'>>';

			top = 4;
			len = twoXY.length;
			for( i in 0...top )
				if( i < len ) {
					var x = twoXY[ i ];
					if( x < minValue )
						x = minValue;
					else if( x > maxValue )
						x = maxValue;
					else x += 0.0;
					aXY[ i ] = x;
				}
			x0 = aXY[ 0 ];
			y0 = aXY[ 1 ];
			x1 = aXY[ 2 ];
			y1 = aXY[ 3 ];
		case gtMesh:
		}
	}
}

private class GradientPatch {
	static var aPTS = [ 0.0, 0, 0.33, 0, 0.67, 0, 1, 0, 1, 0.33, 1, 0.67, 1, 1, 0.67, 1, 0.33, 1, 0, 1, 0, 0.67, 0, 0.33 ];
	public static var minValue = 0.0;
	public static var maxValue = 1.0;

	public var f: Int;
	public var colors: Array<Int>;  //<- 4 ou 2 couleurs
	public var points: Array<Float>;  //<- 12 ou 8 coordonnées X-Y

	public function new( edge: Int, ?fourColors: Array<Int>, ?twelveXY: Array<Float> ) {
		if( fourColors == null ) {
			fourColors = [];
			var topColors = 4;  //( edge == 0 ) ? 4 : 2;
			while( topColors-- > 0 )
				fourColors.push( rgb() );
		}
		if( twelveXY == null ) {
			//var topPoints = ( edge == 0 ) ? 24 : 16;
			twelveXY = aPTS;  //.slice( 0, topPoints );
		}

		//les paramètres 'edge', 'fourColors' et 'twelveXY' sont testés en amont
		f = edge;
		colors = fourColors;  //<- bottomLeft- bottomRight- TopRight- TopLeft-Color
		points = twelveXY;
	}
	function rgb() {
		var r = Std.random( 256 ) << 16;
		var g = Std.random( 256 ) << 8;
		var b = Std.random( 256 );
		return ( r | g | b );
	}
}
