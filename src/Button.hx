import TextRenderer.TextCharacter;
import hxsl.Types.Vec4;
import hxd.Math;
import h2d.RenderContext;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Object;

class CDTextLabel extends Object {
	public var label(default, set) : String;
	public var lb : Array<TextCharacter> = [];

	public function set_label(lab) {
		for (character in lb) {
			character.remove();
		}
		lb = TextRenderer.draw(lab, Std.int(mWidth), mYOff, this, TITLES);
		return label = lab;
	}

	public var mWidth : Float;
	public var mYOff : Float;

	public function new(width : Float, yoff : Float, parent : Object) {
		mWidth = width;
		mYOff = yoff;
		super(parent);
	}
}

class CDTab extends Object {
	public var bmp : Bitmap;
	var int : Interactive;

	var isOver : Bool;
	var isDown : Bool;
	public dynamic function onOver() {}
	public dynamic function onOut() {}

	public var enabled(default, set) : Bool = true;
	public var toplabel(default, set) : String;
	public var labeloffset : Int;
	public var lb : Array<TextCharacter> = [];

	public function set_toplabel(lab) {
		for (character in lb) {
			character.remove();
		}
		lb = TextRenderer.draw(lab, Std.int(bmp.width), labeloffset, bmp, TITLES);
		return toplabel = lab;
	}

	public function set_enabled(b) {
		bmp.color = b ? new Vec4(1,1,1,1) : new Vec4(0.7,0.7,0.7,1);
		return enabled = b;
	}

	public function new(tile : Tile, pxscale : Float, parent : Object) {
		super(parent);

		bmp = new Bitmap(tile, this);
		bmp.width = tile.width * pxscale;
		int = new Interactive(tile.width * pxscale, tile.height * pxscale, this);

		int.onOver = (e) -> {
			onOver();
			isOver = true;
		}

		int.onOut = (e) -> {
			onOut();
			isOver = false;
		}

		int.onPush = (e) -> {
			isDown = true;
		}

		int.onRelease = (e) -> {
			isDown = false;
		}

		int.onReleaseOutside = (e) -> {
			isDown = false;
		}
	}

	override public function sync(ctx: RenderContext) {
		super.sync(ctx);

		// bmp.y = Math.clamp(bmp.y + (isOver && (!isDown || (isDown && bmp.y > -4)) ? -1 : 1), enabled ? -8 : -4, 0);
		// bmp.scaleY = Math.clamp(bmp.scaleY + (isDown ? -0.005 : 0.04), 0.95, 1);
	}
}

class CDButton extends Object {
	var bmp : Bitmap;
	var int : Interactive;

	var isOver : Bool;
	var isDown : Bool;
	public dynamic function onOver() {}
	public dynamic function onOut() {}
	public dynamic function onClick() {}

	public var enabled(default, set) : Bool = true;
	public var toplabel(default, set) : String;
	public var lb : Array<TextCharacter> = [];

	public function set_toplabel(lab) {
		for (character in lb) {
			character.remove();
		}
		lb = TextRenderer.draw(lab, Std.int(bmp.width), -35, bmp, TITLES);
		return toplabel = lab;
	}

	public function set_enabled(b) {
		bmp.color = b ? new Vec4(1,1,1,1) : new Vec4(0.7,0.7,0.7,1);
		return enabled = b;
	}

	public function new(tile : Tile, pxscale : Float, parent : Object) {
		super(parent);

		bmp = new Bitmap(tile, this);
		bmp.width = tile.width * pxscale;
		int = new Interactive(tile.width * pxscale, tile.height * pxscale, this);

		int.onOver = (e) -> {
			onOver();
			isOver = true;
		}

		int.onOut = (e) -> {
			onOut();
			isOver = false;
		}

		int.onPush = (e) -> {
			isDown = true;
		}

		int.onRelease = (e) -> {
			isDown = false;
		}

		int.onReleaseOutside = (e) -> {
			isDown = false;
		}

		int.onClick = (e) -> {
			if (enabled) onClick();
		}
	}

	override public function sync(ctx: RenderContext) {
		super.sync(ctx);

		bmp.y = Math.clamp(bmp.y + (isOver && (!isDown || (isDown && bmp.y > -4)) ? -1 : 1), enabled ? -8 : -4, 0);
		// bmp.scaleY = Math.clamp(bmp.scaleY + (isDown ? -0.005 : 0.04), 0.95, 1);
	}
}