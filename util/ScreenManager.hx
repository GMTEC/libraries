/**
 * @author GM
 * @version 1.1
 * for use with Flex and Flash in Adobe AIR
 *
 * ScreenManager
 * Make your application go multi-screen
 * Move or open windows on different screens
 */
package util;

import flash.display.NativeWindow;
import flash.display.Screen;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.geom.Rectangle;

class ScreenManager
{
	public static  var TOP_LEFT_CORNER:String = "topLeft";
	public static  var TOP_RIGHT_CORNER:String = "topRight";
	public static  var BOTTOM_LEFT_CORNER:String = "bottomLeft";
	public static  var BOTTOM_RIGHT_CORNER:String = "bottomRight";

	/**
	 * Open an instance of NativeWindow on a screen
	 * @param window Instance of a NativeWindow
	 * @param oneBasedScreenIndex index of the screen you want to add your window on, main screen=1, second screen = 2, ...
	 * @param x (optional) x value of the new window on the screen
	 * @param y (optional) y value of the new window on the screen
	 */
	public static function openWindowOnScreen(window:NativeWindow, oneBasedScreenIndex:Int, x:Int = 0, y:Int = 0):Void
	{
		var screen:Screen = Screen.screens[oneBasedScreenIndex - 1];
		
		if (((screen.bounds.left) + x) < screen.bounds.right)
		{
			window.x = (screen.bounds.left) + x;
		}
		
		if (((screen.bounds.top) + y) < screen.bounds.bottom)
		{
			window.y = (screen.bounds.top) + y;
		}

		window.activate();
	}

	/**
	 * Open an instance of NativeWindow centered on a screen
	 * @param window Instance of a NativeWindow
	 * @param oneBasedScreenIndex index of the screen you want to add your window on, main screen=1, second screen = 2, ...
	 */
	public static function openWindowCenteredOnScreen(window:NativeWindow, oneBasedScreenIndex:Int):Void
	{
		var screen:Screen = Screen.screens[oneBasedScreenIndex - 1];
		var centerX:Int = cast screen.bounds.right - screen.bounds.width + (screen.bounds.width / 2);
		var centerY:Int = cast screen.bounds.bottom - screen.bounds.height + (screen.bounds.height / 2);
		window.x = centerX - (window.width) / 2;
		window.y = centerY - (window.height) / 2;
		window.activate();
	}

	/**
	 * Open an instance of NativeWindow on a screen to the corner of a screen
	 * @param window Instance of a NativeWindow
	 * @param oneBasedScreenIndex index of the screen you want to move your window in, main screen=1, second screen = 2, ...
	 * @param corner Corner to move the window to (public statics of this class)
	 */
	public static function openWindowInCorner(window:NativeWindow, oneBasedScreenIndex:Int, corner:String):Void
	{
		moveWindowToCorner(window, oneBasedScreenIndex, corner);
		window.activate();
	}

	/**
	 * Move an instance of NativeWindow on a screen
	 * @param window Instance of a NativeWindow
	 * @param oneBasedScreenIndex index of the screen you want to move your window in, main screen=1, second screen = 2, ...
	 * @param x (optional) x value of the new window on the screen
	 * @param y (optional) y value of the new window on the screen
	 */
	public static function moveWindow(window:NativeWindow, oneBasedScreenIndex:Int, x:Float = 0, y:Float = 0):Void
	{
		var screen:Screen = Screen.screens[oneBasedScreenIndex - 1];
		if (((screen.bounds.left) + x) < screen.bounds.right)
		{
			window.x = (screen.bounds.left) + x;
		}
		
		if (((screen.bounds.top) + y) < screen.bounds.bottom)
		{
			window.y = (screen.bounds.top) + y;
		}
	}
	
	/**
	 * Move an instance of NativeWindow on a screen to the corner of a screen
	 * @param window Instance of a NativeWindow
	 * @param oneBasedScreenIndex index of the screen you want to move your window in, main screen=1, second screen = 2, ...
	 * @param corner Corner to move the window to (public statics of this class)
	 */
	public static function moveWindowToCorner(window:NativeWindow, oneBasedScreenIndex:Int, corner:String):Void
	{
		var screen:Screen = Screen.screens[oneBasedScreenIndex - 1];

		switch (corner)
		{
			case ScreenManager.TOP_RIGHT_CORNER: 
				window.x = screen.bounds.width - window.width;
				window.y = 0;
			case ScreenManager.BOTTOM_LEFT_CORNER: 
				window.x = 0;
				window.y = screen.bounds.height - window.height;
			case ScreenManager.BOTTOM_RIGHT_CORNER: 
				window.x = screen.bounds.width - window.width;
				window.y = screen.bounds.height - window.height;
			default: 
				window.x = 0;
				window.y = 0;
		}
		
		window.x += screen.bounds.x;
		window.y += screen.bounds.y;
	}
	
	/**
	 * Move an instance of NativeWindow to the center of a screen
	 * @param window Instance of a NativeWindow
	 * @param oneBasedScreenIndex index of the screen you want to move your window in, main screen=1, second screen = 2, ...
	 */
	public static function centerWindowOnScreen(window:NativeWindow, oneBasedScreenIndex:Int):Void
	{
		var screen:Screen = Screen.screens[oneBasedScreenIndex - 1];
		var centerX:Int = cast screen.bounds.right - screen.bounds.width + (screen.bounds.width / 2);
		var centerY:Int = cast screen.bounds.bottom - screen.bounds.height + (screen.bounds.height / 2);
		window.x = centerX - (window.width) / 2;
		window.y = centerY - (window.height) / 2;
	}
	
