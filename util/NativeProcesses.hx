package util;

import events.PanelEvents;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.Vector;
import flash.system.FSCommand;

/**
 * ...
 * @author GM
 */
class NativeProcesses extends EventDispatcher
{
	static var started		:Bool;
	static var proxyProcess	:NativeProcess;

	public function new() 
	{
		super();


		Main.root1.addEventListener(PanelEvents.EVT_APP_EXIT, OnExit);
	}

	//function killProxy() 
	//{
		////var strAppli:String = 'taskkill /F /IM RPMProxy.exe';
		//var npsi:NativeProcessStartupInfo;
		//var nativeProcess:NativeProcess;
		//var file:File = new File("c:\\windows\\system32\\cmd.exe");
		//var args:Vector<String> = new Vector<String>();
//
		//args.push('TASKKILL');
		//args.push('/F /IM RPMProxy.exe / T');
		////args.push('www.adobe.com');
//
		//npsi = new NativeProcessStartupInfo();
		//npsi.arguments = args;
		//npsi.executable = file;
//
		//nativeProcess = new NativeProcess();
		////nativeProcess.addEventListener(ProgressEvent.PROGRESS,onStandardOutputData);
		////nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onError);
		//nativeProcess.start(npsi);
	//}

	private function OnExit(e:Event):Void 
	{
		if(cast proxyProcess)
			proxyProcess.exit(true);
	}

	/**
	 * 
	 * @return
	 */
	public static function execRPMProxy():Bool
	{
		return false;

		if (started)
			return false;

		started = true;
		var strAppli:String = 'RPMProxy.exe';
		var sh:File = File.applicationDirectory.resolvePath(strAppli);
		proxyProcess = new NativeProcess();
		var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		// let the nativeprocess know where the working directory is
		startupInfo.workingDirectory = File.applicationDirectory;
		// set the executable to your shell file
		startupInfo.executable = sh;

		var processArgs	= new Vector<String>();
		processArgs[0]	= strAppli;
		startupInfo.arguments = processArgs;
 
		// start the process!!
		proxyProcess.start(startupInfo);

		return true;
	}
}