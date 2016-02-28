package widgets;

import comp.Decorators.WDragDecorator;
import db.ResObject;
import events.PanelEvents;
import flash.events.Event;
import haxe.Timer;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import org.aswing.AssetPane;
import org.aswing.Component;
import org.aswing.geom.IntDimension;
import org.aswing.graphics.Graphics2D;
import org.aswing.GroundDecorator;
import org.aswing.JLoadPane;
import org.aswing.JPanel;
import util.Fading;
//import widgets.WComponent.BorderDecorator;

/**
 * ...
 * @author GM
 */
class WSlideShow extends WComponent
{
	var timer:Timer;
	var delay:Int = 3000;
	var slides:Map<Int, JLoadPane>;
	var slideIndex:Int = 0;
	var currentSlide:JLoadPane;
	var slidesNumber:Int;
	var loadPane:JLoadPane;
	var dragDecorator:WDragDecorator;

	public function new() 
	{
		super();

		var frame:Sprite = new Sprite();
		drawDashedRect(frame);

		slides = new  Map<Int, JLoadPane> ();
		Main.root1.addEventListener(PanelEvents.EVT_GET_PAGES, onPagesInitialized);
		
        var g:Graphics2D = new Graphics2D(frame.graphics);

		//this.setBackgroundDecorator(new WDragDecorator());
		
	}

	override function setVisible(vis:Bool)
	{
		trace("SetVisible()");
	}

	/**
	 * 
	 * @param	e
	 */
	private function onPagesInitialized(e:Event):Void 
	{
		if (slidesNumber > 1)
		{
			timer = new Timer(delay);
			timer.run = onTimer;
			onTimer();
		}
		else
			loadPane.visible = true;
	}

	/**
	 * 
	 */
	function onTimer() 
	{
		if (parent.visible)
		{
			if (cast currentSlide)
				Fading.fadeOut(currentSlide, 0, 1);
		
			if (!slides.exists(++slideIndex))
			{
				slideIndex = 1;
			}
			currentSlide = slides.get(slideIndex);
			Fading.fadeIn(currentSlide, 1, 1);
		}
	}

	/**
	 * 
	 * @param	page
	 * @param	comp
	 */
	static public function addSlideShowToPage(components:Map <String, Component>, page:JPanel, comp:ResObject) 
	{
		var slideShow:WSlideShow = cast components.get(comp.Name);

		if (slideShow == null) {
			slideShow = new WSlideShow();
			components.set(comp.Name, cast slideShow);
			page.addChild(slideShow);
		}
		slideShow._addSlideShowToPage(comp);
	}

	/**
	 * 
	 * @param	components
	 * @param	Component>
	 * @param	page
	 * @param	comp
	 */
	function _addSlideShowToPage(comp:ResObject) 
	{
		slidesNumber ++;
		loadPane = new JLoadPane();
		loadPane.setSize(new IntDimension(comp.W, comp.H));
		loadPane.setAwmlID(cast comp.ID);
		loadPane.x = comp.X;
		loadPane.y = comp.Y;
		loadPane.setScaleMode(AssetPane.SCALE_FIT_PANE);
			
		loadPane.setVisible(false);
		loadPane.load(new URLRequest(comp.URL));
		loadPane.addEventListener(MouseEvent.CLICK, onImageClick);
		slides.set(comp.Number, loadPane);
		
		loadPane.butCursorAllowed = true;
		loadPane.setRightButtonEnabled();

		addChild(loadPane);		
	}

	/**
	 * 
	 * @param	e
	 */
	private function onImageClick(e:MouseEvent):Void 
	{
		trace("onImageClick");
	}
}