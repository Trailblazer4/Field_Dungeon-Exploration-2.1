extends ColorRect


func _init():
	color = "#00000000"


func scaleTo(screen: Vector2):
	size = screen * 1.3


func play(anim_name: String):
	get_child(0).play(anim_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	#get_child(0).animation_finished.connect(get_parent().on_fadeout_end)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
