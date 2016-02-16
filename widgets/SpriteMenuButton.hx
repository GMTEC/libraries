package widgets;

import flash.display.Bitmap;
import flash.display.Sprite;
import org.aswing.Component;
import util.Images;

/**
 * ...
 * @author GM
 */
class SpriteMenuButton extends Sprite
{
	public var spriteEnabled	:Sprite;
	public var spriteDisabled	:Sprite;
	public var sizeX	:Int;
	public var sizeY	:Int;

	public function new(?bmEn:Bitmap, ?bmDis:Bitmap, ?sprEn:Sprite, ?sprDis:Sprite, sizeXIn:Int = 26, sizeYIn:Int = 26) 
	{
		super();

		sizeX = sizeXIn;
		sizeY = sizeYIn;

		x += 8;
		y += 4;

		spriteEnabled 	= new Sprite();
		if (cast bmEn) spriteEnabled.addChild(bmEn);

		if(cast sprEn)	spriteEnabled 	= sprEn;
		if(cast sprDis)	spriteDisabled 	= sprDis;

		spriteEnabled.scaleY = spriteEnabled.scaleX = sizeXIn / Math.max(spriteEnabled.width, spriteEnabled.height);

		addChild(spriteEnabled);

		if (cast bmDis)	{
			spriteDisabled 	= new Sprite();
			spriteDisabled.addChild(bmDis);
			spriteDisabled.scaleY = spriteDisabled.scaleX = sizeY / spriteDisabled.height;
			addChild(spriteDisabled);
		}
	}

	/**
	 * 
	 * @param	comp
	 * @return
	 */
	public function getComponent(comp:Component):Sprite
	{
		spriteEnabled.visible 	= comp.isEnabled();
		spriteDisabled.visible	= !spriteEnabled.visible;

		return this;
	}
}