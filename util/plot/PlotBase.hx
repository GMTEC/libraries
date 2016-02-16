/**
* ...
* @author GM
*/
package util.plot;

import flash.display.Sprite;
import widgets.WBase;
 
class PlotBase extends Sprite
{
	public var filmValues : Sprite;

	var TimeMinSet : Int;
	var XMinSet : Float;
	var XMaxSet : Float;
	var startIndex : Int;
	var maxDistiVal : Int;
	var XDistriScale : Float;
	var YDistriScale : Float;
	var XDistriOffset : Float;
	var YDistriOffset : Float;
	var XDistriOrigin : Float;
	var overlayGraph : Bool;

	public function new()
	{
		super();
	
		filmValues = new Sprite();
	
		startIndex = 0;
	}

}

