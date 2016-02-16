package util;

import flash.display.Sprite;
import flash.geom.Matrix;
import flash.display.GradientType;
import flash.display.SpreadMethod;

/**
 * ...
 * @author GM
 */
class Gradients
{
	var matrixGradient:Matrix;
	var matrWidth:Float;
	var fillType:GradientType;
	var colors:Array<Int>;
	var alphas:Array<Dynamic>;
	var ratios:Array<Dynamic>;
	var spreadMethod:SpreadMethod;
	var X:Int;
	var Y:Int;

	/**
	 * 
	 */
	public function new(colorStart:Int,colorEnd:Int = 0xffffff, xIn:Int = 0, yIn:Int = 0) 
	{
		X = xIn;
		Y = yIn;
		matrixGradient = new Matrix();
		createGradient(colorStart, colorEnd);
	}
	
	/**
	 * 
	 */
	function createGradient(colorStart:Int, colorEnd:Int) 
	{
		fillType = GradientType.LINEAR;
		colors = [colorStart, colorEnd];
		alphas = [1, 1];
		ratios = [0, 255];
		matrWidth = 300;
		spreadMethod = SpreadMethod.REFLECT;

		matrixGradient.createGradientBox(matrWidth, 600 , Math.PI / 2, X, Y);		
	}
	
	/**
	 * 
	 */
	public function beginGradientFill(sprite:Sprite)
	{
		sprite.graphics.beginGradientFill(fillType, cast colors, alphas, ratios, matrixGradient, spreadMethod, null);		
	}
}