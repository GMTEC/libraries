package util;

/**
* @author GM
*/

import flash.utils.ByteArray;
import StringTools;

class HexDump
{
	static public function dumpString(buffer : String) : String
	{
		var out:ByteArray;

		out = new ByteArray();
		out.writeUTFBytes(buffer);

		return dump(out);
	}

	static public function dump(buffer : ByteArray) : String
	{
		var out : String = fillUp("\nOffset  ", 8, " ") + "  00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F \n";
		var offset : Int = 0;
		var l : Int = buffer.length;
		var row : String = "";
		buffer.position = 0;
		var i : Int = 0;
	
		while(i < l)
		{
			row += fillUp(Std.string(offset).toUpperCase(), 8, "0") + "  ";
			var n : Int;
			
			if (buffer.length - buffer.position > 16)
				n = 16;
			else
				n = buffer.length - buffer.position;
	
			var string : String = "";
			var j : Int = 0;
		
			while(j < 16)
			{
				if(j < n) 
				{
					var value : Int = buffer.readUnsignedByte();
					string += value >= (32) ? String.fromCharCode(value) : ".";
					var str:String = StringTools.hex(value, 2);
					
					row += fillUp(str.toUpperCase(), 2, "0") + " ";
					offset++;
				}

				else 
				{
					row += "   ";
					string += " ";
				}

				++j;
			}

			row += " " + string + "\n";
			i += 15;
		}

		out += row;
		out += "Lenght: " + l;
		return out;
	}

	static function fillUp(value : String, count : Int, fillWith : String) : String
	{
		var l : Int = count - value.length;
		var ret : String = "";
		while(--l > -1)ret += fillWith;
		return ret + value;
	}
}
