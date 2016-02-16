package util;

import flash.utils.ByteArray;
import flash.utils.RegExp;
import org.aswing.util.StringUtils;

/**
 * ...
 * @author GM
 */
class VCard
{
	public var vCard:String;
	public var fullName:String;
	public var orgs:Array<String>;
	public var title:String;
	public var image:ByteArray;
	public var phones:Array<Phone>;
	public var emails:Array<Email>;
	public var addresses:Array<Address>;
	public var uid:String;

	public function new()
	{
		orgs = new Array();
		phones = new Array();
		emails = new Array();
		addresses = new Array();
	}

	public function getFullName():String
	{
		return fullName;
	}

	public function getPhone():String
	{
		return (cast phones[0]) ? phones[0].number : "";
	}

	public function getAddress():String
	{	
		return (cast addresses[0]) ? addresses[0].city : "";
	}

	public function getOrganization():String
	{
		return (cast orgs[0]) ? orgs[0] : "";
	}
}
	

class Address
{
	public var type:String;
	public var street:String;
	public var city:String;
	public var state:String;
	public var postalCode:String;
	
	public function toString():String
	{
		return (street + " " + city + ", " + state + " " + postalCode);
	}
	public function new()
	{
	}
}

/**
 * 
 */
class Email
{
	public var type:String;
	public var address:String;
	public function new()
	{
	}
}
/**
 * 
 */
class Phone
{
	public var type:String;
	public var number:String;

	public function new()
	{
	}
}

/**
 * 
 */
class VCardReader
{
	public function new()
	{
	}

	/**
	 * 
	 * @param	str
	 * @param	len
	 * @return
	 */
	static function getSubString(strIn:String, len:Int):String
	{
		var str = strIn.substring(len, strIn.length);
		str = StringUtils.replace(str, "\'", "");
		str = StringUtils.replace(str, "\r", "");
		
		return str;
	}

