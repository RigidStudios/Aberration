import PickupItem.PickupType;
import hxd.Math;
import util.FaceData.BadEnemies;

class MobFactory {
	public static function createMob(enemy : BadEnemies, tier : Int) {
		var _mob: Updatable;
		switch(enemy) {
			case ABERRANT:
				var mob = new BaseAberrant(enemy);
				_mob = mob;
				mob.hp = 60 + tier * 10;
				if (tier > 1) {
					mob.DAMAGE = 10 + tier * 2.5;
					mob.ATTACK_CHANCE -= tier * 0.04;
					mob.ATTACK_COOLDOWN -= tier * 0.15;
					mob.XSPEED += tier * 1;
				}
			case SPLITTER:
				var mob = new BaseAberrant(enemy);
				_mob = mob;
				mob.hp = 50 + tier * 10;
				if (tier > 1) {
					mob.DAMAGE = 10 + tier * 3;
					mob.ATTACK_CHANCE -= tier * 0.04;
					mob.SPLITTER_OUTPUT += tier;
					mob.ATTACK_COOLDOWN -= tier * 0.15;
					mob.XSPEED += tier * 1;
				}
			case SPAWNER:
				var mob = new BaseAberrant(enemy);
				_mob = mob;
				mob.hp = 60 + tier * 10;
				if (tier > 1) {
					mob.DAMAGE = 0;
					mob.ATTACK_CHANCE = 0;
					mob.SPLITTER_OUTPUT += tier;
					mob.ATTACK_COOLDOWN = 7 - tier * 1;
					mob.XSPEED += tier * 1;
				}
			case SMALL_SPLITTER:
				var mob = new BaseAberrant(enemy);
				_mob = mob;
				mob.hp = 15 + tier * 4;
				mob.XSPEED += tier * 1.4;
				mob.DAMAGE = 4 + (tier - 1) * 3;
				if (tier > 1) {
					mob.ATTACK_CHANCE -= tier * 0.04;
					mob.ATTACK_COOLDOWN -= tier * 0.15;
				}
			case SHOOTER:
				var mob = new BaseAberrant(enemy);
				_mob = mob;
				mob.hp = 42 + tier * 8;
				if (tier > 1) {
					mob.DAMAGE = 5 + tier * 3;
					mob.ATTACK_CHANCE -= tier * 0.04;
					mob.SPLITTER_OUTPUT += tier;
					mob.ATTACK_COOLDOWN -= tier * 0.15;
					mob.XSPEED += tier * 1;
				}
		}
		Main.inst.enemies.set(_mob.id, _mob);
		return _mob;
	}

	public static function getMobsForRound(round: Int) {
		var hasPin = Math.random() > (0.85 + round * 0.04);
		var hasLock = Math.random() > (0.9 + round * 0.02);
		var hasFlip = Math.random() > (0.8 + round * 0.04);
		var mn = Main.inst;
		var cards = mn.cards;
		var enems = [];
		
		for (card in cards) {
			var f = card.getFaceData();
			for (enemy in f.UNLOCK_ENEMIES) {
				for (i in 0...Std.int(Math.clamp(1 + ((round + 1) * 0.5), 1, 5))) {
					var m = cast(createMob(enemy, f.ENEMY_TIERS), BaseAberrant);
					m.x = Math.random() > 0.5 ? -5 - Math.random() * 20 : 165 + Math.random() * 20;
					m.y = 20 + Math.random() * 15;
					enems.push(m);
				}
			}
		}

		if (hasPin) enems[Std.random(enems.length)].deathDrops.push(PickupType.PIN);
		if (hasLock) enems[Std.random(enems.length)].deathDrops.push(PickupType.LOCK);
		if (hasFlip) enems[Std.random(enems.length)].deathDrops.push(PickupType.FLIP);
	}
}