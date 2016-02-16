/*_____ __  __ _______ _____  __  __       _ _           
 / ____|  \/  |__   __|  __ \|  \/  |     (_) |          
| (___ | \  / |  | |  | |__) | \  / | __ _ _| | ___ _ __ 
 \___ \| |\/| |  | |  |  ___/| |\/| |/ _` | | |/ _ \ '__|
 ____) | |  | |  | |  | |    | |  | | (_| | | |  __/ |   
|_____/|_|  |_|  |_|  |_|    |_|  |_|\__,_|_|_|\___|_|                                                    
/*
* This class lets you send rich emails with AS3 (html, attached files) through SMTP
* for more infos http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol
* @author Thibault Imbert (bytearray.org)
* @version 0.3 Added image type auto detect (PNG, JPG-JPEG)
* @version 0.4 Dispatching proper events
* @version 0.5 Handles every kind of files for attachment, few bugs fixed
* @version 0.6 Handles authentication, thank you Wein ;)
* @version 0.7 Few fixes, thank you Vicente ;)
* @version 0.8 Good fix, thank you Ben and Carlos ;)
* @version 0.9 Refactoring ;)
*/

package mail;

import flash.errors.Error;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.utils.Object;
import flash.utils.RegExp;
import flash.utils.Timer;
import haxe.io.Bytes;

import haxe.crypto.Md5;
import haxe.crypto.Base64;
import flash.events.Event;

/**
 * 
 */
class SMTPInfos
{
	public var code:Int;
	public var message:String;

	public function new(code:Int, message:String)
	{
		this.code = code;
		this.message = message;
	}
}

/**
 * 
 */
class SMTPEvent extends Event 
{
	public static var MAIL_SENT:String = "mailSent";
	public static var AUTHENTICATED:String = "authenticated";
	public static var MAIL_ERROR:String = "mailError";
	public static var BAD_SEQUENCE:String = "badSequence";
	public static var CONNECTED:String = "connected";
	public static var DISCONNECTED:String = "disconnected";
	public var result:Object;

	public function new ( pEvent:String, pInfos:Object )
	{
		super ( pEvent );
		result = pInfos;
	}
}

/**
 * 
 */
class SMTPMailer extends Socket 
{
	private var sHost:String;
	private var buffer:Array<Object>;

	// regexp pattern
	private var reg:RegExp;

	// PNG, JPEG header values
	private static var PNG:Float = 0x89504E47;
	private static var JPEG:Float = 0xFFD8;

	// common SMTP server response codes
	// other codes could be added to add fonctionalities and more events
	private static var ACTION_OK:Float = 0xFA;
	private static var AUTHENTICATED:Float = 0xEB;
	private static var DISCONNECTED:Float = 0xDD;
	private static var READY:Float = 0xDC;
	private static var DATA:Float = 0x162;
	private static var BAD_SEQUENCE:Float = 0x1F7;

	/**
	 * 
	 * @param	pHost
	 * @param	pPort
	 */
	public function new ( pHost:String, pPort:Int) 
	{
		reg = new RegExp(~/^\d{3}/img);

		super ();			
	
		sHost = pHost;
		addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		addEventListener(Event.CONNECT, onConnect);
		//addEventListener(Event.CLOSE, onClose);
		//addEventListener(IOErrorEvent.IO_ERROR, onError);
		//addEventListener(ProgressEvent.SOCKET_DATA, onResponse);
		//addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
		addEventListener(SMTPEvent.AUTHENTICATED, onAuthSuccess);
		addEventListener(SMTPEvent.BAD_SEQUENCE, onAuthFailed);
		addEventListener(SMTPEvent.CONNECTED, onSMTPConnect);
		
		connect( pHost, pPort );
	}
	
	private function onSMTPConnect(e:SMTPEvent):Void 
	{
		trace("onSMTPConnect " + e.result);
	}
	
	private function onAuthSuccess(e:SMTPEvent):Void 
	{
		trace("onAuthSuccess");
	}
	
	private function onAuthFailed(e:SMTPEvent):Void 
	{
		trace("onAuthFailed");
	}

	/**
	 * 
	 * @param	e
	 */
	private function onSecError(e:SecurityErrorEvent):Void 
	{
		trace("onSecError");
	}
	