	/**
	 * 
	 * @param	vCardText
	 * @return
	 */
	public static function ParseText(vCardText:String):Array<VCard>
	{
		var vcards:Array<VCard> = new Array<VCard>();
		var lines:Array<String> = vCardText.split('\n');
		var vcard:VCard = new VCard();
		var type:String;
		var typeTmp:String;
		var line:String;
		var addressTokens:Array<String> = new Array<String> ();
		var addressToken:String = new String("");
		var addressType:String = new String("");

		for (i in 0 ... lines.length)
		{
			line = StringUtils.replace(lines[i], "\r", "");

			if (line == "BEGIN:VCARD")
			{
				vcard = new VCard();
			}
			else if (line == "END:VCARD")
			{
				if (vcard != null)
				{
					vcards.push(vcard);
				}
			}
			else if(line.indexOf('ORG') != -1)
			{
				var org:String = line.substring(4, line.length);
				var orgArray:Array<String>= org.split(";");
				for (orgToken in orgArray)
				{
					if (StringUtils.trim(orgToken).length > 0)
					{
						vcard.orgs.push(orgToken);
					}
				}
			}
			else if(line.indexOf('TITLE') != -1)
			{
				vcard.title = line.substring(6, line.length);
			}
			else if(line.indexOf('UID') != -1)
			{
				vcard.uid =  getSubString(line, 4);
			}
			else if (line.indexOf('FN:') != -1)
			{
				vcard.fullName =  getSubString(line, 3);
			}
			else if (line.indexOf('TEL') != -1)
			{
				type = new String("");
				typeTmp = new String("");
				var phone:Phone = new Phone();
				var number:String = "";
				var phoneTokens:Array<String> = line.split(";");

				for (phoneToken in phoneTokens)
				{
					if (phoneToken.indexOf('TYPE=') != -1)
					{
						if (phoneToken.indexOf(":") != -1)
						{
							typeTmp = phoneToken.substring(5, phoneToken.indexOf(":"));
							number = phoneToken.substring(phoneToken.indexOf(":")+1, phoneToken.length);
						}
						else
						{									
							typeTmp = phoneToken.substring(5, phoneToken.length);
						}

						//typeTmp = typeTmp.toLocaleLowerCase();

						if (typeTmp == "pref")
						{
							continue;
						}
						if (type.length != 0)
						{
							type += (" ");
						}
						type += typeTmp;
					}
				}
				if (type.length > 0 && number != null)
				{
					phone.type = type;
					phone.number = number;
				}
				vcard.phones.push(phone);
			}
			else if (line.indexOf('EMAIL') != -1)
			{
				type = new String("");
				typeTmp = new String("");
				var email:Email = new Email();
				var emailAddress:String = "";
				var emailTokens:Array<String> = line.split(";");
				for (emailToken in emailTokens)
				{
					if (emailToken.indexOf('TYPE=') != -1)
					{
						if (emailToken.indexOf(":") != -1)
						{
							typeTmp = emailToken.substring(5, emailToken.indexOf(":"));
							emailAddress = emailToken.substring(emailToken.indexOf(":")+1, emailToken.length);
						}
						else
						{									
							typeTmp = emailToken.substring(5, emailToken.length);
						}

						//typeTmp = typeTmp.toLocaleLowerCase();

						if (typeTmp == "pref" || typeTmp == "internet")
						{
							continue;
						}
						if (type.length != 0)
						{
							type += (" ");
						}
						type += typeTmp;
					}
				}
				if (type.length > 0 && emailAddress != null)
				{
					email.type = type;
					email.address = emailAddress;
				}
				vcard.emails.push(email);
			}
			else if (line.indexOf("ADR;") != -1)
			{
				addressTokens = line.split(";");
				var address:Address = new Address();
				for (j in 1 ... addressTokens.length)
				{
					addressToken = addressTokens[j];
					if (addressToken.indexOf('HOME:+$') != -1) // For Outlook, which uses non-standard vCards.
					{
						address.type = "HOME";
					}
					else if (addressToken.indexOf('HOME:+$') != -1) // For Outlook, which uses non-standard vCards.
					{
						address.type = "HOME";
					}
					if (addressToken.indexOf('TYPE=') != -1)  // The "type" parameter is the standard way (which Address Book uses)
					{
						// First, remove the optional ":" character.
						addressToken	= StringUtils.replace(addressToken,':',"");
						addressType		= addressToken.substring(5, addressToken.length);
						//.toLowerCase();
						trace(addressToken);
						if (addressType == "pref") // Not interested in which one is preferred.
						{
							continue;
						}
						else if (addressType.indexOf("home") != -1) // home
						{
							addressType = "home";
						}
						else if (addressType.indexOf("work") != -1) // work
						{
							addressType = "work";
						}
						else if (addressType.indexOf(",") != -1) // if the comma technique is used, just use the first one
						{
							var typeTokens:Array<String> = addressType.split(",");
							for (typeToken in typeTokens)
							{
								if (typeToken != "pref")
								{
									addressType = typeToken;
									break;
								}
							}
						}
						address.type = addressType;
					}
					//else if (addressToken.indexOf('\n') != -1 && address.street == null)
					else if (address.street == null)
					{
						address.street 		= addressTokens[j+2];
						address.city 		= addressTokens[j+3];
						address.postalCode 	= addressTokens[j+4];
						address.state 		= addressTokens[j+5];
						if (address.type != null && address.street != null)
						{
							vcard.addresses.push(address);
						}
					}
				}
			}
			else if (line.indexOf('PHOTO') != -1)
			{
				var imageStr:String = new String("");
				for (k in i+1 ... lines.length-1)
				{
					imageStr += lines[k];
					//if (lines[k].indexOf(/.+\=$/) != -1) // Very slow in Mac due to RegEx bug
					if (lines[k].indexOf('=') != -1)
					{
						//var decoder: = new Base64Decoder();
						//decoder.decode(imageStr);
						//vcard.image = decoder.flush();
						//break;
					}
				}
			}
		}
		return vcards;
	}
}