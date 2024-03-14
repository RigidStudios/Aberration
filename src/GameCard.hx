import util.FaceData;
import h2d.Tile;
import Button.CDTab;
import Button.CDTextLabel;
import hxd.Math;
import CardTray.CardClickConsumptionReason;
import h2d.Object;
import TextRenderer.TextCharacter;
import util.FaceData.SelfWeapons;
import util.FaceData.BadEnemies;
import util.FaceData.CardFaceData;
import h2d.filter.Shader;
import motion.easing.Quad.Circ;
import motion.Actuate;
import h2d.Interactive;
import hxd.Res;
import h2d.Bitmap;

enum TrayFilter {
	INIT_DRAW;
	DRAW;
	ACTIVE;
}

class CardsDeck {
	public static var ABERRANT_1 = new CardFaceData("ab1");
	public static var ABERRANT_2 = new CardFaceData("ab2");
	public static var ABERRANT_3 = new CardFaceData("ab3");

	public static var SPLITTER_1 = new CardFaceData("sp1");
	public static var SPLITTER_2 = new CardFaceData("sp2");
	public static var SPLITTER_3 = new CardFaceData("sp3");

	public static var SHOOTER_1 = new CardFaceData("sh1");
	public static var SHOOTER_2 = new CardFaceData("sh2");
	public static var SHOOTER_3 = new CardFaceData("sh3");

	public static var SPAWNER_1 = new CardFaceData("sw1");
	public static var SPAWNER_2 = new CardFaceData("sw2");
	public static var SPAWNER_3 = new CardFaceData("sw3");

	public static var BURST_1 = new CardFaceData("bu1");
	public static var BURST_2 = new CardFaceData("bu2");
	public static var BURST_3 = new CardFaceData("bu3");

	public static var TENTACLES_1 = new CardFaceData("te1");
	public static var TENTACLES_2 = new CardFaceData("te2");
	public static var TENTACLES_3 = new CardFaceData("te3");

	public static var PEWPEW_1 = new CardFaceData("pw1");
	public static var PEWPEW_2 = new CardFaceData("pw2");
	public static var PEWPEW_3 = new CardFaceData("pw3");

	public static var SPIKES_1 = new CardFaceData("sk1");
	public static var SPIKES_2 = new CardFaceData("sk2");
	public static var SPIKES_3 = new CardFaceData("sk3");

	public static var S_RABBIT_1 = new CardFaceData("rb1");
	public static var S_RABBIT_2 = new CardFaceData("rb2");

	public static var S_FLASH_1 = new CardFaceData("fl1");
	public static var S_FLASH_2 = new CardFaceData("fl2");

	public static var S_BATS_1 = new CardFaceData("ba1");
	public static var S_BATS_2 = new CardFaceData("ba2");

	public static var S_BEARS_1 = new CardFaceData("bo1");
	public static var S_BEARS_2 = new CardFaceData("bo2");

	public static var isDeckReady = false;

	public static var STARTERS_1 = [[BURST_1, ABERRANT_1], [PEWPEW_1, SPLITTER_1]];
	public static var STARTERS_2 = [[ABERRANT_1, ABERRANT_1], [ABERRANT_1, ABERRANT_1]];

	// public static var STARTERS_1 = [[BURST_1, ABERRANT_1], [BURST_1, SPLITTER_1]];
	// public static var STARTERS_2 = [[ABERRANT_1, BURST_1], [SPLITTER_1, BURST_1]];

