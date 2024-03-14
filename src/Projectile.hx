import WeaponUser.DamageIntensity;
import h2d.RenderContext;
import h2d.Tile;
import hxmath.math.Vector2;
import hxd.Res;
import h2d.Bitmap;

class Projectile extends Bitmap {
	public static var tiles: Array<Tile> = [];
	var time: Float;
	var dir: Vector2;
	var _x: Float;
	var _y: Float;
	var dmg : Float;
	var goodG : Bool;
	public function new(x: Float, y: Float, dir: Vector2, speed : Float, dmg : Float, goodGuy : Bool) {
		goodG = goodGuy;
		if (tiles.length == 0) {
			var tileImagex = goodGuy ? Res.vfx.friendly_projectile_small.toTile() : Res.vfx.projectile_small.toTile();
			tiles = [
				for(x in 0 ... Std.int(tileImagex.width / 8))
					for(y in 0 ... Std.int(tileImagex.height / 8))
						tileImagex.sub(x * 8, y * 8, 8, 8)
			];
		}

		this.dmg = dmg;

		super(tiles[0], Main.inst.stage);

		trace("NEW PROJECTILE!");

		height = 8 * 5;
		width = 8 * 5;

		_x = x;
		_y = y;
		this.x = x * 10;
		this.y = y * 10;

		this.dir = dir * speed;

		time = Math.random() * 2;
	}


	override public function sync(ctx: RenderContext) {
		var dt = Main.inst._dt;
		time += dt;

		if (time > 10.) remove();

		var frame = Math.floor(time * 6) % 5;
		tile = tiles[frame];

		_x += dir.x * dt;
		_y += dir.y * dt;

		x = _x * 10;
		y = _y * 10;

		if (goodG) {
			for (enemy in Main.inst.enemies) {
				var ab = cast(enemy, BaseAberrant);
				if (new Vector2(_x - ab.x, _y - ab.y).length < 5) {
					ab.affectHP(-dmg, DamageIntensity.MINOR);
					remove();
				}
			}
		} else {
			if (new Vector2(_x - Main.inst.char.x, _y - (Main.inst.char.y - 4)).length < 3) {
				Main.inst.char.affectHP(-dmg, DamageIntensity.MINOR);
				remove();
			}
		}

		if (_y < 0) remove();
		if (_y > Main.inst.FLOOR) remove();

		super.sync(ctx);
	}
}