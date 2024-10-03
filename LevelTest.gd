extends Level


#var fadeScene = preload("res://fadebox.tscn").instantiate()
#func _init():
	#super()

# Called when the node enters the scene tree for the first time.
func _ready():
	# use a method to recursively (or not) check
	# all Exit children, and connect their signals to
	# this Level's on_time_to_go
	#$Exit0.time_to_go.connect(on_time_to_go)
	#$Exit1.time_to_go.connect(on_time_to_go)
	#add_child(fadebox)
	#fadebox.play("fade_white")
	#print("Scene: ", fadeScene)
	#add_child(fadeScene)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func _on_exit_0_time_to_go(level, entryPoint, direction):
	#print("Time to go!")
	#print(level, entryPoint, direction)