	public static function centerSpriteOnScreen(window:Sprite, oneBasedScreenIndex:Int):Void
	{
		var screen:Screen = Screen.screens[oneBasedScreenIndex - 1];
		var centerX:Int = cast screen.bounds.right - screen.bounds.width + (screen.bounds.width / 2);
		var centerY:Int = cast screen.bounds.bottom - screen.bounds.height + (screen.bounds.height / 2);
		window.x = centerX - (window.width) / 2;
		window.y = centerY - (window.height) / 2;
	}
	
	/**
	 * Stretches an instance of NativeWindow to fill the screen
	 * @param window Instance of a NativeWindow
	 * @param oneBasedScreenIndex index of the screen you want to move your window in, main screen=1, second screen = 2, ...
	 */
	public static function stretchWindowOnScreen(window:NativeWindow, oneBasedScreenIndex:Int):Void
	{
		moveWindow(window, oneBasedScreenIndex, 0, 0);
		window.width = getVisibleScreenBounds(oneBasedScreenIndex).width;
		window.height = getVisibleScreenBounds(oneBasedScreenIndex).height;
	}
	
	/**
	 * Stretches an instance of NativeWindow to fill all screens
	 * @param window Instance of a NativeWindow
	 */
	public static function stretchWindowToAllScreens(window:NativeWindow):Void
	{
		window.x = 0;
		window.y = 0;
		window.width	= cast getMaximumAvailableResolution().width;
		window.height	= cast getMaximumAvailableResolution().height;
	}
	
	/**
	 * OPen window  fullscreen on certain screen
	 * @param window Instance of a NativeWindow
	 * @param oneBasedScreenIndex index of the screen you want to move your window in, main screen=1, second screen = 2, ...
	 * @param displayState displayState of the window, can be all strings in the static class StageDisplayState
	 * @param fullScreenSourceRect FullScreen Source Rectangle, defines what part of the application goes fullscreen, null is default
	 */
	public static function openWindowFullScreenOn(window:NativeWindow, oneBasedScreenIndex:Int = 1, displayState:Int = 1, fullScreenSourceRect:Rectangle = null):Void
	{
		moveWindow(window, oneBasedScreenIndex);
		window.activate();
		
		if (fullScreenSourceRect != null)
		{
			window.stage.fullScreenSourceRect = fullScreenSourceRect;
		}
		
		window.stage.displayState = cast displayState;
	}

	/**
	 * Make existing window go fullscreen on certain screen
	 * @param window Instance of a NativeWindow
	 * @param oneBasedScreenIndex index of the screen you want to move your window in, main screen=1, second screen = 2, ...
	 * @param displayState displayState of the window, can be all strings in the static class StageDisplayState
	 * @param fullScreenSourceRect FullScreen Source Rectangle, defines what part of the application goes fullscreen, null is default
	 */
	public static function setWindowFullScreenOn(window:NativeWindow, oneBasedScreenIndex:Int = 1, displayState:Int = 1, fullScreenSourceRect:Rectangle = null):Void
	{
		moveWindow(window, oneBasedScreenIndex);

		if (fullScreenSourceRect != null)
		{
			window.stage.fullScreenSourceRect = fullScreenSourceRect;
		}
		window.stage.displayState = cast displayState;
	}

	/**
	 * Get the bounds (rectangle) of a screen
	 * @param oneBasedScreenIndex index of the screen you want to move your window in, main screen=1, second screen = 2, ...
	 */
	public static function getActualScreenBounds(oneBasedScreenIndex:Int):Rectangle
	{
		var screen:Screen = Screen.screens[oneBasedScreenIndex - 1];

		return screen.bounds;
	}

	/**
	 * Get the visible bounds (rectangle) of a screen
	 * Excludes taskbar/dock and menubar
	 * @param oneBasedScreenIndex index of the screen you want to move your window in, main screen=1, second screen = 2, ...
	 */
	public static function getVisibleScreenBounds(oneBasedScreenIndex:Int):Rectangle
	{
		var screen:Screen = Screen.screens[oneBasedScreenIndex - 1];

		return screen.visibleBounds;
	}

	/**
	 * Get the colordepth (int) of a screen, f.e 32bit, 64bit
	 * @param oneBasedScreenIndex index of the screen you want to move your window in, main screen=1, second screen = 2, ...
	 */
	public static function getScreenColorDepth(oneBasedScreenIndex:Int):Int
	{
		var screen:Screen = Screen.screens[oneBasedScreenIndex - 1];

		return screen.colorDepth;
	}
	
	//- EVENT HANDLERS ----------------------------------------------------------------------------------------
	
	//- GETTERS & SETTERS -------------------------------------------------------------------------------------
	/**
	 * Get the index of the main screen
	 */
	public static function getMainScreenIndex():Int
	{
		return 1;
	}
	
	/**
	 * Get the number of screens available
	 */
	public static function getNumScreens():Int
	{
		return Screen.screens.length;
	}
	
	/**
	 * Get the maximum available resolution, the resolution of all screens combined
	 */
	public static function getMaximumAvailableResolution():Rectangle
	{
		var virtualBounds:Rectangle = new Rectangle();

		for (screen in  Screen.screens)
		{
			if (virtualBounds.left > screen.bounds.left)
			{
				virtualBounds.left = screen.bounds.left;
			}
			if (virtualBounds.right < screen.bounds.right)
			{
				virtualBounds.right = screen.bounds.right;
			}
			if (virtualBounds.top > screen.bounds.top)
			{
				virtualBounds.top = screen.bounds.top;
			}
			if (virtualBounds.bottom < screen.bounds.bottom)
			{
				virtualBounds.bottom = screen.bounds.bottom;
			}
		}
		return virtualBounds;
	}
}