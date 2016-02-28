package util;

import data.ALPRJsonData;
import events.PanelEvents;
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.utils.ByteArray;
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
	
	static var process:NativeProcess;

	/**
	 * 
	 */
	public static function startAlpr():Void 
	{
		trace("Starting ALPR : ");
		var strAppli:String = 'alpr.exe';
		var startupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		var file:File = File.applicationDirectory.resolvePath(strAppli); 
		startupInfo.executable = file;

		var cmdVec:Vector<String> = new Vector<String> ();
		cmdVec[0] = "-c";
		cmdVec[1] = "eu";
		cmdVec[2] = "-j";
		cmdVec[3] = "plate2.jpg";

		startupInfo.arguments = cmdVec;
		startupInfo.workingDirectory = File.applicationDirectory;

		process		= new NativeProcess();
		process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, outputData);
		process.addEventListener(ProgressEvent.PROGRESS, onProgress);
		process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, onErrorData);
		process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, onInputProgress);

		process.start(startupInfo); 
	}

	static private function onInputProgress(e:ProgressEvent):Void 
	{
		var ba:ByteArray = new ByteArray();
		e.currentTarget.standardError.inboundPipe.readBytes(ba);
		trace (ba);
	}

	static private function onErrorData(e:ProgressEvent):Void 
	{ 
		var ba:ByteArray = new ByteArray();
		e.currentTarget.standardError.readBytes(ba);
		trace (ba);
	}

	static private function onProgress(e:ProgressEvent):Void 
	{
		trace(e);
	}

	/**
	 * 
	 * @param	e
	 */
	private static function outputData(e:ProgressEvent):Void 
	{
		var ba:ByteArray = new ByteArray();
		e.currentTarget.standardOutput.readBytes(ba);
		//trace (ba);
		Session.alprJsonData.parse(ba.toString());
	}
}