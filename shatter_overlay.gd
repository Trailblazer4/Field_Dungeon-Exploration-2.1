extends TextureRect


var t := 0.0


func _process(delta):
	t += delta
	material.set_shader_parameter("time", t)
	#if t > 1.0:
		#queue_free() # or trigger scene switch



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
