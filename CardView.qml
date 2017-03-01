BaseView {
	property int spacing;					///< spacing between adjanced items, pixels
	property int horizontalSpacing; ///< horizontal spacing between rows, overrides regular spacing, pixels
	property int verticalSpacing; ///< vertical spacing between columns, overrides regular spacing, pixels
	property int rows; ///< read-only property, represents number of row in a grid
	property int columns; ///< read-only property, represents number of row in a grid
	property int cellWidth: 100;

	property enum horizontalAlignment {
		AlignLeft, AlignRight, AlignHCenter, AlignJustify
	};

	property enum flow { FlowTopToBottom, FlowLeftToRight };

	/// @private creates delegate in given item slot
	function _createDelegate(idx) {
		log("_createDelegate")
		var items = this._items
		if (items[idx] !== null)
			return

		var row = this.model.get(idx)
		row['index'] = idx
		this._local['model'] = row

		var item = this.delegate()
		items[idx] = item
		item.view = this
		item.element.remove()
		this.element.append(item.element)
		this.addChild(item)

		item._local['model'] = row
		delete this._local['model']
		return item
	}

	function _create() {
		if (!this.recursiveVisible) {
			this.layoutFinished()
			return
		}

		var model = this.model;
		if (!model) {
			return
		}

		this._created = false;
		var n = this.count = model.count
		var items = this._items
		for(var i = 0; i < n; ++i) {
			var item = items[i]
			if (!item) {
				item = this._createDelegate(i)
				this._created = true
			}
		}
	}

	function _indexByXY(x, y) {
		var hsp = this.horizontalSpacing || this.spacing
		var vsp = this.verticalSpacing || this.spacing
		var col = Math.min(this.columns - 1, (Math.floor((x - this.x) / (this.cellWidth + hsp))))
//		log("_indexByXY", col, x - this.x, this.cellWidth + hsp)
		if (col < 0)
			col = 0
		var row = this._posMx[col]
		for (var i = 0; i < row.length; ++i) {
			if (row[i].y <= y && (row[i].y + row[i].height + vsp) > y)
				return row[i].idx
		}

		if (y < 0)
			return row[0].idx

		var last = row[row.length - 1]
		if ((last.y + last.height) <= y)
			return last.idx

		log("_indexByXY didn't get an id", x, y, col, row)
	}

	function _layout() {
		log("_layout")
		this._create()
		this._position()

		this.layoutFinished()
		if (this._created)
			this._context._complete()
	}

	function _position() {
//		log("_position", this.children.length)
		var children = this._items;
		var vsp = this.verticalSpacing || this.spacing,
			hsp = this.horizontalSpacing || this.spacing
		this.count = children.length
		var cw = this.cellWidth
		var cols = Math.floor((this.width - hsp) / (cw + hsp))
		this.columns = cols
		this._posMx = []
		var a = []

		for (var i = 0; i < cols; ++i) {
			a[i] = 0;
			this._posMx[i] = []
		}

		for(var i = 0; i < children.length; ++i) {
			var c = children[i]

			if (c == undefined)
				log("UNDIFINED", i, children)

			if (!('height' in c) || !('width' in c))
				continue


			if (c.recursiveVisible) {
				var col = 0;

				for (var j = 1; j < cols; ++j) {
					if (a[col] > a[j])
						col = j
				}

				c.x = col * (cw + hsp)
				c.y = a[col]
				c.idx = i
				this._posMx[col].push({idx: i, y: a[col], height: c.height})
				a[col] += c.height + vsp
			}
		}
		
		this.contentHeight = Math.max(a) - vsp;
		this.contentWidth = (cw + hsp) * cols - hsp;
	}

	function addChild(child) {
		_globals.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		if (child instanceof _globals.core.Item) {
			child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
//			child.onChanged('width', delayedLayout.schedule.bind(delayedLayout))
//			child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
		}
	}
}