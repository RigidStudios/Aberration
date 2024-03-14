import h2d.RenderContext;
import hxd.Res;
import h2d.Tile;
import h2d.Bitmap;
import hxmath.math.Vector2;
import util.FaceData.SelfWeapons;

enum DamageIntensity {
	ULTIMATE;
	SWARM;
	MINOR;
	MAJOR;
}

class BurstVFX extends Bitmap {
	public static var tiles: Array<Tile> = [];
	var spawnedAt: Float;
	public function new(x: Float, y: Float) {
		if (tiles.length == 0) {
			var tileImagex = Res.vfx.burst.toTile();
			tiles = [
				for(x in 0 ... Std.int(tileImagex.width / 64))
					for(y in 0 ... Std.int(tileImagex.height / 64))
						tileImagex.sub(x * 64, y * 64, 64, 64)
			];
		}

		super(tiles[0], Main.inst.stage);

		height = 64 * 5;
		width = 64 * 5;

		this.x = x * 10 - width / 2;
		this.y = y * 10 - height / 2;

		spawnedAt = Main.inst.time;
	}

	override public function sync(context: RenderContext) {
		super.sync(context);
		var frames = 6;
		var frameIndex = (Main.inst.time - spawnedAt) * 15;
		
		// trace(frameIndex);
		if (frameIndex >= frames) {
			// trace("Too high!");
			remove();
			return;
		}

		tile = tiles[Math.floor(frameIndex)];
	}
}

class TentacleVFX extends Bitmap {
	public static var tiles: Array<Tile> = [];
	var spawnedAt: Float;
	var _weapon: SelfWeapons;
	var _tier: Int;
	public function new(x: Float, y: Float, weapon : SelfWeapons, tier : Int) {
		if (tiles.length == 0) {
			var tileImagex = Res.vfx.tentacle.toTile();
			tiles = [
				for(x in 0 ... Std.int(tileImagex.width / 16))
					for(y in 0 ... Std.int(tileImagex.height / 16))
						tileImagex.sub(x * 16, y * 16, 16, 16)
			];
		}

		_weapon = weapon;
		_tier = tier;

		super(tiles[0], Main.inst.stage);

		height = 16 * 5;
		width = 16 * 5;

		this.x = Main.inst.char.x * 10;
		this.y = Main.inst.char.y * 10;

		spawnedAt = Main.inst.time;
	}

	var used = false;
	override public function sync(context: RenderContext) {
		var ch = Main.inst.char;
		x = ch.x * 10 + ch.playerBmap.scaleX * -15;
		y = (ch.y - 6) * 10;
		scaleX = ch.playerBmap.scaleX;
		
		super.sync(context);
		var frames = 8;
		var frameIndex = (Main.inst.time - spawnedAt) * 10;

		if (frameIndex >= 2 && !used) {
			used = true;
			WeaponUser.useAttackReal(_weapon, _tier);
		}

		// trace(frameIndex);
		if (frameIndex >= frames) {
			// trace("Too high!");
			remove();
			return;
		}

		tile = tiles[Math.floor(frameIndex)];
	}
}

class SpikeVFX extends Bitmap {
	public static var tiles: Array<Tile> = [];
	var spawnedAt: Float;
	var _weapon: SelfWeapons;
	var _tier: Int;
	var _x: Float;
	public function new(x: Float, weapon : SelfWeapons, tier : Int, delay: Float) {
		if (tiles.length == 0) {
			var tileImagex = Res.vfx.spike.toTile();
			tiles = [
				for(x in 0 ... Std.int(tileImagex.width / 32))
					for(y in 0 ... Std.int(tileImagex.height / 32))
						tileImagex.sub(x * 32, y * 32, 32, 32)
			];
		}

		_x = x;

		_weapon = weapon;
		_tier = tier;

		super(tiles[0], Main.inst.stage);

		height = 32 * 5;
		width = 32 * 5;

		if (Math.random() > 0.5) {
			this.x = (x * 10) + 80;
			scaleX = -1;
		} else {
			this.x = (x * 10) - 80;
		}
		this.y = 502 - 160; // THIS

		spawnedAt = Main.inst.time + delay;
	}

