package pdf;

class Tuto1 extends FPDF {
	static function main() {
		new Tuto1();
	}

	public function new() {
		super('P', 'mm', [210, 100]);  //<- custom page-size
		aliasNbPages( '{nb}' );
		addPage();
		setFont( 'Courier', '', 12 );
		for( i in 1...17 )
			cell(0, 10, 'line n° ' + i, 0, 1);  //<- a 'cell' without 'border = 0' but with 'lineBreak = 1'

		setDisplayMode('fullwidth', 'continuous');
		var pdf = Type.getClassName( Type.getClass(this) ).split('.').pop();
		output( pdf );
	}

	override function header() {
		setFont('Courier', '', 8);  //<- Arial bold 8
		//Title : a 'cell' with 'border = 1' but without 'lineBreak = 0'
		cell(0, 8, 'demonstrates  a) custom page-size in mm = [ 210, 100 ]   b) function aliasNbPages()', 1, 0, 'C');
		ln(20);  //<- line-break = 20 mm height
	}

	//Pied de page
	override function footer() {
		setY( -15 );  //Position at 1,5 cm from page-bottom
		setFont('Courier','', 8);  //<- Arial italique 8
		cell(0, 10, 'page ' + pageNo() + " / {nb}   <==  here was an 'alias'  ( not an 'alien' ! )", 0, 0, 'C');  //<- page-number
	}
}
