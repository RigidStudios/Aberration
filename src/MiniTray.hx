import GameCard.CardsDeck;
import haxe.ds.Either;
import hxsl.Types.Vec4;
import h2d.Tile;
import h2d.Bitmap;
import util.FaceData.CardFaceData;
import h2d.RenderContext;
import GameCard.TrayFilter;
import h2d.Object;

class MiniTray extends Object {
	var mWidth : Float;
	var trayFilter : Null<TrayFilter>;
	var miniCards : Array<MiniCard> = [];
	var pxScale: Float;
	var max: Float;
	public function new(parent: Object, cards: Array<Either<GameCard, CardFaceData>>, width: Float, px: Float, showBinds: Bool, doAlmanac: Bool = false, ?max: Int = 12, ?tFilter: TrayFilter) {
		super(parent);

		if (!CardsDeck.isDeckReady) CardsDeck.initDeck();

		mWidth = width;
		trayFilter = tFilter;

		pxScale = px;
		this.max = max;

		for (card in cards) {
			if (doAlmanac) {
				miniCards.push(new MiniCard(cast card, null, px, this, null));
			} else {
				miniCards.push(new MiniCard(cast (card, GameCard).getFaceData(), cast card, px, this, showBinds ? cast (card, GameCard).getFaceData().BIND : null));
			}
		}
	}

	override public function sync(ctx: RenderContext) {
		var width = (mWidth - Math.min(miniCards.length, max) * (pxScale * 16)) / 2;
		for (index=>card in miniCards) {
			var i = index % max;
			card.x = width + i * (pxScale * 16);
			card.y = Math.floor(index / max) * (pxScale * 24);
		}
		super.sync(ctx);
	}
}

class MiniCard extends Object {
	public var bmap : Bitmap;
	public var mCard : Null<GameCard>;
	public var mFace : CardFaceData;
	public function new(face: CardFaceData, card: Null<GameCard>, px: Float, parent: Object, bind: Null<Int>) {
		var tile: Tile;

		if (face.shouldHaveBind()) {
			trace("AMA ONE OF THESE");
			tile = Main.inst.uisheet.sub(192, 80, 16, 16);
		} else if (face.isStatCard()) {
			trace("AMA ONE OF THOSE");
			tile = Main.inst.uisheet.sub(208, 80, 16, 16);
		} else {
			trace("AMA ONE OF THBSE");
			tile = Main.inst.uisheet.sub(192, 96, 16, 16);
		}

		mFace = face;
		mCard = card;

		super(parent);
		bmap = new Bitmap(tile, this);
		bmap.width = tile.width * px;
		bmap.height = tile.height * px;

		if (bind != null && face.shouldHaveBind()) {
			TextRenderer.draw('${String.fromCharCode(bind).toLowerCase()}', Std.int(bmap.width), Std.int(bmap.height), bmap, CONTROLS);
		}
	}

	public var decay = 0.;
	public var chargedOnce = true;
	override public function sync(ctx: RenderContext) {
		decay = Math.max(0, decay - Main.inst._dt);
		if (mCard != null) {
			if (mCard.weaponCooldown <= 0.) {
				if (!chargedOnce) {
					decay = mCard.maxWeaponCooldown;
				}
				chargedOnce = true;
				bmap.color = new Vec4(1. + (decay * 7),1. + (decay * 7),1. + (decay * 7),1);
			} else {
				var dl = 1 - (mCard.weaponCooldown / mCard.maxWeaponCooldown);
				chargedOnce = false;
				bmap.color = new Vec4(1. - (dl * 0.2),1. - (dl * 0.2),1. - (dl * 0.2),1);
			}
		} else {
			if (!CardFaceData.discoveredFaces.get(mFace.ID)) {
				bmap.color = new Vec4(.5,.5,.5,1.);
			}
		}
		super.sync(ctx);
	}
}