package data;

import flash.events.EventDispatcher;
import flash.filesystem.FileStream;
import flash.net.NetworkInfo;
import flash.net.NetworkInterface;
import flash.Vector;

/**
 * ...
 * @author GM
 */

class ComputerIdChecking extends EventDispatcher
{
	var fin:FileStream;
	var macAddress:String;
	var finString:String;
	public var macArrayToCompare:Array<String>;
	public var computerMacAddresses:Array<String>;
	static var fnameLog = "Log.txt";

	public function new() 
	{
		super();

		computerMacAddresses 	= new Array<String>();
		macArrayToCompare 		= new Array<String>();
		readMacAddresses();

		//UVELIAWKS12
		addMacAddress("00", "21", "97", "C6", "53", "D7");
		//RPM-SHUTTLE-1
		addMacAddress("64", "5A", "04", "07", "2A", "4C");
		//RPM-SHUTTLE-2
		addMacAddress("64", "5A", "04", "31", "09", "1A");
		//RPM-SHUTTLE-2
		addMacAddress("00", "27", "0E", "0C", "48", "98");

		// UVELIA
		addMacAddress("80", "EE", "73", "63", "8F", "2B");

		//RPM-SHUTTLE-3
		addMacAddress("00", "27", "0E", "0C", "48", "98");
		//PC BEP
		addMacAddress("00", "27", "0E", "0C", "48", "98");
		//ATOM PB
		addMacAddress("C4", "17", "FE", "08", "0E", "7F");
		//GUY-MSI
		//addMacAddress("DC", "A9", "71", "A1", "B7", "01");
		//ACER Metrabel
		addMacAddress("CC", "AF", "78", "38", "8A", "A0");
		// METRABEl_MC700
		addMacAddress("00", "0D", "B9", "20", "40", "CC");
		//NEXT-1
		addMacAddress("DC", "0E", "A1", "B2", "13", "E1");
		// TRG-PILOT1
		addMacAddress("00", "13", "D3", "8F", "C7", "0E");
		// TRG-PILOT2
		addMacAddress("00", "13", "D3", "8F", "C2", "C0");
		// TRG-PILOT3
		addMacAddress("00", "13", "D3", "8F", "BA", "0A");
		// PCLALACCRAD1
		addMacAddress("C8", "9C", "DC", "ED", "4B", "8A");
		//HALLEMBAYE_HP
		addMacAddress("1C", "65", "9D", "54", "74", "84");
		//intraBascule
		addMacAddress("00", "0F", "FE", "A8", "F0", "B8");
		//intraBascule
		addMacAddress("00", "0F", "FE", "A8", "F0", "B8");
		// MXT-11
		addMacAddress("00", "24", "81", "0A", "44", "16");
		// MXT-10
		addMacAddress("00", "24", "81", "0A", "49", "6A");
		// RPMDemo
		addMacAddress("52", "46", "5D", "C4", "64", "35");
	}

	/**
	 * 
	 * @param	mac1
	 * @param	mac2
	 * @param	mac3
	 * @param	mac4
	 * @param	mac5
	 * @param	mac6
	 */
	public function addMacAddress( ?mac1, ?mac2, ?mac3, ?mac4, ?mac5, ?mac6) 
	{
		//if (cast address)
			//macArrayToCompare.push(address);
		//else
			macArrayToCompare.push(mac1 + '-' + mac2 + '-' + mac3 + '-' + mac4 + '-' + mac5 + '-' + mac6);
	}

	/**
	 * 
	 */
	public function checkAllIDString(): Bool
	{
		return true;
		for (macAd in macArrayToCompare)
		{
			for (locAd in computerMacAddresses)
			{
				if(macAd == locAd)
					return true;
			}
		}

		return false;
	}

	/**
	 * 
	 */
	function readMacAddresses()
	{
		var ntf:Vector<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();

		for (interfaceObj in ntf) 
		{
			if(interfaceObj.mtu != -1)
				computerMacAddresses.push(interfaceObj.hardwareAddress);
		}
	}
}