extends SpellAnim
#
## TODO: Hat-Man
## take a bucnh of benadryl, escape the hat man, FNAF-like


# Called when the node enters the scene tree for the first time.
func _ready():
	start.emit()
	self.modulate.a = 0
	self.position = start_pos
	
	#Overlay.emit_signal("change_color", Color("#387aff70")) # blue
	Overlay.emit_signal("change_color", Color("ff999970")) # red
	
	create_tween().tween_property(get_parent().battleCamera, "zoom", Vector2.ONE, 1.5).as_relative()
	create_tween().tween_property(get_parent().battleCamera, "position", self.position, 1.5)
	
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5).set_delay(3).finished.connect(on_rmv)
	get_tree().create_timer(3).timeout.connect(func(): appear.emit())
	
	var mv_tween: Tween = create_tween()
	mv_tween.tween_property(self, "position", end_pos, 1).set_delay(5)
	mv_tween.finished.connect(on_finish_mv)


# define this function for each visual you want to be a spell.
# for Sprite2D, it can be this tween function.
# for C/GPUParticles we can make it say emitting = true
#func appear():
	#create_tween().tween_property(self, "modulate:a", 1.0, 0.5)


func on_rmv():
	var cam = get_parent().battleCamera
	get_parent().remove_child(cam)
	cam.position = Vector2.ZERO
	add_child(cam)


func on_finish_mv():
	impact.emit()
	
	var cam = get_parent().battleCamera
	remove_child(cam)
	get_parent().add_child(cam)
	cam.position = self.position
	create_tween().tween_property(get_parent().battleCamera, "zoom", Vector2.ONE, 0.75)
	create_tween().tween_property(get_parent().battleCamera, "position", Vector2(572, 336), 0.75)
	
	self.spread = 180
	self.lifetime = 2.0
	self.gravity = Vector2.ZERO
	get_tree().create_timer(0.2).timeout.connect(func(): self.emitting = false)
	get_tree().create_timer(0.8).timeout.connect(func(): end.emit())
	
	get_tree().create_timer(2.5).timeout.connect(func(): queue_free())
	Overlay.emit_signal("change_back")
