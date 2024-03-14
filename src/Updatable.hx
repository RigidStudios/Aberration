class Updatable {
	public static var UPDATABLES: Map<Int, Updatable> = new Map();
	public static var INDEX = 0;

	public var updates = true;
	public var id: Int = 0;

	public function new(?todo: Bool = true) {
		if (todo) registerMyself();
	}

	public function registerMyself() {
		id = this.id == 0 ? INDEX++ : this.id;
		UPDATABLES.set(id, this);
		trace("Registered", this, id);
		updates = true;
	}

	public function update(dt: Float) {
	}

	public static function updateEntities(dt: Float) {
		trace(UPDATABLES);
		for (index => value in UPDATABLES) {
			if (value != null && value.updates) value.update(dt);
		}
	}

	public function remove() {
		UPDATABLES.remove(id);
	}
}