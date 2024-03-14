import h2d.Scene.ScaleModeAlign;
import hxsl.Types.Vec4;
import Button.CDTextLabel;
import CardTray.CardClickConsumptionReason;
import TextRenderer.TextCharacter;
import Button.CDButton;
import h2d.Object;
import hxd.Math;
import GameCard.TrayFilter;
import h2d.Layers;
import GameCard.CardsDeck;
import h2d.Tile;
import h2d.Bitmap;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2World;
import hxd.Res;
import h3d.prim.ModelCache;
import hxmath.math.Vector2;
import h3d.col.Plane;
import hxmath.math.Vector3;
import h3d.pass.DirShadowMap;
import h3d.scene.fwd.DirLight;
import hxd.Event;
import hxd.Window;
import h3d.col.Bounds;
import h3d.Vector;

enum RoundState {
	MAIN_MENU;
	ALMANAC;
	TRANSITIONS;
	INIT_CARD_DRAW;
	CARD_DRAW;
	SHOW_CARDS;
	SIDE_0;
	SIDE_BETWEEN;
	SIDE_1;
	SIDE_END;
	DEATH_SCREEN;
}

class Main extends hxd.App {

	public var UIDRES = 1;
	public function getNextUID() {
		return UIDRES++;
	}

	public var cards : Array<GameCard> = [];
	public var cardsChanged = false;
	public var enemies : Map<Int, Dynamic> = new Map();

	public var char : Character;
	public var world : B2World;
	public var roadCount : Int = 0;
	public var pavementCount : Int = 0;
	public var cardTray : CardTray;

	public var FLOOR = 50;

	public var stage : Layers;
	public var dimmer : Bitmap;

	public var cardbuttons : Object;

	public var cache : ModelCache;

	public var pinsCount(default, set) = 0;
	public var flipsCount(default, set) = 0;
	public var locksCount(default, set) = 0;

	public function set_pinsCount(v) {
		cdbuttonPin.toplabel = v > 0 ? '${v}' : " ";
		cdbuttonPin.enabled = v > 0;
		return pinsCount = v;
	}

	public function set_flipsCount(v) {
		cdbuttonFlip.toplabel = v > 0 ? '${v}' : " ";
		cdbuttonFlip.enabled = v > 0;
		return flipsCount = v;
	}

	public function set_locksCount(v) {
		cdbuttonLock.toplabel = v > 0 ? '${v}' : " ";
		cdbuttonLock.enabled = v > 0;
		return locksCount = v;
	}

	public var cdbuttonPin : CDButton;
	public var cdbuttonFlip : CDButton;
	public var cdbuttonLock : CDButton;

	public var mainMenuMainButtons : Object;
	public var mainMenuAlmanac : Object;
	public var mainMenuBackButton : CDButton;

	public var cdmenuButtonPlay : CDButton;
	public var cdmenuButtonOptions : CDButton;
	public var cdmenuButtonAlmanac : CDButton;

	public var cdTitle0 : CDTextLabel;
	public var cdTitle1 : CDTextLabel;
	public var cdTitle2 : CDTextLabel;
	public var cdTitle3 : CDTextLabel;

	public var cddiedContainer : Object;
	public var cdDied1 : CDTextLabel;
	public var cdDied2 : CDTextLabel;
	public var cdDied3 : CDTextLabel;


	public var cdMainMenu : Bitmap;

	public var healthbar : Healthbar;

	public var uisheet : Tile;

	public function addCard(card: GameCard) {
		cards.push(card);
		cardsChanged = true;
	}

