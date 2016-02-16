package ;

import FileBase;
import flash.filesystem.File;

/**
 * ...
 * @author GM
 */
class Language
{
	public var Label:String;
}

class FileStrings extends FileBase
{
	var LanguageNumber:Int = 0;
	public var LanguagesEnabledNumber:Int = 0;
	var indexLanguageSelected:UInt = 0; // English by Default
	var stringArray:Array<String>;
	var textsArray:Array<String>;

	/**
	 * Constructor
	 */
	public function new()
	{
		dpLanguages = new Array();
		readApplicationDirectoryFile("Strings.txt");
	}	
	
	override function readFile():Bool
	{
		super.readFile();
		stringArray = fileData.split("\r\n");
		//getLanguages();

		return true;
	}

	/**
	 *
	 * @param	idLang
	 */
	public function setLanguage(strLang:String):Void
	{
		for (i in 0 ... dpLanguages.length - 1)
		{
			if (dpLanguages[i] != null && dpLanguages[i].Label == strLang)
				indexLanguageSelected = i;
		}
	}

	/**
	 * Get the String in the current Language
	 * @param	idsString
	 * @return
	 */
	public function loadString(idsString:String):String
	{
		return loadStringForLang(idsString, indexLanguageSelected);
	}

	/**
	 * Scan the Translation file too get the available and enabled languages
	 */
	//public function getLanguages():Void
	//{
		//var languageIndex:Int = 0;
		//var languageSequence:Int = 0;
		//_LanguageNumber = 0;
		//_LanguagesEnabledNumber = 0;
		//
		//for (i in 0 ... stringArray.length - 1)
		//{
			//if (stringArray[i].indexOf("IDLS_LANGUAGE_") >= 0)
			//{
				//languageIndex++;
				//textsArray = stringArray[i].split('|,|');
				//languageSequence = textsArray[1] - 1;
				//
				//if (textsArray[1] != '0')
				//{
					//dpLanguages[_LanguageNumber] = {Language: textsArray[0], Label: String(textsArray[languageIndex + 1]), Index: languageIndex}; // + 2 Offset due to the 1 o 0 value for enabling/Disabling the language
					//_LanguagesEnabledNumber++;
				//}
				//_LanguageNumber++;
			//}
		//}
	//}
	
	/**
	 * Get the String in the current Language
	 * @param	idsString
	 * @return
	 */
	public function loadStringForLang(idsString:String, langID:UInt):String
	{
		for (i in 0 ... stringArray.length - 1)
		{
			textsArray = stringArray[i].split('|,|');
			
			if (textsArray[0] == idsString)
				return getStringOrDefault(langID);
		}
		
		return "";
	}
	
	/**
	 *
	 */
	private function getStringOrDefault(langID:UInt):String
	{
		if (textsArray[langID + 1] == null || textsArray[langID + 1] == "")
			langID = 0; // Default is English
		
		return textsArray[langID + 1];
	}
}