	private function onResponse(e:ProgressEvent):Void 
	{
		trace("onResponse");
	}
	
	private function onError(e:IOErrorEvent):Void 
	{
		trace("onError");
	}
	
	private function onClose(e:Event):Void 
	{
		trace("onClose");
	}
	
	private function onConnect(e:Event):Void 
	{
		trace("onConnected ");
	}
	/*
	* This method lets you authenticate, just pass a login and password
	*/
	public function authenticate ( pLogin:String, pPass:String ):Void
	{
		writeUTFBytes ("ELO "+sHost);
		writeUTFBytes ("AUTH LOGIN " + pLogin + " " + pPass);
		//writeUTFBytes (pLogin);
		//writeUTFBytes (pPass);
		//writeUTFBytes ("ELO "+sHost+"\r\n");
		//writeUTFBytes ("AUTH LOGIN\r\n");
		//writeUTFBytes (pLogin +"\r\n");
		//writeUTFBytes (pPass + "\r\n");
		//writeUTFBytes (Base64.encode (stringToBytes( pLogin +"\r\n")));
		//writeUTFBytes (Base64.encode (stringToBytes( pPass + "\r\n")));
		flush();
	}

	/**
	 * 
	 * @param	str
	 * @return
	 */
	function stringToBytes(str:String):Bytes
	{
		var b = haxe.io.Bytes.alloc(str.length); 
		for( i in 0...str.length ) 
			b.set(i, StringTools.fastCodeAt(str, i));
			
		return b;
	}

	/*
	* This method is used to send emails with attached files and HTML 
	* takes an incoming Bytearray and convert it to base64 string
	* for instance pass a JPEG ByteArray stream to get a picture attached in the mail ;)
	*/
	public function sendAttachedMail ( pFrom:String, pDest:String, pSubject:String, pMess:String, pByteArray:ByteArray, pFileName:String ) :Void
	{
		try {

			writeUTFBytes ("HELO "+sHost+"\r\n");
			writeUTFBytes ("MAIL FROM: <"+pFrom+">\r\n");
			writeUTFBytes ("RCPT TO: <"+pDest+">\r\n");
			writeUTFBytes ("DATA\r\n");
			writeUTFBytes ("From: "+pFrom+"\r\n");
			writeUTFBytes ("To: "+pDest+"\r\n");
			writeUTFBytes ("Date : "+ Date.now().toString()+"\r\n");
			writeUTFBytes ("Subject: "+pSubject+"\r\n");
			writeUTFBytes ("Mime-Version: 1.0\r\n");
			
			var md5Boundary:String = Md5.encode ( cast ( Date.now().getTime() ) );
			
			writeUTFBytes ("Content-Type: multipart/mixed; boundary=------------"+md5Boundary+"\r\n");
			writeUTFBytes("\r\n");
			writeUTFBytes ("This is a multi-part message in MIME format.\r\n");
			writeUTFBytes ("--------------"+md5Boundary+"\r\n");
			writeUTFBytes ("Content-Type: text/html; charset=UTF-8; format=flowed\r\n");
			writeUTFBytes("\r\n");
			writeUTFBytes (pMess+"\r\n");
			writeUTFBytes ("--------------"+md5Boundary+"\r\n");
			writeUTFBytes ( readHeader (pByteArray, pFileName) );
			writeUTFBytes ("Content-Transfer-Encoding: base64\r\n");
			writeUTFBytes ("\r\n");
			
			var base64String:String = Base64.encode ( cast pByteArray, true );

			writeUTFBytes ( base64String+"\r\n");
			writeUTFBytes ("--------------"+md5Boundary+"-\r\n");
			writeUTFBytes (".\r\n");
			flush();
			
		} catch ( pError:Error )
		{
			trace("Error : Socket error, please check the sendAttachedMail() method parameters");
			//trace("Arguments : " + arguments );		
		}
	}