	override function init() {
		cache = new h3d.prim.ModelCache();

		// engine.autoResize = false;
		// engine.resize(480, 270); // 640, 360 // 480, 270
		// engine.resize(315, 250); // for thumbs.

		// s3d.camera.pos = new Vector(50,50,15);

		// var zoom = Math.min(engine.height, engine.width) / 12; // ZOOM = 8;
		// s3d.camera.orthoBounds = Bounds.fromValues(-engine.width / zoom / 2, -engine.height / zoom / 2, -99, engine.width / zoom, engine.height / zoom, 999);

		s2d.scaleMode = Stretch(1600, 1024);
		world = new B2World(new B2Vec2(0,15.), true);

		#if js
        Res.initEmbed();
        #else
        Res.initLocal();
        #end

		var background1 = new Bitmap(Res.background.toTile(), s2d);
		background1.width = 1600;
		background1.height = 512;
		var background2 = new Bitmap(Res.background.toTile(), s2d);
		background2.width = 1600;
		background2.height = 512;

		background2.y = 512;

		var ground = new Bitmap(Tile.fromColor(0x11002A, 1, 1, 1.), s2d);
		ground.x = 0;
		ground.y = 1014;
		ground.width = 1600;
		ground.height = 10;

		var ground2 = new Bitmap(Tile.fromColor(0x11002A, 1, 1, 1.), s2d);
		ground2.x = 0;
		ground2.y = 502;
		ground2.width = 1600;
		ground2.height = 10;

		
		stage = new Layers(s2d);
		stage.y = 512;

		dimmer = new Bitmap(Tile.fromColor(0x000000, 1, 1, 1.), s2d);
		dimmer.height = 1024;
		dimmer.width = 1600;
		dimmer.alpha = 0.;

		uisheet = Res.ui_elements.toTile();
		cardbuttons = new Object(s2d);


		cdbuttonPin = new CDButton(uisheet.sub(32,16,16,16), 5, cardbuttons);
		cdbuttonFlip = new CDButton(uisheet.sub(48,16,16,16), 5, cardbuttons);
		cdbuttonLock = new CDButton(uisheet.sub(64,16,16,16), 5, cardbuttons);
		
		cdbuttonFlip.x = 100;
		cdbuttonLock.x = 200;

		cdbuttonPin.enabled = false;
		cdbuttonFlip.enabled = false;
		cdbuttonLock.enabled = false;

		cdbuttonPin.toplabel = " ";
		cdbuttonFlip.toplabel = " ";
		cdbuttonLock.toplabel = " ";

		cdTitle0 = new CDTextLabel(800, 0, s2d);

		cdTitle0.label = "these are your starter cards";
		cdTitle0.setScale(2);
		cdTitle0.y = 1040;

		var cdTitle5 = new CDTextLabel(800, 30, cdTitle0);

		cdTitle5.label = "one weapon and one enemy";

		cdTitle1 = new CDTextLabel(800, 0, s2d);

		cdTitle1.label = "manage deck";
		cdTitle1.setScale(2);

		cdTitle1.y = -200;

		cdTitle3 = new CDTextLabel(1600, 0, cdTitle1);

		cdTitle3.label = "press *space] to continue";

		cdTitle3.setScale(0.5);

		cdTitle3.y = 35;

		cdTitle2 = new CDTextLabel(800, 0, s2d);

		cdTitle2.label = "draw card";
		cdTitle2.setScale(2);

		cdTitle2.y = -200;

		var bnds = cardbuttons.getBounds();
		cardbuttons.x = (1600 - bnds.width) / 2;
		cardbuttons.y = -200;

		var currText : Array<TextCharacter> = [];

		cddiedContainer = new Object(s2d);
		cdDied1 = new CDTextLabel(800, 0, cddiedContainer);
		cdDied1.setScale(2);
		cdDied1.label = "you died";
		cdDied2 = new CDTextLabel(1600, 70, cddiedContainer);
		cdDied2.setScale(1);
		cdDied2.label = 'you killed *${80}] aberrants';
		cdDied3 = new CDTextLabel(1600, 110, cddiedContainer);
		cdDied3.setScale(1);
		cdDied3.label = "check the *almanac] to see all your unlocked cards";

		cddiedContainer.y = 1024;
		
		cdMainMenu = new Bitmap(Res.main_menu.toTile(), s2d);
		cdMainMenu.height = 1024;
		cdMainMenu.width = 1600;
		cdMainMenu.color = new Vec4(0.9,0.9,0.9,1.);


		mainMenuMainButtons = new Object(cdMainMenu);

		var baseOffset = 390;
		var logo = new CDButton(Res.ingame_logo.toTile(), 4, mainMenuMainButtons);
		logo.x = ((48 * 8) - (144 * 4)) / 2;
		logo.y = 60;

		cdmenuButtonPlay = new CDButton(uisheet.sub(208,32,48,16), 8, mainMenuMainButtons);
		cdmenuButtonPlay.y = baseOffset;
		cdmenuButtonAlmanac = new CDButton(uisheet.sub(208,0,48,16), 8, mainMenuMainButtons);
		cdmenuButtonAlmanac.y = baseOffset + (128 + 20);
		cdmenuButtonOptions = new CDButton(uisheet.sub(208,16,48,16), 8, mainMenuMainButtons);
		cdmenuButtonOptions.y = baseOffset + (128 + 20) * 2;

		cdmenuButtonAlmanac.enabled = true;
		cdmenuButtonOptions.enabled = false;

		mainMenuAlmanac = new Object(cdMainMenu);
		mainMenuBackButton = new CDButton(uisheet.sub(208,64,32,16), 8, cdMainMenu);
		mainMenuBackButton.x = (1600 - (32 * 8)) / 2;
		mainMenuBackButton.y = 1024;

		// cdmenuButtonPlay = new CDButton(uisheet.sub(208,32,48,16), 8, mainMenuMainButtons);


		var credit = new Bitmap(uisheet.sub(208,49,48,15), mainMenuMainButtons);
		credit.width = 48 * 6;
		credit.x = 48;
		credit.y = baseOffset + (128 + 20) * 3;

		mainMenuMainButtons.x = (1600 - 48 * 8) / 2;

		cdmenuButtonPlay.onClick = () -> {
			dimmer.alpha = 1.;
			roundState = TRANSITIONS;
			needsRoundStateInit = true;
		}

		cdmenuButtonAlmanac.onClick = () -> {
			dimmer.alpha = 1.;
			roundState = ALMANAC;
			needsRoundStateInit = true;
		}

		mainMenuBackButton.onClick = () -> {
			dimmer.alpha = 1.;
			miniTray?.remove();
			miniTray = null;
			roundState = MAIN_MENU;
			needsRoundStateInit = true;
		}

		cdbuttonPin.onClick = () -> {
			if (pinsCount > 0) {
				cardTray.setConsumeCardClick(CardClickConsumptionReason.PIN);
			} else if (cardTray.CONSUME_CARD_CLICK == CardClickConsumptionReason.PIN) {
				cardTray.setConsumeCardClick(null);
			}
		}

		cdbuttonFlip.onClick = () -> {
			if (flipsCount > 0) {
				cardTray.setConsumeCardClick(CardClickConsumptionReason.FLIP);
			} else if (cardTray.CONSUME_CARD_CLICK == CardClickConsumptionReason.FLIP) {
				cardTray.setConsumeCardClick(null);
			}
		}

		cdbuttonLock.onClick = () -> {
			if (locksCount > 0) {
				cardTray.setConsumeCardClick(CardClickConsumptionReason.LOCK);
			} else if (cardTray.CONSUME_CARD_CLICK == CardClickConsumptionReason.LOCK) {
				cardTray.setConsumeCardClick(null);
			}
		}

		cdbuttonPin.onOver = () -> {
			for (index => value in currText) {
				value.fadeout();
			}
			currText = TextRenderer.draw(">*pin ]a card onto a specific face for *3] aberrations", Std.int(bnds.width), 100, cardbuttons, TITLES);
		}

		cdbuttonPin.onOut = cdbuttonLock.onOut = cdbuttonFlip.onOut = () -> {
			for (index => value in currText) {
				value.fadeout();
			}
			currText = [];
		}

		cdbuttonFlip.onOver = () -> {
			for (index => value in currText) {
				value.fadeout();
			}
			currText = TextRenderer.draw(">*flip ]the face of an unlocked card", Std.int(bnds.width), 100, cardbuttons, TITLES);
		}

		cdbuttonLock.onOver = () -> {
			for (index => value in currText) {
				value.fadeout();
			}
			currText = TextRenderer.draw(">*lock ]a card onto a specific face permanently", Std.int(bnds.width), 100, cardbuttons, TITLES);
		}

		new Character();
		
		// MobFactory.createMob(ABERRANT, 1);
		// MobFactory.createMob(ABERRANT, 1);
		// MobFactory.createMob(ABERRANT, 2);
		// MobFactory.createMob(ABERRANT, 3);
		// MobFactory.createMob(ABERRANT, 3);
		// MobFactory.createMob(SPLITTER, 3);
		// MobFactory.createMob(SPLITTER, 3);

		cardTray = new CardTray();

		healthbar = new Healthbar();
		healthbar.y = 256;
		healthbar.x = -128;

		// card.visible = false;

		Window.getInstance().addEventTarget(handleEvent);

		// TODO: Play music well, add volume slider.
		// var chn = Res.audio.theme.play(true, 1.);
		// trace(chn.duration);

		start();
	}