	public static var DRAW_RNDS_1_5: Array<Array<CardFaceData>> = [[ABERRANT_1, BURST_1], [S_BEARS_2, SPAWNER_2], [S_BEARS_1, SHOOTER_2], [SPAWNER_1, S_FLASH_1], [SPAWNER_1, SPIKES_1], [SHOOTER_1, PEWPEW_2], [SPLITTER_1, PEWPEW_1],  [SHOOTER_1, TENTACLES_2], [SPLITTER_1, BURST_1], [ABERRANT_1, TENTACLES_1], [SPIKES_1, SPLITTER_1], [S_BATS_1, SPLITTER_1]];
	public static var DRAW_RNDS_6_12: Array<Array<CardFaceData>> = [[ABERRANT_2, BURST_2], [SPLITTER_2, S_BATS_2], [SPAWNER_1, S_FLASH_2], [SPIKES_2, TENTACLES_2], [SPLITTER_2, BURST_2]];
	public static var DRAW_RNDS_13_20: Array<Array<CardFaceData>> = [[ABERRANT_3, BURST_3], [S_RABBIT_2, SPLITTER_3], [S_RABBIT_1, SPLITTER_3], [S_FLASH_2, SPLITTER_3], [BURST_3, SPLITTER_3]];

	public static function getStarterCards() {
		var starter1 = STARTERS_1[Std.random(STARTERS_1.length)];
		var starter2 = STARTERS_2[Std.random(STARTERS_2.length)];

		var c1 = new GameCard(starter1[0], starter1[1]);
		c1.filter = INIT_DRAW;
		c1.IS_LOCKED = true;

		var c2 = new GameCard(starter2[0], starter2[1]);
		c2.filter = INIT_DRAW;
		c2.IS_LOCKED = true;
	}

	public static function getDraw(rn : Int) {
		var draw = rn < 6 ? DRAW_RNDS_1_5 : rn < 13 ? DRAW_RNDS_6_12 : DRAW_RNDS_13_20;
		var card1 = draw[Std.random(draw.length)];
		var c1 = new GameCard(card1[0], card1[1]);
		c1.filter = DRAW;
		var card2 = draw[Std.random(draw.length)];
		var c2 = new GameCard(card2[0], card2[1]);
		c2.filter = DRAW;
	}

	public static inline function setTitles(base: String, items: Array<CardFaceData>, weapon: Bool = false) {
		for (index=>item in items) {
			if (weapon) {
				item.TITLE = '${base} ${StringTools.rpad("", "i", index + 1)}\n*weapon';
			} else {
				item.TITLE = '${base} ${StringTools.rpad("", "i", index + 1)}\n+enemy';
			}
		}
	}

	public static inline function setData(items: Array<CardFaceData>, base: String, weapon: Bool, enemies: Array<BadEnemies>, weapons: Array<SelfWeapons>, tile: Tile) {
		for (index=>item in items) {
			if (weapon) {
				item.TITLE = '${base} ${StringTools.rpad("", "i", index + 1)}\n*weapon';
			} else {
				item.TITLE = '${base} ${StringTools.rpad("", "i", index + 1)}\n+enemy';
			}
			item.UNLOCK_ENEMIES = enemies;
			item.UNLOCK_WEAPONS = weapons;
			item.ENEMY_TIERS = item.WEAPON_TIERS = index + 1;
			item.IMG = tile;
		}
	}

	public static function generateStatString(stat: CardFaceData, buff: Bool) {
		var hlChar = buff ? "*" : "+";

		var str = "";
		str += stat.BUFF_SELF_DAMAGE != 0. ? hlChar + '<+${Std.int(stat.BUFF_SELF_DAMAGE)}] damage\n' : "";
		str += stat.BUFF_SELF_SPEED != 0. ? hlChar + '<+${Std.int(stat.BUFF_SELF_SPEED * 100)}<%] speed\n' : "";
		str += stat.BUFF_SELF_HEALTH != 0. ? hlChar + '<+${Std.int(stat.BUFF_SELF_HEALTH)}] hp\n' : "";
		str += stat.BUFF_SELF_HEALTH_MULT != 1. ? hlChar + '<+${Std.int(stat.BUFF_SELF_HEALTH_MULT * 100 - 100)}<%] hp\n' : "";
		str += stat.BUFF_SELF_JUMP_EXTRA != 0 ? hlChar + '<+${Std.int(stat.BUFF_SELF_JUMP_EXTRA)}] jumps\n' : "";
		str += stat.BUFF_SELF_JUMP_MULT != 1. ? hlChar + '<+${Std.int(stat.BUFF_SELF_JUMP_MULT * 100 - 100)}<%] jump\n' : "";
		str += stat.BUFF_SELF_JUMP_SLOWFALL != 0. ? hlChar + '<+${Std.int(stat.BUFF_SELF_JUMP_SLOWFALL)}] slowfall\n' : "";

		return str;
	}

