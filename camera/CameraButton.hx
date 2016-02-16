package camera;

import camera.CameraView;
import comp.ButtonMenu;
import comp.JButton2;
import db.DBDefaults;
import enums.Enums.Parameters;
import events.PanelEvents;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

/**
 * ...
 * @author GM
 */
class CameraButton extends ButtonMenu
{
	var sprite:Sprite;
	var butZoom:JButton2;
	var cameraEnabled:Bool	= false;
	var camera:camera.CameraView;

	/**
	 * 
	 * @param	name
	 * @param	xIn
	 * @param	yIn
	 * @param	wIn
	 * @param	hIn
	 * @param	text
	 * @param	bmIn
	 * @param	iconSizeIn
	 */
	public function new(name:String, xIn:Int, yIn:Int, wIn:Int, hIn:Int, text:String = "0", sprite:SpriteMenuButton = null, iconSizeIn:Int = 0, butZoomEnabled = false) 
	{
		super(name, xIn, yIn, wIn, hIn, text, sprite, null, cast iconSizeIn / 2);

		camera 		= new camera.CameraView("ID_CAMERA_BUT", sprite.sizeX, sprite.sizeY);
		camera.x 	-= 6;
		//camera.y = yIn + 4;

		sprite.addChild(camera);
		//filters = Filters.centerWinFilters;
		Main.root1.addEventListener(PanelEvents.EVT_PARAM_UPDATED, refresh);
		addEventListener(MouseEvent.CLICK, onClickCamera);
		//onClickCamera();

		if (cast butZoomEnabled)
		{
			butZoom = new JButton2(xIn + 60, yIn + 30, 20, 20, "+", onButZoom);
			addChild(butZoom);
			onButZoom();
		}

		if(!butZoomEnabled) camera.visible = true;

		refresh();
	}

	/**
	 * 
	 * @param	e
	 */
	function onButZoom(e:Event = null) 
	{
		camera.visible = cameraEnabled ? !camera.visible : false;
		if (cast butZoom) butZoom.setText(camera.visible ? "1" : "0");
	}

	/**
	 * 
	 * @param	e
	 */
	private function onClickCamera(e:MouseEvent = null):Void 
	{
		if(cameraEnabled) Main.root1.dispatchEvent(new Event(PanelEvents.EVT_BUT_CAM_ZOOM));				
	}

	/**
	 * 
	 * @param	e
	 */
	private function refresh(e:Event = null):Void 
	{
		cameraEnabled = cast DBDefaults.getIntParam(Parameters.paramCameraIndex);
		if(cast butZoom) butZoom.setEnabled(cameraEnabled);
	}
}