	private var downMap = new Map<Int, Bool>();
	private var downPMap = new Map<Int, Bool>();
	private var downALPHAMap = new Map<Int, Bool>();
	private var downALPHAPMap = new Map<Int, Bool>();
	private var hovered = new Vector2(0,0);
	public var mousePos = new Vector2(0,0);
	public var mousePoint = new Vector3(0,0,0);
	public var isM1Down = false;
	public var isM2Down = false;

	public var downT = 0.;
	public var downPoint: Vector3;
	public var clickThisFrame = false;

	public function isKDown(key: Int) {
		return downMap.get(key) ?? false;
	}

	public function consumeK(key: Null<Int>) {
		if (key == null) return false;
		var yes = downPMap.get(key);
		if (yes) downPMap.remove(key);
		return yes;
	}

	public function isALPHAKDown(key: Int) {
		return downALPHAMap.get(key) ?? false;
	}

	public function consumeALPHAK(key: Int) {
		var yes = downALPHAPMap.get(key);
		if (yes) downALPHAPMap.remove(key);
		return yes;
	}

	public var heldForExpectedControl: Null<Int>;
	public var currentlyExpectingControl: Null<Int>;
	public function expectForMe(id: Int): Bool {
		if (currentlyExpectingControl == null) {
			currentlyExpectingControl = id;
			return true;
		}
		return false;
	}

