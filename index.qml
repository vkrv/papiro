Item {
	id: app;
	anchors.fill: context;

	CardView {
		width: 90%;
		x: 5%; y: 5%;
		spacing: 10;

		model: ListModel {
			onCompleted: {
				for (var i = 0; i < 50; ++i)
					this.append({ text: "TEXT", height: (100 + (i % 10) * 10), idx: i})
			}
		}

		delegate: WebItem {
			width: parent.cellWidth; 
			height: model.height;
			color: "#F9F8F0";
			clip: true;
			property int idx: model.idx;

			effects.shadow.blur: hover ? 18 : 3;
			effects.shadow.y: 1;
			effects.shadow.color: "#0006";
			effects.shadow.spread: 0;
			radius: 2;
			z: hover ? 500 : model.index;

			Text { 
				text: model.idx;
			}

			property TranslateDragMixin drag: TranslateDragMixin {
				onMoved(iX, iY, eX, eY): {
//					log("onMoved", this.parent.x, this.parent.y, eX - this.parent.parent.x, eY - this.parent.parent.y)
					var idx = this.parent.parent._indexByXY(eX, eY)
//					log("onMoved", idx, this.parent.idx)
					if(idx === undefined) 
						log("idx undefined", eX, eY, iX, iY, this.parent.parent._posMx)

					if (idx !== this.parent.idx && (!this.prevIdx || idx !== this.prevIdx)) {
						this.prevIdx = idx;
						var item = this.parent.parent._items[idx]
						var sx = this.parent.x - item.x;
						var sy = this.parent.y - item.y;
						this.parent.parent._items[idx] = this.parent.parent._items[this.parent.idx]
						this.parent.parent._items[this.parent.idx] = item
						log ("translate old", idx, this.parent.idx, this.parent.transform.translateX, sx)
						this.parent.parent._position()
						this.parent.transform.translateX += sx
						this.parent.transform.translateY += sy
						this._startX -= sx
						this._startY -= sy
						log ("translate new", this.parent.transform.translateX)
					}
				}

				onDropped: {
					this.prevIdx = undefined
				}
			}

			Behavior on x, y, transform { Animation { duration: parent.drag.pressed ? 0 : 500; }}
			Behavior on z { Animation { duration: 500; }}
			Behavior on boxshadow { Animation { duration: 500; }}
		}
	}
}
