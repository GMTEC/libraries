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
class URLMail extends EventDispatcher
{
	public function new() 
	{
		super();

		//Création des variables à passer dans l'URL
		var vars:URLVariables = new URLVariables();
		var req:URLRequest = new URLRequest();
		vars.to 			= "guymenten@yahoo.com";
		vars.subject 		= "Test de Message";
		vars.message 		= "Ceci est mon message";
		vars.from 			= "Porte 22";

		var url:URLRequest = new URLRequest("http://www.gmtec.be/guy/scriptsmxt/mailmxt.php"); //URL du fichier PHP
		url.method = URLRequestMethod.POST; //Définit la méthode d'envoi des variables dans l'URL (POST ou GET)
		url.data = vars; //On intégre les variables dans l'URL (en POST)

		var loader:URLLoader = new URLLoader();
		loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		loader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(evt:Object):Void{handleError(evt,"SecurityErrorEvent.SECURITY_ERROR");});
		loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(evt:Object):Void{handleError(evt,"HTTPStatusEvent.HTTP_STATUS");});
	
		loader.load(url);		

		//var request:URLRequest = new URLRequest("mailto:guymenten@yahoo.com ?subject=Test Email&body=<h1>Test Body</h1>");request.contentType = "multipart/form-data";  
		//navigateToURL(request, "_self");
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