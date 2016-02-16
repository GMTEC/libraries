package;

import Array;
import flash.filesystem.*;
import flash.net.FileFilter;

/**
 * ...
 * @author GM
 */
class FileBase
{
	//var dataArray:Array;
	var file:File;
	var fileName:String;
	public var fileData:String;

	public function new():Void
	{
	}

	/**
	 *
	 */
	function readFile():Bool
	{
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.READ);
		fileData = stream.readUTFBytes(stream.bytesAvailable);
		stream.close();
		
		return fileData.length != 0;
	}

	/**
	 *
	 * @param	strFile
	 */
	public function readApplicationDirectoryFile(strFile:String):Void
	{
		fileName = strFile;
		file = File.applicationDirectory.resolvePath(strFile);
		readFile();
	}
	/**
	 * 
	 * @param	string
	 */
	public function readApplicationStorageDirectoryFile(strFile:String):Void
	{
		fileName = strFile;
		file = File.applicationStorageDirectory.resolvePath(fileName);
		readFile();
	}

}