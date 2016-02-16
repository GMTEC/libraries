package mail;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.Object;

/**
 * ...
 * @author GM
 */
class PHPMailer extends EventDispatcher
{
	public function new() 
	{
		super();

		var vars:URLVariables 	= new URLVariables();
		var req:URLRequest 		= new URLRequest();
	
		vars.to 		= "guymenten@yahoo.com";
		vars.from 		= "contact@gmtec.be";
		vars.name 		= "Porte 22";
		vars.subject 	= "Test de Message";
		vars.reply 		= "contact@gmtec.be";
		vars.body 		= "Porte 22 en ALARME";
		vars.attachment	= "Rapport.pdf";

		var url:URLRequest 	= new URLRequest("http://www.gmtec.be/guy/scriptsmxt/phpmailermxt.php"); //URL du fichier PHP
		url.method 			= URLRequestMethod.POST; //Définit la méthode d'envoi des variables dans l'URL (POST ou GET)
		url.data 			= vars; //On intégre les variables dans l'URL (en POST)

		var loader:URLLoader = new URLLoader();
		loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(evt:Object):Void{handleError(evt,"SecurityErrorEvent.SECURITY_ERROR");});
		loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(evt:Object):Void{handleError(evt,"HTTPStatusEvent.HTTP_STATUS");});

		loader.load(url);
	}

	function handleError(evt:Object, string:String) 
	{
		trace("handleError " + string);
	}

	private function loaderCompleteHandler(e:Event):Void 
	{
		trace("loaderCompleteHandler " + e.currentTarget.data);
	}
	
	private function errorHandler(e:IOErrorEvent):Void 
	{
		trace("errorHandler " + e.currentTarget.data);
	}
}