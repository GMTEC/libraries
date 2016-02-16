/**
* ...

* @author GM

*/
package util.plot;

class GraphXYZ
{
	public var X 		: Int;
	public var Y 		: Int;
	public var Z 		: Float;
	public var event 	: Int;

	public function new(x : Int, y : Int, z : Float, ev:Int = 0)
	{
		X = x;
		Y = y;
		Z = z;
		event = ev;
	}

}

