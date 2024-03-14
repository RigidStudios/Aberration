import GameCard.TrayFilter;
import hxd.Math;
import hxmath.math.Vector2;

enum CardTrayLayoutStep {
	LEFT_SCREEN_TOP;
	LEFT_SCREEN_CENTER;
	LEFT_SCREEN_BOTTOM;
	CENTER_SCREEN_TOP;
	CENTER_SCREEN_BOTTOM;
	CENTER_SCREEN_CENTER;
	CENTER_SCREEN_CENTER_2;
}

enum CardClickConsumptionReason {
	LOCK;
	FLIP;
	PIN;
}

class CardTray {
	public function new() {}

	public var cards(get, null): Array<GameCard>;

	public function get_cards() {
		return Main.inst.cards;
	}

	public var goingToStartState = 0.;
	public var transitioningTo : Null<CardTrayLayoutStep>;
	public var currentlyAt : Null<CardTrayLayoutStep>;
	public var cardFilter : Null<TrayFilter>;

	public var BUFF_SELF_SPEED = 1.;
	public var BUFF_SELF_HEALTH = 1.;
	public var BUFF_SELF_HEALTH_MULT = 1.;
	public var BUFF_SELF_JUMP_EXTRA = 1;
	public var BUFF_SELF_JUMP_MULT = 1.;
	public var BUFF_SELF_JUMP_SLOWFALL = 1.;
	public var BUFF_SELF_DAMAGE = 1.;

	public var CONSUME_CARD_CLICK: Null<CardClickConsumptionReason>;
	public var wasChangeFrame = false;

	public function setConsumeCardClick(cc: Null<CardClickConsumptionReason>) {
		wasChangeFrame = true;
		CONSUME_CARD_CLICK = cc;
	}

	public function setTransition(state : CardTrayLayoutStep, ?filter : TrayFilter) {
		transitioningTo = state;
		cardFilter = filter;
		goingToStartState = 0.;
	}

	public function getInitPos(): Vector2 {
		if (currentlyAt == null) return new Vector2(-500,0);
		return switch (currentlyAt) {
			case LEFT_SCREEN_TOP: new Vector2(-500,26);
			case LEFT_SCREEN_CENTER: new Vector2(-500,308);
			case LEFT_SCREEN_BOTTOM: new Vector2(-500,538);
			case CENTER_SCREEN_BOTTOM: new Vector2(-500, 538);
			case CENTER_SCREEN_CENTER: new Vector2(-500, 308);
			case CENTER_SCREEN_CENTER_2: new Vector2(-500, 308);
			case CENTER_SCREEN_TOP: new Vector2(-500, 26);
		}
	}

	public function update(dt: Float) {
		var mn = Main.inst;

		if (mn.cardsChanged) {
			BUFF_SELF_SPEED = 1;
			BUFF_SELF_HEALTH = 1;
			BUFF_SELF_HEALTH_MULT = 1;
			BUFF_SELF_JUMP_EXTRA = 1;
			BUFF_SELF_JUMP_MULT = 1;
			BUFF_SELF_JUMP_SLOWFALL = 1;
			BUFF_SELF_DAMAGE = 1;
			for (card in cards) {
				var data = card.getFaceData();
				BUFF_SELF_SPEED += data.BUFF_SELF_SPEED;
				BUFF_SELF_HEALTH += data.BUFF_SELF_HEALTH;
				BUFF_SELF_HEALTH_MULT *= data.BUFF_SELF_HEALTH_MULT;
				BUFF_SELF_JUMP_EXTRA += data.BUFF_SELF_JUMP_EXTRA;
				BUFF_SELF_JUMP_MULT *= data.BUFF_SELF_JUMP_MULT;
				BUFF_SELF_JUMP_SLOWFALL += data.BUFF_SELF_JUMP_SLOWFALL;
				BUFF_SELF_DAMAGE += data.BUFF_SELF_DAMAGE;
			}
		}

		if (CONSUME_CARD_CLICK != null) {
			for (card in cards) {
				if (card.isInterestedInConsumption(CONSUME_CARD_CLICK))
					card.rotcont.rotation = Math.sin(Main.inst.time * 2.5) * 0.1;
			}
		} else if (wasChangeFrame) {
			for (card in cards) {
				card.rotcont.rotation = 0;
			}
		}

		var done = true;
		if (transitioningTo == null) return;

		var matchesFilter = cardFilter == null ? cards : cards.filter(f -> f.filter == cardFilter);

		var wrapAt = 5;
		var maxCardSize = matchesFilter.length > wrapAt ? 0.4 : 0.8;
		var correctStandardScale = matchesFilter.length > wrapAt ? 152 : 304;
		var maxWidthAtStandardScale = correctStandardScale * Math.min(matchesFilter.length, 5);
		var index = 0;
		for (card in cards) {
			if (cardFilter != null && cardFilter != card.filter) {
				card.x = Math.lerp(card.x, -500, .12);
				if (Math.abs(card.x - (-500)) > 1) done = false;
				continue;
			}

			var target = switch (transitioningTo) {
				case LEFT_SCREEN_TOP: new Vector2(-500,26);
				case LEFT_SCREEN_CENTER: new Vector2(-500,308);
				case LEFT_SCREEN_BOTTOM: new Vector2(-500,538);
				case CENTER_SCREEN_BOTTOM: new Vector2((1600 - maxWidthAtStandardScale) / 2 + (index % wrapAt) * correctStandardScale, 538 + 234 * Math.floor(index / wrapAt));
				case CENTER_SCREEN_CENTER: new Vector2((1600 - maxWidthAtStandardScale) / 2 + index * (304), 308);
				case CENTER_SCREEN_CENTER_2: new Vector2((1600 - maxWidthAtStandardScale) / 2 + (index % wrapAt) * correctStandardScale, 308 + 234 * Math.floor(index / wrapAt));
				case CENTER_SCREEN_TOP: new Vector2((1600 - maxWidthAtStandardScale) / 2 + (index % wrapAt) * correctStandardScale, 26 + 234 * Math.floor(index / wrapAt));
			}

			var targetScale = switch (transitioningTo) {
				case LEFT_SCREEN_TOP: maxCardSize;
				case LEFT_SCREEN_CENTER: 0.8;
				case LEFT_SCREEN_BOTTOM: maxCardSize;
				case CENTER_SCREEN_BOTTOM: maxCardSize;
				case CENTER_SCREEN_CENTER: 0.8;
				case CENTER_SCREEN_CENTER_2: maxCardSize;
				case CENTER_SCREEN_TOP: maxCardSize;
			}

			card.x = Math.lerp(card.x, target.x, .09);
			card.y = Math.lerp(card.y, target.y, .09);
			card.scale = Math.lerp(card.scale, targetScale, .09);
			if (Math.abs(card.x - target.x) > 1 || Math.abs(card.y - target.y) > 1 || Math.abs(card.scale - targetScale) > 0.01) done = false;
			index++;
		}
		if (done) {
			currentlyAt = transitioningTo;
			transitioningTo = null;
		}
	}
}