	public function getExpectedControl(id: Int): Null<Int> {
		if (id == currentlyExpectingControl && currentlyExpectingControl != null) {
			if (heldForExpectedControl != null) {
				var n = heldForExpectedControl;
				heldForExpectedControl = null;
				currentlyExpectingControl = null;
				return n;
			}
			return null;
		}
		return null;
	}

	public function handleEvent(ev: Event) {
		switch(ev.kind) {
			case EKeyDown:
				if (currentlyExpectingControl != null) {
					heldForExpectedControl = ev.keyCode;
					return;
				}
				trace(ev.keyCode, ev.charCode);
				if (!downMap.get(ev.keyCode)) {
					downMap.set(ev.keyCode, true);
					downPMap.set(ev.keyCode, true);
				}
			case ETextInput:
			case EKeyUp:
				if (currentlyExpectingControl != null) {
					if (heldForExpectedControl == ev.keyCode) {
						heldForExpectedControl = null;
					}
				}
				downMap.set(ev.keyCode, false);
				downPMap.set(ev.keyCode, false);
			case EPush:
				if (ev.button == 0) {
					isM1Down = true;
					downT = time;
					downPoint = mousePoint;
				} else {
					isM2Down = true;
				}
			case ERelease:
				if (ev.button == 0) {	
					isM1Down = false;
				} else {
					isM2Down = false;
				}
				if (time - downT < 5 && (downPoint - mousePoint).length < 2) {
					clickThisFrame = true;
				}
			case EMove:
				mousePos.x = (ev.relX / Window.getInstance().width) * engine.width;
				mousePos.y = (ev.relY / Window.getInstance().height) * engine.height;
			case _:
		}
	}

