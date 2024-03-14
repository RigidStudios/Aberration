import hxd.Math;
import h2d.filter.Shader;
import h2d.RenderContext;
import h2d.Bitmap;
import hxd.Res;
import h2d.Object;

class SliceShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;
        
        @param var texture : Sampler2D;
        // @param var speed : Float;
        // @param var frequency : Float;
        // @param var amplitude : Float;
        @param var slice : Float;
        @param var zeroe : Float;
        @param var height : Float;
        
        function fragment() {
			var col = texture.get(calculatedUV);

            pixelColor = vec4(col.rgb, slice < (calculatedUV.y - zeroe) / height ? col.a : 0.);
        }
    }
}

class Healthbar extends Object {
	public var slice : SliceShader;
	public var bmback : Bitmap;
	public var bmfront : Bitmap;
	
	public function new() {
		super(Main.inst.s2d);

		bmback = new Bitmap(Res.healthbar_back.toTile(), this);
		bmfront = new Bitmap(Res.healthbar_front.toTile(), bmback);

		slice = new SliceShader();
		slice.texture = bmfront.tile.getTexture();
		slice.zeroe = 0.02;
		slice.height = 0.73;
		bmfront.addShader(slice);

		bmback.width = 32 * 4;
		bmfront.width = 32 * 4;
	}

	public var decay = 0.;
	public var lastRecordedHP = 100.;

	override public function sync(ctx: RenderContext) {
		if (lastRecordedHP != Main.inst.char.hp) {
			decay = (lastRecordedHP - Main.inst.char.hp) * 0.1;
			lastRecordedHP = Main.inst.char.hp;
		}
		slice.slice = Math.lerp(slice.slice, 1 - Main.inst.char.hp / Main.inst.char.maxHp, 0.08);

		decay = Math.max(decay - Main.inst._dt, 0);
		bmback.x = (Math.sin(decay * 20) * 4) * Math.min(decay / 0.4, 1);
		bmback.y = (Math.sin(decay * 20 + 12) * 2) * Math.min(decay / 0.4, 1);

		super.sync(ctx);
	}
}