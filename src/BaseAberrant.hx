import PickupItem.PickupType;
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

class BaseAberrant extends Updatable {
	public var x = -10.;
	public var y = -10.;

	public static var KILLS_SO_FAR = 0;

	public static var GRAVITY = 20;
	public static var BASE_SPEED = 35;

	public var ATTACK_CHANCE = 0.98;
	public var ATTACK_COOLDOWN = 1.5;
	public var DAMAGE = 10.;

	public var XSPEED = 11.;

	public var SPLITTER_OUTPUT = 2;

	public var deathDrops: Array<PickupType> = [];

	public var velx = 0.;
	public var vely = 0.;

	public var scale(default, set) = 1.;
	
	public var body : B2Body;
	public var playerBmap : Bitmap;

	public var enemyType : BadEnemies;

	public static var tileImage : Map<BadEnemies, Tile> = new Map();
	public static var tiles : Map<BadEnemies, Array<Tile>> = new Map();

	public var myTiles : Array<Tile>;
	public var enemySeed : Float;

	public function set_scale(v) {
		if (playerBmap != null) playerBmap.scale(v);

		return scale = v;
	}
	
	public function new(enemy : BadEnemies) {
		super(true);

		time += Math.random() * 8;

		enemyType = enemy;
		
		if (!tileImage.exists(enemy)) {
			var tileImagex = switch(enemy) {
				case ABERRANT: Res.creatures.aberrant.toTile();
				case SPLITTER: Res.creatures.splitter.toTile();
				case SMALL_SPLITTER: Res.creatures.smallsplitter.toTile();
				case SHOOTER: Res.creatures.shooter.toTile();
				case SPAWNER: Res.creatures.spawner.toTile();
			}
			var tlsl = [
				for(x in 0 ... Std.int(tileImagex.width / 16))
					for(y in 0 ... Std.int(tileImagex.height / 16))
						tileImagex.sub(x * 16, y * 16, 16, 16)
			];
			tileImage.set(enemy, tileImagex);
			tiles.set(enemy, tlsl);
		}

		myTiles = tiles.get(enemy);

		playerBmap = new Bitmap(myTiles[0], Main.inst.stage);
		playerBmap.height = 16 * 5;
		playerBmap.width = 16 * 5;

		enemySeed = Math.random();

		playerBmap.setScale(scale);
	}

	public var AI_ENABLED = true;
	public var hp = 100.;
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
		if (hp < 0.) {
			AI_ENABLED = false;
		}
	}

	public var damageFrameDecayMax = 1;
	public var damageFrameDecay = 0;
	public var idleLastFrame = false;
	public var time = 0.;
	public var lastAttack = 0.;
	public var inAttack = false;
	public var lastFrame = 0;
	override public function update(dt: Float) {
		time += dt;
		var mn = Main.inst;

		if (damageFrameDecay >= 0) {
			var dlt = damageFrameDecay / damageFrameDecayMax;
			playerBmap.colorAdd = new Vector(dlt * 1, dlt * 1, dlt * 1);

			if (damageFrameDecay == 0 && hp < 0.) {
				KILLS_SO_FAR++;
				remove();
				playerBmap.remove();
				mn.enemies.remove(id);
				for (drop in deathDrops) {
					var it = new PickupItem(drop);
					it.x = x;
					it.y = y;
					it.velx = velx + (Math.random() - .5) * 8;
					it.vely = vely + 9 + Math.random();
				}
				switch(enemyType) {
					case ABERRANT:
					case SMALL_SPLITTER:
					case SPAWNER:
					case SPLITTER:
						for (i in 0...SPLITTER_OUTPUT) {
							var m = cast (MobFactory.createMob(SMALL_SPLITTER, 1), BaseAberrant);
							m.velx = velx + (Math.random() - 0.5) * 15;
							m.vely = vely + (Math.random() - 0.5) * 15;
							m.x = x;
							m.y = y;
						}
					case SHOOTER:
				}
				return;
			}
		}

		damageFrameDecay--;


		var frame = Math.floor(time * (enemyType == SHOOTER ? 4 : 6)) % 5;
		playerBmap.tile = myTiles[frame];
		idleLastFrame = true;

		// Per-frame enemy update.
		switch(enemyType) {
			case SHOOTER:
				if (AI_ENABLED) {
					var chary = mn.char.y - (8 + enemySeed * 4);
					vely = Math.lerp(
						vely,
						(
							(
								10 + enemySeed * 8 + Math.sin(time * (1.4 + enemySeed * .4)) * 5 + (Math.sin(time * 0.2 + enemySeed * 100) + 1) * 15
							)
							- y
						) * 5,
						.04
					);
					velx = Math.lerp(velx, ((enemySeed > 0.5 ? 130 - enemySeed * 10 : 30 + enemySeed * 10) + Math.sin(time * (1.5 + enemySeed * .9) + enemySeed) * 8) - x, 0.05);
				}
				if (frame == 4 && !inAttack) {
					inAttack = true;
					new Projectile(x, y, (new Vector2(mn.char.x - x, (mn.char.y - 4) - y).normalize()), 20, DAMAGE, false);
				} else if (frame != 4) {
					inAttack = false;
				}
			case SPAWNER:
				velx = 0;
				vely = 0;

				x = 20 + enemySeed * 120;
				y = mn.FLOOR - 3.2;

				if (time - lastAttack > ATTACK_COOLDOWN) {
					var m = cast (MobFactory.createMob(SMALL_SPLITTER, 1), BaseAberrant);
					m.velx = velx + (Math.random() - 0.5) * 2;
					m.vely = -23 - (Math.random()) * 12;
					m.x = x;
					m.y = y;
					lastAttack = time;
				}
			case ABERRANT | SMALL_SPLITTER | SPLITTER:
				if (AI_ENABLED && !inAttack && Math.abs(x - mn.char.x) < 20 && (time - lastAttack) > ATTACK_COOLDOWN && Math.random() > ATTACK_CHANCE) {
					lastAttack = time;
					inAttack = true;
				}

				if (!inAttack && AI_ENABLED) {
					var chary = mn.char.y - 4;
					velx = Math.lerp(velx, (x > mn.char.x ? -1 : 1) * XSPEED * (Math.sin(time * 2 + .5) + 1.5) * 2, 0.04);
					vely = Math.lerp(vely, chary - y, 0.02) + Math.sin(time * 2) * 0.1;
				} else if (AI_ENABLED) {
					var vec = new Vector2(mn.char.x, mn.char.y - 4);
					var myVec = new Vector2(x, y);
					var vel = (vec - myVec);
					var dir = vel.clone().normalize();
					velx = Math.lerp(velx, dir.x * 40, 0.05);
					vely = Math.lerp(vely, dir.y * 40, 0.05);
					var touching = vel.length < 8;
					if (touching || time - lastAttack > 2) {
						lastAttack = time;
						inAttack = false;
						if (touching)
							mn.char.affectHP(-DAMAGE, DAMAGE < 10 ? DamageIntensity.MINOR : DamageIntensity.MAJOR);
					}
				} else {
					velx *= .8;
					vely *= .8;
				}
		}

		
		

		// W = 87, S = 83, SPACE = 32


		x += velx * dt;
		var fy = y + vely * dt;
		y = Math.clamp(fy, 0, mn.FLOOR);
		if (fy < 0) vely *= .8;
		if (fy > mn.FLOOR) vely *= .8;



		playerBmap.x = x * 10 - (playerBmap.width / 2);
		playerBmap.y = y * 10 - (playerBmap.height / 2);
	}
}