	public static inline function setStatData(items: Array<CardFaceData>, buff: Bool, tile: Tile, stat: FaceData) {
		for (index=>item in items) {
			var itier = index + 1;
			item.BUFF_SELF_DAMAGE = (stat.BUFF_SELF_DAMAGE ?? 0) * itier;
			item.BUFF_SELF_SPEED = (stat.BUFF_SELF_SPEED ?? 0) * itier;
			item.BUFF_SELF_HEALTH = (stat.BUFF_SELF_HEALTH ?? 0) * itier;
			item.BUFF_SELF_HEALTH_MULT = 1 + (stat.BUFF_SELF_HEALTH_MULT ?? 0) * itier;
			item.BUFF_SELF_JUMP_MULT = 1 + (stat.BUFF_SELF_JUMP_MULT ?? 0) * itier;
			item.BUFF_SELF_JUMP_SLOWFALL = (stat.BUFF_SELF_JUMP_SLOWFALL ?? 0) * itier;
			item.BUFF_SELF_JUMP_EXTRA = Std.int((stat.BUFF_SELF_JUMP_EXTRA ?? 0) * itier);

			if (buff) {
				item.TITLE = generateStatString(item, buff);
			} else {
				item.TITLE = generateStatString(item, buff);
			}

			item.ENEMY_TIERS = item.WEAPON_TIERS = itier;
			item.IMG = tile;
		}
	}

	public static function initDeck() {
		setData([ABERRANT_1, ABERRANT_2, ABERRANT_3], "aberrant", false, [ BadEnemies.ABERRANT ], [], Res.cards.card_aberrant.toTile());
		setData([SPLITTER_1, SPLITTER_2, SPLITTER_3], "splitter", false, [ BadEnemies.SPLITTER ], [], Res.cards.card_splitter.toTile());
		setData([SHOOTER_1, SHOOTER_2, SHOOTER_3], "shooter", false, [ BadEnemies.SHOOTER ], [], Res.cards.card_shooter.toTile());
		setData([SPAWNER_1, SPAWNER_2, SPAWNER_3], "spawner", false, [ BadEnemies.SPAWNER ], [], Res.cards.card_spawner.toTile());

		setData([BURST_1, BURST_2, BURST_3], "burst", true, [], [ SelfWeapons.BURST ], Res.cards.card_burst.toTile());
		setData([TENTACLES_1, TENTACLES_2, TENTACLES_3], "tentacle", true, [], [ SelfWeapons.TENTACLES ], Res.cards.card_tentacles.toTile());
		setData([SPIKES_1, SPIKES_2, SPIKES_3], "spikes", true, [], [ SelfWeapons.SPIKES ], Res.cards.card_spike.toTile());
		setData([PEWPEW_1, PEWPEW_2, PEWPEW_3], "pewpew", true, [], [ SelfWeapons.PEWPEW ], Res.cards.card_pewpew.toTile());

		setStatData([S_RABBIT_1, S_RABBIT_2], true, Res.cards.card_stats.toTile(), {
			BUFF_SELF_JUMP_MULT: 0.5,
			BUFF_SELF_HEALTH: 10,
		});

		setStatData([S_FLASH_1, S_FLASH_2], true, Res.cards.card_stats.toTile(), {
			BUFF_SELF_SPEED: 0.15,
			BUFF_SELF_HEALTH_MULT: 0.1
		});

		setStatData([S_BATS_1, S_BATS_2], true, Res.cards.card_stats.toTile(), {
			BUFF_SELF_JUMP_EXTRA: 1,
			BUFF_SELF_HEALTH: 15,
		});

		setStatData([S_BEARS_1, S_BEARS_2], true, Res.cards.card_stats.toTile(), {
			BUFF_SELF_HEALTH_MULT: 0.4,
			BUFF_SELF_HEALTH: 30,
		});

		isDeckReady = true;
	}
}

