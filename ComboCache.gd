extends Node

class_name ComboCache
# idea: DFA

var combo_timer: Timer = Timer.new()
func _init():
	add_child(combo_timer)
	combo_timer.timeout.connect(on_timeout)
	combo_timer.autostart = true

var accum_inputs = []
var buffer = 0.5


func start():
	combo_timer.start(buffer)


func add():
	if Input.is_action_just_pressed("up"):
		accum_inputs.append("w")
	elif Input.is_action_just_pressed("down"):
		accum_inputs.append("s")
	elif Input.is_action_just_pressed("left"):
		accum_inputs.append("a")
	elif Input.is_action_just_pressed("right"):
		accum_inputs.append("d")
	elif Input.is_action_just_pressed("confirm"):
		accum_inputs.append("k")
	elif Input.is_action_just_pressed("cancel"):
		accum_inputs.append("l")
	if Input.is_anything_pressed():
		#print(accum_inputs)
		combo_timer.start(buffer)


func on_timeout():
	print(accum_inputs)
	accum_inputs.clear()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