	public function log( s : String, ?pos : haxe.PosInfos ) {
		haxe.Log.trace(s, pos);
	}

	function start() {
		log("Live");
	}

	public var isDrawDone = false;
	public function pickAtDraw(card : GameCard) {
		var tmpCrds = [];
		for (index => value in cards) {
			if (value.filter != DRAW) {
				tmpCrds.push(value);
			} else {
				value.remove();
			}
		}
		cards = tmpCrds;
		isDrawDone = true;
	}

	public var time = 0.;
	public var timeOfRoundStateStart : Null<Float> = 0.;

	public var readyForRoundStart = false;
	public var roundState : RoundState = MAIN_MENU;
	public var needsRoundStateInit = true;
	public var roundN = 1;

	public var playthroughN = 0;

	public var miniTray : MiniTray;

	public var _dt = 0.03;
	override function update(dt:Float) {
		_dt = dt;
		time += dt;
		world.step(1 / 60, 6, 3);

		Updatable.updateEntities(dt);
		cardTray.update(dt);

		if (readyForRoundStart && roundState == MAIN_MENU) {
			readyForRoundStart = false;
			cardTray.setTransition(LEFT_SCREEN_BOTTOM);
			cdMainMenu.visible = true;
		}

		if (isM2Down) {
			if (cardTray.CONSUME_CARD_CLICK != null) {
				cardTray.setConsumeCardClick(null);
			}
		}

		switch(roundState) {
			case TRANSITIONS:
				dimmer.alpha = Math.lerp(dimmer.alpha, 0.4, 0.02);
				cdMainMenu.visible = false;
				mainMenuMainButtons.x = 1600;

			case INIT_CARD_DRAW:
				dimmer.alpha = Math.lerp(dimmer.alpha, 0.4, 0.05);
			case CARD_DRAW:
				cdTitle2.y = Math.lerp(cdTitle2.y, 40, 0.07);

				dimmer.alpha = Math.lerp(dimmer.alpha, 0.4, 0.05);
			case SHOW_CARDS:
				cdTitle2.y = Math.lerp(cdTitle2.y, -200, 0.08);
				cdTitle1.y = Math.lerp(cdTitle1.y, 40, 0.07);
				cdTitle3.alpha = 0.9 + Math.sin(time * 3) * 0.1;

				healthbar.x = Math.lerp(healthbar.x, -128, 0.08);
				cardbuttons.y = Math.lerp(cardbuttons.y, 300, 0.05) + Math.sin(time * 1.5) * 0.8;
				dimmer.alpha = Math.lerp(dimmer.alpha, 0.5, 0.05);
			case SIDE_0:
				healthbar.x = Math.lerp(healthbar.x, 0, 0.08);
				cdTitle1.y = Math.lerp(cdTitle1.y, -200, 0.08);

				cardbuttons.y = Math.lerp(cardbuttons.y, -200, 0.05);
				dimmer.alpha = Math.lerp(dimmer.alpha, 0, 0.05);
			case SIDE_BETWEEN:
				healthbar.x = Math.lerp(healthbar.x, -128, 0.08);
				dimmer.alpha = Math.lerp(dimmer.alpha, 0.4, 0.05);
			case SIDE_1:
				healthbar.x = Math.lerp(healthbar.x, 0, 0.08);
				dimmer.alpha = Math.lerp(dimmer.alpha, 0, 0.05);
			case SIDE_END:
				healthbar.x = Math.lerp(healthbar.x, -128, 0.08);
				dimmer.alpha = Math.lerp(dimmer.alpha, 0.4, 0.05);
			case DEATH_SCREEN:
				healthbar.x = Math.lerp(healthbar.x, -128, 0.08);
				dimmer.alpha = Math.lerp(dimmer.alpha, 0.5, 0.05);
				cddiedContainer.y = Math.lerp(cddiedContainer.y, (1024 - 300) / 2, 0.05);
			case MAIN_MENU:
				healthbar.x = -128;
				dimmer.alpha = 0.1;
				cdMainMenu.visible = true;
				mainMenuMainButtons.x = Math.lerp(mainMenuMainButtons.x, (1600 - 48 * 8) / 2, 0.08);
				mainMenuMainButtons.y = Math.pow(Math.sin(time * 1.4), 1) * 17;
				mainMenuBackButton.y = Math.lerp(mainMenuBackButton.y, 1024, 0.1);
				cddiedContainer.y = Math.lerp(cddiedContainer.y, 1024, 0.08);
				mainMenuAlmanac.x = Math.lerp(mainMenuAlmanac.x, 1600, 0.1);
			case ALMANAC:
				mainMenuMainButtons.x = Math.lerp(mainMenuMainButtons.x, -1600, 0.1);
				mainMenuBackButton.y = Math.lerp(mainMenuBackButton.y, 880, 0.1);
				mainMenuAlmanac.x = Math.lerp(mainMenuAlmanac.x, 0, 0.1);
				if (miniTray != null) miniTray.y = (1024 - miniTray.getBounds().height) / 2;
			}

		if (roundState == ALMANAC && needsRoundStateInit) {
			needsRoundStateInit = false;
			var allCards = [];
			for (d in [CardsDeck.DRAW_RNDS_1_5, CardsDeck.DRAW_RNDS_6_12, CardsDeck.DRAW_RNDS_13_20]) {
				for (v in d) {
					for (c in v) {
						if (!allCards.contains(c)) allCards.push(c);
					}
				}
			}
			miniTray = new MiniTray(s2d, cast allCards, 800, 4, true, true);
			miniTray.setScale(1.5);
			miniTray.x = 200;
			miniTray.y = (1024 - miniTray.getBounds().height) / 2;
		}

		if (roundState == TRANSITIONS && cardTray.transitioningTo == null && needsRoundStateInit) {
			roundState = INIT_CARD_DRAW;
			needsRoundStateInit = true;
		}

		if (roundState == INIT_CARD_DRAW && needsRoundStateInit) {
			needsRoundStateInit = false;
			CardsDeck.getStarterCards();
			cardsChanged = true;
			timeOfRoundStateStart = time;
			cardTray.setTransition(CENTER_SCREEN_CENTER, TrayFilter.INIT_DRAW);
		}

		if (roundState == INIT_CARD_DRAW && cardTray.transitioningTo == null && (time - timeOfRoundStateStart) > 3.) {
			roundState = SHOW_CARDS;
			cardTray.setTransition(CENTER_SCREEN_BOTTOM);
			needsRoundStateInit = true;
		}

		var spaceDown = isKDown(32);
		if (roundState == SHOW_CARDS && spaceDown /* SPACE */) {
			roundState = SIDE_0;
			cardTray.setTransition(LEFT_SCREEN_BOTTOM);
			needsRoundStateInit = true;
			Main.inst.char.hp = Main.inst.char.maxHp;
			healthbar.lastRecordedHP = 0.;
			miniTray = new MiniTray(s2d, cast cards, 1066, 4, true);
			miniTray.setScale(1.5);
			miniTray.y = 512 + (512 - miniTray.getBounds().height) / 2;
		}

		if (roundState == SIDE_0 && needsRoundStateInit && cardTray.transitioningTo == null) {
			MobFactory.getMobsForRound(roundN);
			needsRoundStateInit = false;
			char.shown = true;
			stage.y = 0;
		}

		if (roundState == SIDE_0 && !needsRoundStateInit) {
			var i = 0;
			for (enemy in enemies) {
				i++;
			}
			if (i == 0) {
				roundState = SIDE_BETWEEN;
				needsRoundStateInit = true;
				miniTray.remove();
				miniTray = null;
			}
		}

		if (roundState == SIDE_BETWEEN && needsRoundStateInit) {
			cardTray.setTransition(CENTER_SCREEN_CENTER);
			char.shown = false;
			
			timeOfRoundStateStart = null;
			needsRoundStateInit = false;
		}

		if (roundState == SIDE_BETWEEN && timeOfRoundStateStart == null && cardTray.transitioningTo == null && !needsRoundStateInit) {
			for (index => value in cards) {
				value.flipFace();
			}
			timeOfRoundStateStart = time;
		}

		if (roundState == SIDE_BETWEEN && timeOfRoundStateStart != null && !needsRoundStateInit && time - timeOfRoundStateStart > 2) {
			cardTray.setTransition(LEFT_SCREEN_CENTER);
			roundState = SIDE_1;
			needsRoundStateInit = true;
			timeOfRoundStateStart = null;
			miniTray = new MiniTray(s2d, cast cards, 800, 4, true);
			miniTray.setScale(2);
			miniTray.y = (512 - miniTray.getBounds().height) / 2;
		}
		
		if ((roundState == SIDE_1 || roundState == SIDE_0) && char.hp <= 0) {
			miniTray?.remove();
			needsRoundStateInit = true;
			roundState = DEATH_SCREEN;
		}

		if (roundState == DEATH_SCREEN && needsRoundStateInit) {
			needsRoundStateInit = false;
			char.shown = false;
			cdDied2.label = 'you killed *${BaseAberrant.KILLS_SO_FAR}] aberrants';
			BaseAberrant.KILLS_SO_FAR = 0;
			GameCard.unusedBinds = ["N", "X", "B", "J", "K", "L", "H", "M", "Z", "E"];
			timeOfRoundStateStart = time;
			playthroughN++;
			miniTray = new MiniTray(cddiedContainer, cast cards, 1600, 4, false);
			miniTray.setScale(1);
			miniTray.y = 200;
		}

		if (roundState == DEATH_SCREEN && (time - timeOfRoundStateStart) > 6.) {
			roundState = MAIN_MENU;
			needsRoundStateInit = true;
			for (card in cards) {
				card.remove();
			}
			cards = [];
			miniTray.remove();
		}

		if (roundState == SIDE_1 && needsRoundStateInit) {
			needsRoundStateInit = false;
			MobFactory.getMobsForRound(roundN);
			char.shown = true;
			stage.y = 512;
		}
		
		if (roundState == SIDE_1 && !needsRoundStateInit) {
			var i = 0;
			for (enemy in enemies) {
				i++;
			}
			if (i == 0) {
				roundState = SIDE_END;
				needsRoundStateInit = true;
				cardTray.setTransition(CENTER_SCREEN_CENTER_2);
				char.shown = false;
				miniTray.remove();
				miniTray = null;
			}
		}

		if (roundState == SIDE_END && timeOfRoundStateStart == null && cardTray.transitioningTo == null && needsRoundStateInit) {
			for (index => value in cards) {
				value.flipFace();
			}
			timeOfRoundStateStart = time;
			needsRoundStateInit = false;
		}

		if (roundState == SIDE_END && timeOfRoundStateStart != null && !needsRoundStateInit && time - timeOfRoundStateStart > 2) {
			roundState = CARD_DRAW;
			needsRoundStateInit = true;
			timeOfRoundStateStart = null;
		}

		if (roundState == CARD_DRAW && needsRoundStateInit) {
			// TODO: Generate cards for draw.
			needsRoundStateInit = false;
			isDrawDone = false;
			CardsDeck.getDraw(roundN);
			cardTray.setTransition(CENTER_SCREEN_CENTER, TrayFilter.DRAW);
		}

		if (roundState == CARD_DRAW && isDrawDone && !needsRoundStateInit) {
			roundState = SHOW_CARDS;
			cardTray.setTransition(CENTER_SCREEN_BOTTOM);
			needsRoundStateInit = true;
		}

		clickThisFrame = false;
	}

	public function new() {
		super();
		inst = this;
	}

	public static var inst : Main;
	static function main() {
		new Main();
	}

}