class GameCard extends Updatable {
	public var topface : Bitmap;
	public var bottomface : Bitmap;
	var interactive : Interactive;
	var interactiveFlip : Interactive;

	public static var cardCount = 0;

	var ctrlbind : Bitmap;
	var confirmBMP : Bitmap;
	var flipBMP : Bitmap;

	var confirmTXT : CDTextLabel;
	var flipTXT : CDTextLabel;

	var tfData : CardFaceData;
	var bfData : CardFaceData;

	var face = 0;
	var animating = false;
	var changed = false;

	public var weaponCooldown = 0.;
	public var maxWeaponCooldown = 0.;

	public var x(default, set) = 0.;
	public var y(default, set) = 0.;

	public var filter : Null<TrayFilter>;

	public var obj : Object;
	public var rotcont : Object;

	public var hover = 0.;
	public var isHover = false;

	public var scale(default, set) = 1.;
	public var maxWidth = 400.;

	public var cardSheen : CardSheen;
	public var cardSheen2 : CardSheen;

	public var IS_PINNED(get, set): Bool;
	public var IS_LOCKED = false;
	public var IS_REDUNDANT(get, null): Bool;

	public var pinTab : CDTab;
	public var lockTab : CDTab;
	public var upgradeTab : CDTab;

	public var pinDurability = 0;

	public function set_IS_PINNED(pinned) {
		if (pinned) {
			pinDurability = 3;
		}
		return pinned;
	}

	public function get_IS_PINNED() {
		return pinDurability > 0;
	}

	public function get_IS_REDUNDANT() {
		var valid = true;
		var mfd = getFaceData();
		var mindex = 1000;
		for (index=>card in Main.inst.cards) {
			if (card == this) {
				mindex = index;
				continue;
			}
			var fd = card.getFaceData();
			if (fd.UNLOCK_WEAPONS.length > 0 && fd.UNLOCK_WEAPONS[0] == mfd.UNLOCK_WEAPONS[0]) {
				if ((mindex == 1000 && fd.WEAPON_TIERS >= mfd.WEAPON_TIERS)) {
					valid = false;
				}
			}
		}
		return !valid;
	}

	public function getFaceData() {
		return face == 0 ? tfData : bfData;
	}

	public function set_x(v) {
		changed = true;
		if (obj != null) obj.x = x;
		return x = v;
	}

	public function set_y(v) {
		changed = true;
		if (obj != null) obj.y = y;
		return y = v;
	}

	public function set_scale(v) {
		changed = true;
		if (obj != null) obj.setScale(v);
		return scale = v;
	}

	public var bindText: Null<Array<TextCharacter>>;
	public static var unusedBinds = ["N", "X", "B", "J", "K", "L", "H", "M", "Z", "E"];
	
	public inline function hasWeapon() {
		return tfData.UNLOCK_WEAPONS.length > 0 || bfData.UNLOCK_WEAPONS.length > 0;
	}

	public function onCardClick(flipping: Bool) {
		if (filter == DRAW) {
			var mPos = Main.inst.mousePos;
			if (flipping) {
				flipFace();
			} else {
				filter = null;
				Main.inst.pickAtDraw(this);
			}
			return;
		}
	}

