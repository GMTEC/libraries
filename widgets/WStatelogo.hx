package widgets;
import enums.Enums.PanelState;
import events.PanelEvents;
import events.PanelEvents.StateMachineEvent;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import tweenx909.TweenX;
import util.PerspectiveImage;

/**
 * ...
 * @author GM
 */
class WStatelogo extends WBase
{
	var bNewlogoVisible:Bool;
	//var oldLogo:Sprite;
	//var newLogo:Sprite;
	var oldLogo:DisplayObject;
	var newLogo:DisplayObject;
	var stateMachine:PanelState;

	public function new(name:String) 
	{
		super(name);

		onStateRefresh(null);
		//newLogo = new Sprite();
		//oldLogo = new Sprite();
		//newLogo.graphics.lineStyle(1);
		//newLogo.graphics.drawRect(0, 0, 300, 300);
		//oldLogo.graphics.lineStyle(1);
		//oldLogo.graphics.drawRect(0, 0, 300, 300);
		//addChild(oldLogo);
		//addChild(newLogo);
//
		Main.root1.addEventListener(PanelEvents.EVT_PANEL_STATE, onStateRefresh);
	}

	///**
	 //* 
	 //* @param	bmData
	 //*/
	//function drawBitmap(bmData:BitmapData) 
	//{
		//var matrix 	= new Matrix();
		//matrix.translate(32, 32);
		//matrix.scale(0.64, 0.64);
	//
		//graphVal.setDrawingOnPaper();
		//bmData.draw(graphVal, matrix, false);
		//bmData.draw(graphBkG, matrix, false);
		//bmData.draw(graphTrg, matrix, false);
		//graphVal.setDrawingOnScreen();
	//}

	///**
	 //* 
	 //* @param	evt
	 //*/
	//function onStateRefresh(evt:StateMachineEvent):Void
	//{
		//if (Session.panelStateMachine.stateMachine != stateMachine)
		//{
			//stateMachine 	= Session.panelStateMachine.stateMachine;
			//var logoBitmap	= Session.panelStateMachine.getStateLogo();
//
			//var dX;
			//var dY;
//
			//if (DefaultParameters.cameraEnabled) {
				//dX = 34;
				//dY = 42;
//
				//PerspectiveImage.drawPlane(bNewlogoVisible ? oldLogo.graphics : newLogo.graphics, logoBitmap.bitmapData, new Point(dX, 0), new Point(newLogo.width - dX), new Point(0, dY), new Point(newLogo.width, dY));
			//}
			//else 
			//{
				//if (bNewlogoVisible) {
					//oldLogo.bitmapData.draw(logoBitmap);
				//}
				//else {
					//newLogo.bitmapData.draw(logoBitmap);
				//}
			//}
//
			//if(bNewlogoVisible)
				//TweenX.parallel([
					//TweenX.tweenFunc(fadeNewLogo, [1] , [0]),
					//TweenX.tweenFunc(fadeOldLogo, [0] , [1]), ]).onFinish(swapBitmaps);
			//else
				//TweenX.parallel([
					//TweenX.tweenFunc(fadeOldLogo, [1] , [0]),
					//TweenX.tweenFunc(fadeNewLogo, [0] , [1]), ]).onFinish(swapBitmaps);
//
			//bNewlogoVisible = !bNewlogoVisible;
		//}
	//}
	/**
	 * 
	 * @param	evt
	 */
	function onStateRefresh(evt:StateMachineEvent):Void
	{
		if (Session.panelStateMachine.stateMachine != stateMachine)
		{
			stateMachine 	= Session.panelStateMachine.stateMachine;
			newLogo 		= Session.panelStateMachine.getStateLogo();
			newLogo.scaleX 	= newLogo.scaleY = 180 / newLogo.width;

			newLogo.alpha = 0;
			addChild(newLogo);

			TweenX.parallel([
				TweenX.tweenFunc(fadeOldLogo, [1] , [0]),
				TweenX.tweenFunc(fadeNewLogo, [0] , [1]), ]).onFinish(swapBitmaps);
		}
	}

	/**
	 * 
	 */
	function swapBitmaps() 
	{
		if ((cast oldLogo) && isChild(oldLogo))
			removeChild(oldLogo);
		oldLogo = newLogo;
	}

	function fadeOldLogo(alpha:Float) {if (cast oldLogo) oldLogo.alpha = alpha;}
	function fadeNewLogo(alpha:Float) {newLogo.alpha = alpha;}
}