import h3d.Vector;
import WeaponUser.DamageIntensity;
import hxd.Res;
import hxd.Math;
import box2D.common.math.B2Vec2;
import h2d.Tile;
import h2d.Bitmap;
import hxmath.math.Vector2;
import util.PhysicsUtil;
import box2D.dynamics.B2Body;

class Character extends Updatable {
	public var x = 0.;
	public var y = 0.;

	public static var GRAVITY = 30;
	public static var BASE_SPEED = 35;

	public var velx = 0.;
	public var vely = 0.;
	
	public var body : B2Body;
	public var playerBmap : Bitmap;

	public var jumps : Int;
	public var maxJumps : Int;

	public var tileImage : Tile;
	public var tiles : Array<Tile>;

	public var health = 100.;
	public var maxHealth(get, null): Float;

	public function get_maxHealth() {
		return 100.;
	}
	
	public function new() {
		super(true);

		jumps = 1;
		maxJumps = 1;
		
		tileImage = Res.charframes.toTile();
		tiles = [
			for(x in 0 ... Std.int(tileImage.width / 32))
				for(y in 0 ... Std.int(tileImage.height / 32))
					tileImage.sub(x * 32, y * 32, 32, 32)
		];

		trace(tiles);
		
		playerBmap = new Bitmap(tiles[0], Main.inst.stage);
		playerBmap.height = 32 * 5;
		playerBmap.width = 32 * 5;
		Main.inst.char = this;
	}

	public function setRoundStartState(endRound: Bool = false) {
		x = 800;
		y = Main.inst.FLOOR;
		if (endRound) {

		}
	}

	public var hp = 100.;
	public var maxHp = 100.;
	public function affectHP(dmg : Float, intensity : DamageIntensity) {
		// Main.inst.cardTray.
		switch(intensity) {
			case ULTIMATE:
				damageFrameDecayMax = damageFrameDecay = 7;
			case SWARM:
				damageFrameDecayMax = damageFrameDecay = 2;
			case MAJOR:
				damageFrameDecayMax = damageFrameDecay = 4;
			case MINOR:
				damageFrameDecayMax = damageFrameDecay = 3;
		}
		hp += dmg;
		trace(hp);
		if (hp < 0.) {
			// TODO: lose condition.
		}
	}

	public var shown = false;

	public var damageFrameDecayMax = 1;
	public var damageFrameDecay = 0;
	public var idleLastFrame = false;
	public var time = 0.;
	override public function update(dt: Float) {
		time += dt;
		var mn = Main.inst;

		maxHp = (100 + mn.cardTray.BUFF_SELF_HEALTH) * mn.cardTray.BUFF_SELF_HEALTH_MULT;

		if (shown) {
			playerBmap.visible = true;
		} else {
			playerBmap.visible = false;
		}

		if (damageFrameDecay >= 0) {
			var dlt = damageFrameDecay / damageFrameDecayMax;
			playerBmap.colorAdd = new Vector(dlt * 1, dlt * 1, dlt * 1);
			
			// if (damageFrameDecay == 0 && hp < 0.) {
			// 	remove();
			// 	playerBmap.remove();
			// 	return;
			// }
		}

		damageFrameDecay--;
		
		var speed = BASE_SPEED * mn.cardTray.BUFF_SELF_SPEED;
		
		// W = 87, S = 83, SPACE = 32
		velx = Math.lerp(velx, shown ? ((mn.isKDown(65) ? -1 : 0) + (mn.isKDown(68) ? 1 : 0)) * speed : 0, 0.35);
		vely = (vely + GRAVITY * dt);
		if (vely > 0) {
			vely *= 1.04;
		} else {
			vely *= 0.95;
		}

		var wasJumpFrame = false;
		if (mn.consumeK(32) && jumps > 0) {
			jumps--;
			vely = (-60) * mn.cardTray.BUFF_SELF_JUMP_MULT;
			wasJumpFrame = true;
		}
		
		var groundContact = y + vely * dt > mn.FLOOR;

		x += velx * dt;
		y = Math.clamp(y + vely * dt, 0, mn.FLOOR);
		x = Math.clamp(x, 0, 160);

		if (groundContact) {
			vely = 0;
			if (!wasJumpFrame) {
				jumps = mn.cardTray?.BUFF_SELF_JUMP_EXTRA ?? maxJumps;
			}
		}

		if (Math.abs(velx) < 0.1) {
			var frame = Math.floor(time * 6) % 4;
			playerBmap.tile = tiles[frame];
			idleLastFrame = true;
		} else {
			if (idleLastFrame) {
				idleLastFrame = false;
				time = 0;
			}
			var frame = Math.floor(time * 12) % 7;
			playerBmap.scaleX = velx > 0 ? 1 : -1;
			playerBmap.tile = tiles[3 + frame];
		}

		playerBmap.x = x * 10 + (playerBmap.width / 2) * -playerBmap.scaleX;
		playerBmap.y = y * 10 - playerBmap.height + 10;
	}
}