	var used = false;
	override public function sync(context: RenderContext) {
		if (Main.inst.time - spawnedAt < 0) {
			visible = false;
			super.sync(context);
			return;
		}

		visible = true;
		
		super.sync(context);
		var frames = 8;
		var frameIndex = (Main.inst.time - spawnedAt) * 10;

		if (frameIndex >= 4 && !used) {
			used = true;
			WeaponUser.useAttackReal(_weapon, _tier, _x);
		}

		// trace(frameIndex);
		if (frameIndex >= frames) {
			// trace("Too high!");
			remove();
			return;
		}

		tile = tiles[Math.floor(frameIndex)];
	}
}

class WeaponUser {
	public static function useWeapon(weapon : SelfWeapons, tier : Int): Float {
		var mn = Main.inst;
		var char = mn.char;

		switch(weapon) {
			case BURST:
				char.velx *= .5;
				char.vely *= .5;
				
				new BurstVFX(char.x, char.y - .5);

				useAttackReal(weapon, tier);

				return 0.9 - tier * 0.08;
			case TENTACLES:
				new TentacleVFX(char.x, char.y, weapon, tier);

				return 0.5 - tier * 0.1;
			case SPIKES:
				new SpikeVFX(char.x, weapon, tier, 0.);
				for (i in 0...Std.int((tier + 1) * 2)) {
					new SpikeVFX(char.x -(i * 6), weapon, tier, i * (0.15 + i * 0.02));
					new SpikeVFX(char.x + (i * 6), weapon, tier, i * (0.15 + i * 0.02));
				}
				return 1.2 - tier * 0.2;
			case PEWPEW:
				new Projectile(char.x, char.y - 4, new Vector2(char.playerBmap.scaleX, 0), 50 + tier * 10, 6 + tier * 10, true);
				if (tier > 0) {
					new Projectile(char.x, char.y - 4, new Vector2(-char.playerBmap.scaleX, 0), 50 + tier * 10, 6 + tier * 10, true);
				}
				return 0.2 - tier * 0.02;
			case _:
				trace("Not implemented.", weapon);
				return 0.01;
		}
	}

	public static function useAttackReal(weapon : SelfWeapons, tier : Int, ?x : Float) {
		var mn = Main.inst;
		var char = mn.char;
		
		switch(weapon) {
			case BURST:
				for (index => value in mn.enemies) {
					if (Std.isOfType(value, BaseAberrant)) {
						var mob : BaseAberrant = cast value;
						var mobPos = new Vector2(mob.x, mob.y);
						var chPos = new Vector2(char.x, char.y);
						
						var dir = (mobPos - chPos);

						if (dir.length < 20) {
							var dft = (1 - dir.length / 20);
							mob.velx += dir.x * 60 * dft;
							mob.vely += dir.y * 60 * dft;
							
							mob.affectHP(-20 - (tier - 1) * 5, DamageIntensity.MAJOR);
						}

					}
				}
			case TENTACLES:
				var maxConsume = Std.int(2.15 + tier * 0.9);
				for (index => value in mn.enemies) {
					if (Std.isOfType(value, BaseAberrant)) {
						if (maxConsume <= 0) return;

						var mob : BaseAberrant = cast value;
						var mobPos = new Vector2(mob.x, mob.y);
						var chPos = new Vector2(char.x + char.playerBmap.scaleX * 4, char.y);
						
						var dir = (mobPos - chPos);
						dir.x *= .7;

						if (dir.length < 10) {
							mob.velx += char.playerBmap.scaleX * 10;
							mob.vely -= 25;
							maxConsume--;
							
							mob.affectHP(-40 - (tier - 1) * 8, DamageIntensity.MAJOR);
						}

					}
				}
			case SPIKES:
				for (index => value in mn.enemies) {
					if (Std.isOfType(value, BaseAberrant)) {
						var mob : BaseAberrant = cast value;

						if (mob.y > (Main.inst.FLOOR - 20) && Math.abs(mob.x - x) < 8) {
							mob.vely -= 20 + (tier - 1) * 5;
							mob.velx *= .4;
							
							mob.affectHP(-6 - (tier - 1) * 4, DamageIntensity.MAJOR);
						}

					}
				}
			case _:
				trace("Not implemented.", weapon);
		}
	}
}