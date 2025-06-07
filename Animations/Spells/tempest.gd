extends SpellAnim


# Called when the node enters the scene tree for the first time.
func _ready():
	start.emit()
	appear.emit()
	position = Vector2(1500, 250)
	Overlay.change_color.emit("#6eff9c60")
	get_tree().create_timer(5).timeout.connect(func():
		impact.emit()
		self.emitting = false
		Overlay.change_back.emit()
		
		get_tree().create_timer(3).timeout.connect(func():
			end.emit()
			queue_free()
		)
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