	public function new(tfIn: CardFaceData, bfIn: CardFaceData) {
		super(true);

		if (!CardsDeck.isDeckReady) CardsDeck.initDeck();

		tfData = tfIn;
		bfData = bfIn;
		var myBind = unusedBinds.pop() ?? "J";
		if (bfData.BIND == null) bfData.BIND = myBind.charCodeAt(0);
		if (tfData.BIND == null) tfData.BIND = myBind.charCodeAt(0);

		CardFaceData.discoveredFaces.set(tfIn.ID, true);
		CardFaceData.discoveredFaces.set(bfIn.ID, true);

		obj = new Object(Main.inst.s2d);
		rotcont = new Object(obj);

		topface = new Bitmap(tfData.IMG, rotcont);
		bottomface = new Bitmap(bfData.IMG, rotcont);

		pinTab = new CDTab(Main.inst.uisheet.sub(32,32,16,16), 5, obj);
		lockTab = new CDTab(Main.inst.uisheet.sub(64,32,16,16), 5, obj);
		upgradeTab = new CDTab(Main.inst.uisheet.sub(64,48,16,16), 5, obj);

		pinTab.y = lockTab.y = upgradeTab.y = 450;
		pinTab.visible = lockTab.visible = upgradeTab.visible = false;

		if (hasWeapon()) {
			ctrlbind = new Bitmap(Res.bind_card_purple.toTile(), tfData.UNLOCK_WEAPONS.length > 0 ? topface : bottomface);
			// var enembind = new Bitmap(Res.bind_card_blue.toTile(), bottomface);

			// enembind.visible = false;
			ctrlbind.x = 137;
			ctrlbind.y = 525;
			ctrlbind.width = 105;
			
			var interactive2 = new Interactive(105, ctrlbind.getSize().height, ctrlbind);

			interactive2.onClick = (e) -> {
				if (animating) return;
				
				drawControlString('%${String.fromCharCode(tfData.BIND).toLowerCase()}', ctrlbind);
				Main.inst.expectForMe(id);
			}	
		}

		maxWidth = topface.width = bottomface.width = 380;

		var interactive = new Interactive(maxWidth, 255, obj);
		interactiveFlip = new Interactive(maxWidth, 255, interactive);
		interactiveFlip.y = 255;

		var ppp = Main.inst.cardTray.getInitPos();
		obj.x = ppp.x;
		obj.y = ppp.y;

		var text = tfData.TITLE;
		var text2 = bfData.TITLE;

		TextRenderer.draw(text, cast maxWidth, 54, topface);
		TextRenderer.draw(text2, cast maxWidth, 54, bottomface);

		drawControlString('${String.fromCharCode(tfData.BIND).toLowerCase()}', ctrlbind);

		topface.scaleX = 1;
		bottomface.scaleX = 0;
		face = 0;

		cardSheen = new CardSheen();
		cardSheen.angle = 0;

		topface.filter = new Shader(cardSheen, "texture");

		cardSheen2 = new CardSheen();
		cardSheen2.angle = 1;

		bottomface.filter = new Shader(cardSheen2, "texture");

		var mn = Main.inst;
		confirmBMP = new Bitmap(mn.uisheet.sub(80,32,16,16), obj);
		flipBMP = new Bitmap(mn.uisheet.sub(96,32,16,16), obj);
		
		confirmBMP.height = 16 * 5;
		flipBMP.height = 16 * 5;
		
		confirmBMP.alpha = 0.;
		flipBMP.alpha = 0.;
		
		confirmBMP.x = (maxWidth - 80) / 2;
		confirmBMP.y = (255 - 80) / 2 - 10;
		flipBMP.x = (maxWidth - 80) / 2;
		flipBMP.y = 255 + (255 - 80) / 2 - 10;
		confirmTXT = new CDTextLabel(maxWidth, confirmBMP.y + 90, obj);
		flipTXT = new CDTextLabel(maxWidth, flipBMP.y + 90, obj);
		flipTXT.label = "flip";
		confirmTXT.label = "add";

		confirmTXT.alpha = 0.;
		flipTXT.alpha = 0.;

		interactiveFlip.onClick = (e) -> {
			onCardClick(true);
			if (mn.cardTray.CONSUME_CARD_CLICK == null) return;
			// TODO: Maybe render the little badge thing I made depending on the LOCK/PIN condition.
			switch(mn.cardTray.CONSUME_CARD_CLICK) {
				case LOCK:
					if (IS_LOCKED) return;
					IS_LOCKED = true;
					mn.cardTray.setConsumeCardClick(null); // TODO: Do this a bit better.
					mn.locksCount--;
				case FLIP:
					flipFace();
					mn.cardTray.setConsumeCardClick(null); // TODO: Do this a bit better.
					mn.flipsCount--;
				case PIN:
					if (IS_LOCKED || IS_PINNED) return;
					IS_PINNED = true;
					mn.cardTray.setConsumeCardClick(null); // TODO: Do this a bit better.
					mn.pinsCount--;
			}
		}

		interactive.onClick = (e) -> {
			onCardClick(false);
			if (mn.cardTray.CONSUME_CARD_CLICK == null) return;
			// TODO: Maybe render the little badge thing I made depending on the LOCK/PIN condition.
			switch(mn.cardTray.CONSUME_CARD_CLICK) {
				case LOCK:
					if (IS_LOCKED) return;
					IS_LOCKED = true;
					mn.cardTray.setConsumeCardClick(null); // TODO: Do this a bit better.
					mn.locksCount--;
				case FLIP:
					flipFace();
					mn.cardTray.setConsumeCardClick(null); // TODO: Do this a bit better.
					mn.flipsCount--;
				case PIN:
					if (IS_LOCKED || IS_PINNED) return;
					IS_PINNED = true;
					mn.cardTray.setConsumeCardClick(null); // TODO: Do this a bit better.
					mn.pinsCount--;
			}
			// topface.visible = !topface.visible;
			// bottomface.visible = !bottomface.visible;
		}

		interactiveFlip.onOver = interactive.onOver = (e) -> {
			isHover = true;
		}

		interactiveFlip.onOut = interactive.onOut = (e) -> {
			isHover = false;
		}

		Main.inst.addCard(this);
	}

