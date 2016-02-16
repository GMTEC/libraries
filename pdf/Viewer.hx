package pdf;

class Viewer extends FPDF {
	static function main() {
		new Viewer();
	}

	public function new() {
		super('L', 'mm', 'A4');  //<- width = 297, height = 210
		setTopMargin( 5.0 );
		setFont( 'Courier', '', 12 );
		addPage();

		var txt = 'Reader is around this blank page.';
		var x = (297 - getStringWidth( txt )) / 2;
		text( x, 30, txt );

		setDisplayMode('fullpage');

		//reader.fullScreen();
		//reader.centerWindow();
		//reader.displayDocTitle();
		//reader.fitWindow();

		reader.hideMenubar();
		reader.hideToolbar();

		//reader.hideWindowUI();

		var pdf = Type.getClassName( Type.getClass(this) ).split('.').pop();
		output( pdf );
	}

	override function header() {
		setFont('Arial', '', 9);  //Police Arial 9
		var s = 'demonstrates : reader.hideMenubar(); reader.hideToolbar();  other functions : .centerWindow()  .displayDocTitle()  .fitWindow()  .fullScreen() .hideWindowUI()';
		cell(0, 10, s, 1, 0, 'C');  //Titre
		ln(20);  //Saut de ligne
	}
}
