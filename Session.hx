package;

import db.DBCameras;
import db.DBSounds;
import flash.events.EventDispatcher;
import db.DBDefaults;
import db.DBLog;
import db.DBTranslations;
import db.DBConfigWidgets;
import widgets.WSound;

import db.DBUsers;

import flash.events.Event;
import events.PanelEvents;
import sound.Sounds;
import error.Errors;

import enums.Enums;

import util.Filters;
import flash.Lib;
import util.Images;
import flash.desktop.NativeApplication;

/**
 * ...
 * @author GM
 */

class Session extends EventDispatcher
{
	var errors:Errors;
	var images:Images;

	static var sounds:Sounds;
	public static var soundsWidget:WSound;
	static var defaultParameters:DefaultParameters;

	public static var dbConfigWidgets:DBConfigWidgets;

	public static var dbDefaults:DBDefaults;
	public static var dbTableLog:DBLog;
	public static var dbSounds:DBSounds;
	public static var translations:DBTranslations;
	public static var tableUsers:DBUsers;

	public static var currentUser:User;
	static public var bTestMode:Bool;
	static public var demoMode:Bool;
	static public var ScaleX:Float = 2.4;
	static public var ScaleY:Float = 2.4;
	static public var priviledgeAdmin:Bool = cast -1;
	static public var privilegeSuperUser:Bool = cast -1;

	public function new() 
	{
		super();

		trace("Session");

		/**
		 * Databases opening: begin
		 */
		images				= new Images();
		dbTableLog 			= new DBLog();
		errors 				= new Errors();

		/**
		 * Databases opening: end
		 */

	}

	/**
	 * 
	 */
	static public function preInit() 
	{
		trace("preInit");

		dbDefaults			= new DBDefaults();
		defaultParameters	= new DefaultParameters();
		dbConfigWidgets 	= new DBConfigWidgets();

		dbSounds			= new DBSounds();
		soundsWidget 		= new WSound();
		translations		= new DBTranslations();
		Session.tableUsers	= new DBUsers();
		Session.sounds 		= new Sounds();
		var filters:Filters = new Filters();
	}

	/**
	 * 
	 */
	public function init()
	{
		trace("Session : init()");
		
	}

	/**
	 * 
	 * @param	index
	 */

	static public function getCurrentUserName() :String
	{
		return (cast currentUser) ? currentUser.name : DBDefaults.getStringParam(Parameters.paramLastUser);
	}

	/**
	 * 
	 */
	static public function checkCurrentNamePasswordOK() : Void
	{
		tableUsers.checkNamePasswordOK(getCurrentUserName(), "", true);
	}
}