	public function isInterestedInConsumption(cc: CardClickConsumptionReason) {
		switch(cc) {
			case LOCK:
				return !IS_LOCKED;
			case FLIP:
				return !IS_LOCKED && !IS_PINNED;
			case PIN:
				return !IS_LOCKED && !IS_PINNED;
		}
	}

	public function flipFace() {
		if (IS_LOCKED) {
			decayShake = 1.;
			return;
		} // TODO: Make a sexy animation.
		if (IS_PINNED) {
			decayShake = 1.;
			pinDurability--; // TODO: Hide/Show pin.
			return;
		}
		if (animating) return;
		if (face == 0) {
			animating = true;
			Actuate.tween(topface, 0.35, { scaleX: 0 }, true).ease(Circ.easeIn);
			Actuate.tween(cardSheen, 0.35, { angle: 1 }, true).ease(Circ.easeIn);
			Actuate.tween(cardSheen2, 0.35, { angle: 0 }, true).ease(Circ.easeIn);
			Actuate.tween(bottomface, 0.35, { scaleX: 1 }, true).delay(0.35).ease(Circ.easeOut).onComplete(() -> {
				face = 1; // TODO: Move this somewhere else.
				Main.inst.cardsChanged = true;
				animating = false;
			});
		} else if (face == 1) {
			animating = true;
			Actuate.tween(bottomface, 0.35, { scaleX: 0 }, true).ease(Circ.easeIn);
			Actuate.tween(cardSheen, 0.35, { angle: 0 }, true).ease(Circ.easeIn);
			Actuate.tween(cardSheen2, 0.35, { angle: 1 }, true).ease(Circ.easeIn);
			Actuate.tween(topface, 0.35, { scaleX: 1 }, true).delay(0.35).ease(Circ.easeOut).onComplete(() -> {
				face = 0;
				Main.inst.cardsChanged = true;
				animating = false;
			});
		}
	}

	public function drawControlString(text: String, parent: Null<Object>) {
		if (parent == null) return;
		if (bindText != null) {
			for (index => value in bindText) {
				value.remove();
			}
		}
		bindText = TextRenderer.draw(text, 105, 14, parent, CONTROLS);
	}

	public var time = 0.;
	public var decayShake = 0.;

