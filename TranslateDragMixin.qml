Object {
	signal moved;
	signal dropped;
	property bool isMoved;
	property bool pressed;
	property bool enabled: true;

	constructor: {
		this.element = this.parent.element;
		this._bindPressed(this.enabled)
	}

	function _moveHandler(e) {
		e.preventDefault();

		if (e.changedTouches)
			e = e.changedTouches[0]

		var eY = e.clientY, sY = this._startY , eX = e.clientX, sX = this._startX 

		this.parent.transform.translateY = eY - sY
		this.parent.transform.translateX = eX - sX
		this.isMoved = true;
		this.moved(eX - sX, eY - sY, eX, eY)
	}

	function _releaseHandler(e) {
		e.preventDefault();

		if (e.changedTouches)
			e = e.changedTouches[0]
		this.pressed = false

		this.parent.transform.translateX = 0
		this.parent.transform.translateY = 0

		this.dropped()
		this._dmMoveBinder.enable(false)
	}

	function _downHandler(e) {
		e.preventDefault();
		this.pressed = true

		if (e.changedTouches)
			e = e.changedTouches[0]

		this._startX = e.clientX// - this.parent.x
		this._startY = e.clientY// - this.parent.y
		if (!this._dmMoveBinder) {
			this._dmMoveBinder = new _globals.core.EventBinder(context.window)

			this._dmMoveBinder.on('mousemove', this._moveHandler.bind(this))
			this._dmMoveBinder.on('touchmove', this._moveHandler.bind(this))

			this._dmMoveBinder.on('mouseup', this._releaseHandler.bind(this))
			this._dmMoveBinder.on('touchend', this._releaseHandler.bind(this))
		}
		this._dmMoveBinder.enable(true)
	}

	function _bindPressed(value) {
		if (value && !this._dmPressBinder) {
			this._dmPressBinder = new _globals.core.EventBinder(this.element)
			this._dmPressBinder.on('mousedown', this._downHandler.bind(this))
			this._dmPressBinder.on('touchstart', this._downHandler.bind(this))
		}
		if (this._dmPressBinder)
			this._dmPressBinder.enable(value)
	}

	onEnabledChanged: {
		this._bindPressed(value)
	}
}
