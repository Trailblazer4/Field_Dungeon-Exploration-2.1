extends Sprite2D

class_name QuickTimeButton


static var buttons = ["confirm", "cancel", "openMagic", "openItems"]
var button: String = buttons.pick_random()
var left
var action: Callable
var chain_complete: Callable
@onready var timer := $Timer
var wait_time
var delay

static var qt_info = load("res://quick_time_button.tscn")
static func with(n, a: Callable, e: Callable, t=1, d=0):
	var new_qtb = qt_info.instantiate()
	new_qtb.left = n
	new_qtb.action = a
	new_qtb.chain_complete = e
	new_qtb.wait_time = t
	new_qtb.delay = d
	return new_qtb


func next():
	if left > 1:
		var new_qtb = QuickTimeButton.with(left-1, action, chain_complete, wait_time, delay)
		visible = false
		new_qtb.position = position
		new_qtb.scale = scale
		if delay:
			timer.stop()
			await get_tree().create_timer(delay).timeout
		get_parent().add_child(new_qtb)
	else:
		chain_complete.call()
	queue_free()


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(func():
		chain_complete.call()
		queue_free()
	)
	timer.start(wait_time)
	
	match button:
		"confirm":
			texture = load("res://images/ps3_button_x.png")
		"cancel":
			texture = load("res://images/ps3_button_o.png")
		"openMagic":
			texture = load("res://images/ps3_button_square.png")
		"openItems":
			texture = load("res://images/ps3_button_triangle.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for b in buttons:
		if Input.is_action_just_pressed(b):
			if b == button:
				action.call()
				print(left)
				next()
			else:
				chain_complete.call()
				queue_free()
