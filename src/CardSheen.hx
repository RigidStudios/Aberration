import h3d.shader.ScreenShader;
import h3d.shader.Base2d;

class CardSheen extends ScreenShader {
    static var SRC = {
        @param var texture : Sampler2D;
        // @param var speed : Float;
        // @param var frequency : Float;
        // @param var amplitude : Float;
        @param var angle : Float;
        
        function fragment() {
			var col = texture.get(calculatedUV);

			var st = smoothstep(0,0.6,angle) * 0.4;
            pixelColor = vec4(col.r * (1 - st), col.g * (1 - st), col.b * (1 - st), col.a);
            // pixelColor = vec4(st, st, st, col.a);
        }
    }
}