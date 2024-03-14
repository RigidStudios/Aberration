import h3d.Vector;
import WeaponUser.DamageIntensity;
import hxsl.Types.Vec4;
import util.FaceData.BadEnemies;
import hxd.Res;
import hxd.Math;
import box2D.common.math.B2Vec2;
import h2d.Tile;
import h2d.Bitmap;
import hxmath.math.Vector2;
import util.PhysicsUtil;
import box2D.dynamics.B2Body;

enum PickupType {
	PIN;
	LOCK;
	FLIP;
}

class PickupItem extends Updatable {
	public var x = -10.;
	public var y = -10.;

	public static var GRAVITY = 20;

	public var velx = 0.;
	public var vely = 0.;
	
	public var playerBmap : Bitmap;
	
	public var pickupType : PickupType;

	public function new(pck: PickupType) {
		super(true);

		var tile: Tile = switch(pck) {
			case PIN: Main.inst.uisheet.sub(80, 48, 16, 16);
			case LOCK: Main.inst.uisheet.sub(96, 48, 16, 16);
			case FLIP: Main.inst.uisheet.sub(96, 32, 16, 16);
		}

		time += Math.random() * 8;

		pickupType = pck;

		playerBmap = new Bitmap(tile, Main.inst.stage);
		playerBmap.height = 16 * 5;
		playerBmap.width = 16 * 5;
	}

	public var time = 0.;
	override public function update(dt: Float) {
		time += dt;
		var mn = Main.inst;

		vely = vely + GRAVITY * dt;
		velx = velx * 0.98;
		if (Math.abs(mn.char.x - x) < 16) {
			velx += (mn.char.x - x) * 0.1;
		}


		// W = 87, S = 83, SPACE = 32

		x += velx * dt;
		var fy = y + vely * dt;
		y = Math.clamp(fy, 0, mn.FLOOR);
		x = Math.clamp(x, 0, 160);
		if (fy < 0) vely = 0;
		if (fy > mn.FLOOR) vely = .8;

		if (new Vector2(mn.char.x - x, mn.char.y - y).length < 5) {
			switch(pickupType) {
				case PIN:
					mn.pinsCount += 1;
				case LOCK:
					mn.locksCount += 1;
				case FLIP:
					mn.flipsCount += 1;
			}
			remove();
			playerBmap.remove();
		}

		playerBmap.x = x * 10 - (playerBmap.width / 2);
		playerBmap.y = y * 10 - (playerBmap.height);
	}
}