	/*
	* This method is used to send HTML emails
	* just pass the HTML string to pMess
	*/
	public function sendHTMLMail ( pFrom:String, pDest:String, pSubject:String, pMess:String ):Void
	{
		try 
		{			
			writeUTFBytes ("HELO "+sHost+"\r\n");
			writeUTFBytes ("MAIL FROM: <"+pFrom+">\r\n");
			writeUTFBytes ("RCPT TO: <"+pDest+">\r\n");
			writeUTFBytes ("DATA\r\n");
			writeUTFBytes ("From: "+pFrom+"\r\n");
			writeUTFBytes ("To: "+pDest+"\r\n");
			writeUTFBytes ("Subject: "+pSubject+"\r\n");
			writeUTFBytes ("Mime-Version: 1.0\r\n");
			writeUTFBytes ("Content-Type: text/html; charset=UTF-8; format=flowed\r\n");
			writeUTFBytes("\r\n");
			writeUTFBytes (pMess+"\r\n");
			writeUTFBytes (".\r\n");
			flush();
		} catch ( pError:Error )
		{	
			trace("Error : Socket error, please check the sendHTMLMail() method parameters");
			//trace("Arguments : " + arguments );	
		}
	}

	/*
	* This method automatically detects the header of the binary stream and returns appropriate headers (jpg, png)
	* classic application/octet-stream content type is added for different kind of files
	*/
	private function readHeader ( pByteArray:ByteArray, pFileName:String ):String 
	{
		pByteArray.position = 0;
		
		var sOutput:String = null;
		
		if ( pByteArray.readUnsignedInt () == SMTPMailer.PNG ) 
		{
			sOutput = "Content-Type: image/png; name="+pFileName+"\r\n";
			sOutput += "Content-Disposition: attachment filename="+pFileName+"\r\n";
			return sOutput;	
		}

		pByteArray.position = 0;

		if ( pByteArray.readUnsignedShort() == SMTPMailer.JPEG ) 
		{
			sOutput = "Content-Type: image/jpeg; name="+pFileName+"\r\n";
			sOutput += "Content-Disposition: attachment filename="+pFileName+"\r\n";
			return sOutput;	
		}

		sOutput = "Content-Type: application/octet-stream; name="+pFileName+"\r\n";
		sOutput += "Content-Disposition: attachment filename="+pFileName+"\r\n";
		
		return sOutput;
	}

	// check SMTP response and dispatch proper events
	// Keep in mind SMTP servers can have different result messages the detection can be modified to match some specific SMTP servers
	private function socketDataHandler ( pEvt:ProgressEvent ):Void
	{
		var response:String = pEvt.target.readUTFBytes ( pEvt.target.bytesAvailable );
		buffer = new Array<Object>();
		var result:Array<Dynamic> = reg.exec(response);
		
		while (result != null)
		{	
			buffer.push (result[0]);
			result = reg.exec(response);
		}
		
		var smtpReturn:Float = buffer[buffer.length-1];
		var smtpInfos:SMTPInfos = new SMTPInfos ( cast smtpReturn, response );
	
		if ( smtpReturn == SMTPMailer.READY ) 
			dispatchEvent ( new SMTPEvent ( SMTPEvent.CONNECTED, smtpInfos ) );
		
		else if ( smtpReturn == SMTPMailer.ACTION_OK && (response.toLowerCase().indexOf ("queued") != -1 || response.toLowerCase().indexOf ("accepted") != -1 ||
				response.toLowerCase().indexOf ("qp") != -1) ) dispatchEvent ( new SMTPEvent ( SMTPEvent.MAIL_SENT, smtpInfos ) );
		else if ( smtpReturn == SMTPMailer.AUTHENTICATED ) 
			dispatchEvent ( new SMTPEvent ( SMTPEvent.AUTHENTICATED, smtpInfos ) );
		else if ( smtpReturn == SMTPMailer.DISCONNECTED ) 
			dispatchEvent ( new SMTPEvent ( SMTPEvent.DISCONNECTED, smtpInfos ) );
		else if ( smtpReturn == SMTPMailer.BAD_SEQUENCE ) 
			dispatchEvent ( new SMTPEvent ( SMTPEvent.BAD_SEQUENCE, smtpInfos ) );
		else if ( smtpReturn != SMTPMailer.DATA ) 
			dispatchEvent ( new SMTPEvent ( SMTPEvent.MAIL_ERROR, smtpInfos ) );	
	}
	}