package ;
class Rocket extends Enemy {
	public function new(x:Float, y:Float, rot:Float) {
		super("rocket", true);
		anim.stop();
		this.xx = x;
		this.yy = y;
		shadow.alpha *= .5;
		shadow.scaleX *= .8;
		shadow.scaleY *= .8;
		this.rotation = rot;
		update();
	}
	override public function update() {
		var hero = Game.CUR.hero;
		if(hero != null && !hero.dead) {
			var curAngle = rotation * Math.PI / 180.;
			var dx = hero.xx - xx;
			var dy = hero.yy - yy;
			var heroAngle = Math.atan2(dy, dx);
			var dist = Math.sqrt(dx * dx + dy * dy);
			var rotSpeed = .027 * 180 / Math.PI * (dist / 10);
			if(rotSpeed > 8.) {
				rotSpeed = 8.;
			} else if(rotSpeed < -8.) {
				rotSpeed = -8.;
			}
			if(curAngle < heroAngle) {
				var d = heroAngle - curAngle;
				var dd = curAngle - heroAngle + Math.PI * 2.;
				if(d > dd) {
					d = -dd;
				}
				if(d < dd) {
					rotation += d * rotSpeed;
				} else {
					rotation -= dd * rotSpeed;
				}
			} else if(heroAngle < curAngle) {
				var d = curAngle - heroAngle;
				var dd = heroAngle + Math.PI * 2. - curAngle;
				if(d < dd) {
					rotation -= d * rotSpeed;
				} else {
					rotation += dd * rotSpeed;
				}
			}
			if(rotation < 0) rotation += 360;
			if(rotation > 360) rotation -= 360;
		}
		
		var a = rotation / 180 * Math.PI;
		var spd = 5;
		var dx = Math.cos(a), dy = Math.sin(a);
		var cx = xx + dx * 7;
		var cy = yy + dy * 7;
		dx *= spd;
		dy *= spd;
		var level = Game.CUR.level;
		if(level.pointCollides(cx, cy)) {
			die();
			return;
		}
		xx += dx;
		yy += dy;
		super.update();
	}
	override function collidesHero() {
		var hero = Game.CUR.hero;
		var hero = Game.CUR.hero;
		var dx = hero.xx - xx;
		var dy = hero.yy - yy;
		var r = hero.cradius + 6;
		return dx*dx + dy*dy < r * r;
	}
}