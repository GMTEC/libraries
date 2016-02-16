package util;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.Vector;

class PerspectiveImage {
	/**
	 * @author zeh
	 */
	static public function drawPlane(graphics:Graphics, bitmap:BitmapData, p1:Point, p2:Point, p3:Point, p4:Point) : Void {
		var pc:Point = getIntersection(p1, p4, p2, p3); // Central point
 
		// If no intersection between two diagonals, doesn't draw anything
		if (pc == null) return;
 
		// Lengths of first diagonal
		var ll1:Float = Point.distance(p1, pc);
		var ll2:Float = Point.distance(pc, p4);
 
		// Lengths of second diagonal
		var lr1:Float = Point.distance(p2, pc);
		var lr2:Float = Point.distance(pc, p3);
 
		// Ratio between diagonals
		var f:Float = (ll1 + ll2) / (lr1 + lr2);
 
		// Draws the triangle
		graphics.clear();
		graphics.beginBitmapFill(bitmap, null, false, true);
 
		graphics.drawTriangles(
			Vector.ofArray([p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y]),
			Vector.ofArray([0,1,2, 1,3,2]),
			Vector.ofArray([0,0,(1/ll2)*f, 1,0,(1/lr2), 0,1,(1/lr1), 1,1,(1/ll1)*f]) // Magic
		);
	}
 
	static private function getIntersection(p1:Point, p2:Point, p3:Point, p4:Point): Point {
		// Returns a point containing the intersection between two lines
		// http://keith-hair.net/blog/2008/08/04/find-intersection-point-of-two-lines-in-as3/
		// http://www.gamedev.pastebin.com/f49a054c1
 
		var a1:Float = p2.y - p1.y;
		var b1:Float = p1.x - p2.x;
		var a2:Float = p4.y - p3.y;
		var b2:Float = p3.x - p4.x;
 
		var denom:Float = a1 * b2 - a2 * b1;
		if (denom == 0) return null;
 
		var c1:Float = p2.x * p1.y - p1.x * p2.y;
		var c2:Float = p4.x * p3.y - p3.x * p4.y;
 
		var p:Point = new Point((b1 * c2 - b2 * c1)/denom, (a2 * c1 - a1 * c2)/denom);
 
		if (Point.distance(p, p2) > Point.distance(p1, p2)) return null;
		if (Point.distance(p, p1) > Point.distance(p1, p2)) return null;
		if (Point.distance(p, p4) > Point.distance(p3, p4)) return null;
		if (Point.distance(p, p3) > Point.distance(p3, p4)) return null;
 
		return p;
	}
}