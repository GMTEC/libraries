package util;

import flash.utils.ByteArray;
import flash.utils.RegExp;

/**
 * ...
 * @author GM
 */

/**
 * 
 */
class VCardImport
{
	var cardArray:Array<String>;

	public function new()
	{
	}

	/**
	 * 
	 */
	public function importVCardFromFile()
	{
		var file:FileBase = new FileBase();
		file.readApplicationDirectoryFile("contacts.vcf");
		cardArray = file.fileData.split("END:VCARD");

		for (contact in cardArray)
		{
			contact  += "END:VCARD";
			Session.dbContacts.addContact(contact, VCardReader.ParseText(contact).pop().uid);
		}
	}
}