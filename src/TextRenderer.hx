import hxd.Math;
import h2d.RenderContext;
import h2d.Object;
import hxsl.Types.Vec4;
import h2d.Bitmap;
import hxd.Res;
import h2d.Tile;

enum ABRFonts {
	TITLES;
	CONTROLS;

}

class TextCharacter extends Bitmap {
	public var defx(default,set) : Float;
	public var defy(default,set) : Float;

	public function set_defx(v) {
		x = v;
		return defx = v;
	}

	public function set_defy(v) {
		y = v;
		return defy = v;
	}

	var shaky : Bool;
	var fade : Bool;
	var outward : Bool;
	var createdAt : Float;
	public function new(tile: Tile, obj: Object, shaky: Bool, fade: Bool) {
		super(tile, obj);
		defx = 0;
		defy = 0;
		this.shaky = shaky;
		this.fade = fade;
		this.alpha = fade ? 0 : 1;
		this.createdAt = Main.inst.time;
	}

	public function fadeout() {
		outward = true;
		createdAt = Main.inst.time;
	}

	override public function sync(ctx: RenderContext) {
		if (shaky) {
			x = defx + ((Math.random() - 0.5) * 3);
			y = defy + ((Math.random() - 0.5) * 3);
		}
		if (fade && this.alpha < 1) {
			this.alpha = Math.clamp((Main.inst.time - createdAt) * 1.5, 0, 1);
			y = defy + 1 - Math.clamp((Main.inst.time - createdAt) * 1.5, 0, 1);
		}
		if (fade && outward) {
			this.alpha = 1 - Math.clamp((Main.inst.time - createdAt) * 2, 0, 1);
			y = defy + Math.clamp((Main.inst.time - createdAt) * 2, 0, 1);
			if (this.alpha == 0) remove();
		}
		if (outward && !fade) remove();
		super.sync(ctx);
	}
}

class TextRenderer {
	public static var ttls_textSize = 22;
	public static var ttls_spaceSize = 4;
	public static var ttls_whitespaceSize = 10;
	public static var ttls_linespaceSize = 8;

	public static var ctrl_textSize = 20;
	public static var ctrl_spaceSize = 4;
	public static var ctrl_whitespaceSize = 10;
	public static var ctrl_linespaceSize = 8;
	
	public static var ctrl_tileImage : Tile;
	public static var ctrl_tiles : Array<Tile> = [];

	public static var ttls_tileImage : Tile;
	public static var ttls_tiles : Array<Tile> = [];

	public static var RENDERED = new Map<Int, TextRenderer>();
	public static var INDEX = 0;

	public var id : Int;
	public var chars : Array<Bitmap> = [];

	public function new() {
		id = INDEX++;
		RENDERED.set(id, this);
	}

	public static var alphabet = "abcdefghijklmnopqrstuvwxyz1234567890%-+";
	public static var modifiers = "*+%]><";

	public static function initTiles() {
		ctrl_tileImage = Res.keybind_alphabet.toTile();
		ctrl_tiles = [
			for(y in 0 ... Std.int(ctrl_tileImage.height / 5))
			for(x in 0 ... Std.int(ctrl_tileImage.width / 5))
			ctrl_tileImage.sub(x * 5, y * 5, 5, 5)
		];
		ttls_tileImage = Res.alphabet.toTile();
		ttls_tiles = [
			for(y in 0 ... Std.int(ttls_tileImage.height / 10))
			for(x in 0 ... Std.int(ttls_tileImage.width / 10))
			ttls_tileImage.sub(x * 10, y * 10, 10, 10)
		];
	}

	public static function draw(text : String, maxWidth : Int, paddingTop : Float, parent : Object, font : ABRFonts = TITLES): Array<TextCharacter> {
		if (ctrl_tileImage == null) initTiles();

		var textSize: Int; var spaceSize: Int; var whitespaceSize: Int; var linespaceSize: Int; var tiles: Array<Tile>;
		switch(font) {
			case TITLES:
				textSize = ttls_textSize;
				spaceSize = ttls_spaceSize;
				whitespaceSize = ttls_whitespaceSize;
				linespaceSize = ttls_linespaceSize;
				tiles = ttls_tiles;
			case CONTROLS:
				textSize = ctrl_textSize;
				spaceSize = ctrl_spaceSize;
				whitespaceSize = ctrl_whitespaceSize;
				linespaceSize = ctrl_linespaceSize;
				tiles = ctrl_tiles;
		}

		var i = 0;

		var spacesThisLine = 0;
		var lines = 0;

		var lineSizes = [];
		var ignorenext = false;

		for (index=>ltr in text.split("")) {
			if (ltr.charCodeAt(0) == 10 || index == text.length - 1) {
				if (index == text.length - 1) i++;

				lines++;
				lineSizes.push(i * (textSize + spaceSize) - spaceSize + (whitespaceSize * spacesThisLine));
				spacesThisLine = 0;
				i = 0;
				continue;
			}

			if (ltr == "<") {
				ignorenext = true;
				continue;
			}

			if (ltr == " ") {	
				spacesThisLine++;
				continue;
			}

			if (alphabet.indexOf(ltr) != -1) {
				if (modifiers.indexOf(ltr) != -1) {
					if (ignorenext) i++;
				} else i++;
			}
			ignorenext = false;
		}
		
		lines = 0;
		spacesThisLine = 0;

		var mod = false;
		var mod2 = false;
		var shak = false;
		var fade = false;

		var chars = [];
		for (ltr in text.split("")) {
			// trace(ltr, ltr.charCodeAt(0));
			if (ltr.charCodeAt(0) == 10) {
				lines++;
				spacesThisLine = 0;
				i = 0;
				continue;
			}

			if (ltr == " ") {
				spacesThisLine++;
				continue;
			}

			if (!ignorenext) {
				switch(ltr) {
					case "*":
						mod = true;
						continue;
					case "+":
						mod2 = true;
						continue;
					case "%":
						shak = true;
						continue;
					case "]":
						shak = false;
						mod = false;
						mod2 = false;
						continue;
					case ">":
						fade = true;
						continue;
					case "<":
						ignorenext = true;
						continue;
				}
			}

			ignorenext = false;

			var letter = new TextCharacter(tiles[alphabet.indexOf(ltr)], parent, shak, fade);
			letter.width = textSize;
			// letter.defx = (maxWidth - lineSizes[lines]) / 2 + ((i * (textSize + spaceSize)) - spaceSize + (whitespaceSize * spacesThisLine));
			letter.defx = (maxWidth - lineSizes[lines]) / 2 + (i * (textSize + spaceSize) + (whitespaceSize * spacesThisLine));
			letter.defy = paddingTop + lines * (linespaceSize + textSize);
			if (mod) letter.color = new Vec4(246 / 255,186 / 255,251 / 255,1);
			if (mod2) letter.color = new Vec4(170 / 255,215 / 255,239 / 255,1);
			i++;
			chars.push(letter);
		}
		return chars;
	}
}