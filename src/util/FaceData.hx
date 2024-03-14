package util;

import h2d.Tile;

enum SelfWeapons {
	TENTACLES;
	BURST;
	SWARM;
	ORB;
	ANGELS;
	SPUNK;
	SPIKES;
	ENCHANTMENT;
	PEWPEW;
}

enum BadEnemies {
	ABERRANT;
	SPLITTER;
	SMALL_SPLITTER;
	SHOOTER;
	SPAWNER;
}

typedef FaceData = {
	public var ?BUFF_SELF_SPEED : Float;
	public var ?BUFF_SELF_HEALTH : Float;
	public var ?BUFF_SELF_HEALTH_MULT : Float;
	public var ?BUFF_SELF_JUMP_EXTRA : Int;
	public var ?BUFF_SELF_JUMP_MULT : Float;
	public var ?BUFF_SELF_JUMP_SLOWFALL : Float;
	public var ?BUFF_SELF_DAMAGE : Float;
}

class CardFaceData {
	public static var faceDatae = new Map<String, CardFaceData>();
	public static var discoveredFaces : Map<String, Bool> = new Map();
	public static var cardFaces = 0;

	public var BUFF_SELF_SPEED = 0.;
	public var BUFF_SELF_HEALTH = 0.;
	public var BUFF_SELF_HEALTH_MULT = 1.;
	public var BUFF_SELF_JUMP_EXTRA = 0;
	public var BUFF_SELF_JUMP_MULT = 1.;
	public var BUFF_SELF_JUMP_SLOWFALL = 0.;
	public var BUFF_SELF_DAMAGE = 0.;

	public var UNLOCK_WEAPONS: Array<SelfWeapons> = [];
	public var UNLOCK_ENEMIES: Array<BadEnemies> = [];
	public var ENEMY_TIERS = 1;
	public var WEAPON_TIERS = 1;

	public var TITLE = "NO TITLE";

	public var BIND : Null<Int>;
	public var IMG : Null<Tile>;

	public var ID : Null<String>;

	public function shouldHaveBind() {
		return UNLOCK_WEAPONS.length > 0;
	}

	public function isStatCard() {
		return UNLOCK_WEAPONS.length == 0 && UNLOCK_ENEMIES.length == 0;
	}

	public function new(?id: String) {
		ID = id;
		cardFaces++;
		faceDatae.set(id, this);
	}
}