package util;

import box2D.dynamics.B2Body;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2BodyDef;
import hxmath.math.Vector2;


class PhysicsUtil {
	public static function addBox(w:B2World, center:Vector2, halfExtents:Vector2, wall:Bool): B2Body {
		var groundBody = new B2BodyDef();
		if (!wall) groundBody.type = DYNAMIC_BODY;
		groundBody.position.set(center.x,center.y);
		var body = w.createBody(groundBody);
		var shape = new B2PolygonShape();
		shape.setAsBox(halfExtents.x, halfExtents.y);
		var fixture = new B2FixtureDef();
		
		fixture.density = 0.2;
		fixture.friction = wall ? 0.2 : 0.1;
		fixture.shape = shape;

		body.createFixture(fixture);

		return body;
	}
}