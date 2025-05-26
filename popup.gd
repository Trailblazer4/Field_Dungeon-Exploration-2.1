extends ColorRect


# Called when the node enters the scene tree for the first time.


#func hide_display():
	#for child in get_parent().get_children():
		#if child != self: child.visible = false


#func show_display():
	#for child in get_parent().get_children():
		#child.visible = true
	#queue_free()


func _ready():
	#hide_display()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("confirm"):
		#show_display()
		queue_free()
