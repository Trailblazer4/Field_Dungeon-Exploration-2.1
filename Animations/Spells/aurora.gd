extends SpellAnim


# Called when the node enters the scene tree for the first time.
func _ready():
	start.emit()
	scale = Vector2(3, 4)
	$CPUParticles2D.scale_amount_min *= 2.5
	$CPUParticles2D.scale_amount_max *= 2.5
	Overlay.emit_signal("change_color", Color("#60d3fc55"))
	
	self_modulate.a = 0
	position = end_pos
	create_tween().tween_property(self, "self_modulate:a", 0.78, 1.5).set_delay(2)
	create_tween().tween_property(self, "self_modulate:a", 0, 1.5).set_delay(5)\
	.finished.connect(func(): $CPUParticles2D.emitting = false; Overlay.emit_signal("change_back"); end.emit())
	get_tree().create_timer(5).timeout.connect(func(): impact.emit())
	
	get_tree().create_timer(10).timeout.connect(func(): queue_free()) # waits for particles to be done
