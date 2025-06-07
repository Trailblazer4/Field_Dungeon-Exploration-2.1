extends SpellAnim


@export var jump_curve: Curve
func curve_pt(v): return jump_curve.sample_baked(v)

func higher(pos0: Vector2, pos1: Vector2) -> Vector2:
	# if y is lower, then position is physically higher
	if pos0.y < pos1.y:
		return pos0
	return pos1


func lagrange(x, start, mid, end) -> float:
	if start.x == mid.x or start.x == end.x or mid.x == end.x:
		push_error("Lagrange interpolation requires distinct x values")
		return 0.0
	
	return start.y * (x - mid.x) * (x - end.x) / ((start.x - mid.x) * (start.x - end.x)) \
			+ mid.y * (x - start.x) * (x - end.x) / ((mid.x - start.x) * (mid.x - end.x)) \
			+ end.y * (x - start.x) * (x - mid.x) / ((end.x - start.x) *(end.x - mid.x))


# langrange interpolation to be set
var lagrerp: Callable

# Called when the node enters the scene tree for the first time.
func _ready():
	start.emit()
	appear.emit() # ? maybe move this
	# move user toward target, then back
	var old_pos = user.global_position
	var midpoint = higher(old_pos + Vector2(-200, -100), end_pos + Vector2(200, -100))
	lagrerp = func(x): return lagrange(x, old_pos, midpoint, end_pos)
	
	create_tween().tween_property(user, "global_position:x", target.global_position.x, 0.25)\
	.finished.connect(func(): impact.emit())
	
	create_tween().tween_property(user, "global_position:x", old_pos.x, 0.25)\
	.set_delay(0.5)\
	.finished.connect(func(): end.emit(); queue_free())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	user.global_position.y = lagrerp.call(user.global_position.x)



### quadratic interpolation for jumping ###

# start at start_pos

# midpoint is going to be higher(old_pos + Vector2(-200, -100), end_pos + Vector2(200, -100)),
# where higher returns the vector with higher y position (lower numeric value)

# end at end_pos