	override public function update(dt:Float) {
		time += dt;
		decayShake = Math.clamp(decayShake - dt, 0, 1);

		weaponCooldown -= dt;

		var currentData = getFaceData();
		if (currentData.UNLOCK_WEAPONS.length > 0 && weaponCooldown <= 0 && Main.inst.consumeK(currentData.BIND)) {
			for (index => value in currentData.UNLOCK_WEAPONS) {
				var spent = WeaponUser.useWeapon(value, currentData.WEAPON_TIERS);
				if (spent >= weaponCooldown) {
					maxWeaponCooldown = spent;
					weaponCooldown = spent;
				}
			}
		}

		var easeDS = 1 - (1 - decayShake) * (1 - decayShake);
		lockTab.bmp.x = Math.sin(decayShake * Math.PI * 15) * 3 * easeDS;
		pinTab.bmp.x = Math.sin(decayShake * Math.PI * 15) * 3 * easeDS;

		var isrd = IS_REDUNDANT;
		if ((IS_PINNED != pinTab.visible) || (IS_LOCKED != lockTab.visible) || (isrd != upgradeTab.visible)) {
			var xOff = 0;

			pinTab.visible = IS_PINNED;
			pinTab.x = 16 * 5 * (xOff);
			xOff += IS_PINNED ? 1 : 0;

			lockTab.visible = IS_LOCKED;
			lockTab.x = 16 * 5 * (xOff);
			xOff += IS_LOCKED ? 1 : 0;

			upgradeTab.visible = isrd;
			upgradeTab.x = 16 * 5 * (xOff);
			xOff += isrd ? 1 : 0;
		}

		if (filter == DRAW) {
			var mPos = Main.inst.mousePos;
			var inFlip = (mPos.y > rotcont.getAbsPos().y);
			confirmBMP.alpha = Math.lerp(confirmBMP.alpha, Math.clamp(inFlip ? hover * .5 : hover,0.25,1), 0.08);
			confirmTXT.alpha = Math.lerp(confirmTXT.alpha, Math.clamp(inFlip ? hover * .5 : hover,0.25,1), 0.08);
			flipBMP.alpha = Math.lerp(flipBMP.alpha, Math.clamp(inFlip ? hover : hover * .5,0.25,1), 0.08);
			flipTXT.alpha = Math.lerp(flipTXT.alpha, Math.clamp(inFlip ? hover : hover * .5,0.25,1), 0.08);
			if (ctrlbind != null) ctrlbind.alpha = 0.;
		} else {
			confirmBMP.alpha = 0;
			flipBMP.alpha = 0;
			confirmTXT.alpha = 0;
			flipTXT.alpha = 0;
			if (ctrlbind != null) ctrlbind.alpha = Math.lerp(ctrlbind.alpha, 1., 0.08);
			// Clean up.
		}

		var ctrl = Main.inst.getExpectedControl(id);
		if (ctrl != null) {
			getFaceData().BIND = ctrl;
			drawControlString('${String.fromCharCode(getFaceData().BIND).toLowerCase()}', ctrlbind);
		}

		if (changed) {
			changed = false;
		}

		if (isHover) {
			hover = Math.min((hover + 0.07) * 1.08, 1);
		} else {
			hover = Math.max((hover - 0.05) * 0.95, 0);
		}
		
		var hfmw = 0.5 * maxWidth;

		rotcont.x = hfmw;
		rotcont.y = hfmw;

		bottomface.x = /* x + */ (0.5 - bottomface.scaleX * 0.5) * maxWidth - hfmw;
		bottomface.y = /* y + */ (0.5 - bottomface.scaleY * 0.5) * maxWidth - hover * 6 - hfmw;

		topface.x = /* x + */ (0.5 - topface.scaleX * 0.5) * maxWidth - hfmw;
		topface.y = /* y + */ (0.5 - topface.scaleY * 0.5) * maxWidth - hover * 6 - hfmw;
	}

	override public function remove() {
		super.remove();
		obj.remove();
	}
}