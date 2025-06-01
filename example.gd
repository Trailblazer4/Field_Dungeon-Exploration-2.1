extends Sprite2D
#
## TODO: Hat-Man
## take a bucnh of benadryl, escape the hat man, FNAF-like
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
	#self.modulate.a = 0
	#
	#Overlay.play("fadein_zone")
#
	#await Overlay.anim.animation_finished
	##Overlay.emit_signal("change_color", Color("#387aff70")) # blue
	#Overlay.emit_signal("change_color", Color("ff999970")) # red
	#create_tween().tween_property(get_parent().battleCamera, "zoom", Vector2.ONE, 1.5).as_relative()
	#create_tween().tween_property(get_parent().battleCamera, "position", self.position, 1.5)
	#create_tween().tween_property(self, "modulate:a", 1.0, 0.5).set_delay(3).finished.connect(on_rmv)
	#var mv_tween: Tween = create_tween()
	#mv_tween.tween_property(self, "position", Vector2(-500, 500), 1).as_relative().set_delay(5)
	#mv_tween.finished.connect(on_finish_mv)
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if Input.is_action_just_pressed("ui_accept"):
		#appear()
#
#
## define this function for each visual you want to be a spell.
## for Sprite2D, it can be this tween function.
## for C/GPUParticles we can make it say emitting = true
#func appear():
	#create_tween().tween_property(self, "modulate:a", 1.0, 0.5)
#
#
#func on_rmv():
	#var cam = get_parent().battleCamera
	#get_parent().remove_child(cam)
	#cam.position = Vector2.ZERO
	#add_child(cam)
#
#
#func on_finish_mv():
	#var cam = get_parent().battleCamera
	#remove_child(cam)
	#get_parent().add_child(cam)
	#cam.position = self.position
	#create_tween().tween_property(get_parent().battleCamera, "zoom", Vector2.ONE, 0.75)
	#create_tween().tween_property(get_parent().battleCamera, "position", Vector2(572, 336), 0.75)
