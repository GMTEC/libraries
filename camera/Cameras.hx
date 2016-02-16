package camera;
import flash.media.Camera;
import flash.media.Video;

/**
 * ...
 * @author GM
 */
class Cameras
{
	var cameraVideos:Array<Video>;

	public function new() 
	{
		cameraVideos = new Array<Video>();
		var index:Int = 0;

		for (name in Camera.names)
		{
			createCameraView(index++);
		}
	}

	/**
	 * 
	 * @param	camNum
	 * @param	wIn
	 * @param	hIn
	 */
	function createCameraView(camNum:Int):Void 
	{
		var camera:Camera 			= Camera.getCamera(cast camNum);
		camera.setQuality(0x8000, 100);
		camera.setKeyFrameInterval(1);

		var video			= new Video();

		video.attachCamera(camera);
		video.smoothing = true;

		cameraVideos.push(video);
	}
}