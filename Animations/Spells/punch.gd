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

#var dodged: bool = false
signal dodged(who)
var has_dodged: bool = false
@onready var battle = user.get_parent().get_parent()

signal chain_complete

# Called when the node enters the scene tree for the first time.
func _ready():
	dodged.connect(battle.get_node("Battle HUD/BattlePrompt").player_dodged)
	start.emit()
	appear.emit() # ? maybe move this
	# move user toward target, then back
	var old_pos = user.global_position
	var midpoint = higher(
		old_pos + Vector2(-200, -100), # user pos. if facing left (i.e. is a player),
													   # old pos is positioned left, else right
		end_pos + Vector2(200, -100) # target pos.
	)
	lagrerp = func(x): return lagrange(x, old_pos, midpoint, end_pos) # + Vector2.RIGHT * -100 * dir_lr_scalar())
	
	var shutdown = func():
		self.name = "freed"
		create_tween().tween_property(user, "global_position:x", old_pos.x, 0.4)\
		.set_delay(0.5)\
		.finished.connect(func():
			end.emit();
			get_tree().create_timer(1).timeout.connect(func(): queue_free())
		)
	
	#  + 100 * dir_lr_scalar() ?
	create_tween().tween_property(user, "global_position:x", target.global_position.x, 0.4)\
	.finished.connect(func():
		impact.emit()
		
		if user in battle.get_node("Party").get_children() \
		&& randi_range(1, 5) >= 1:
				# chance of QTE popping up
				# spawn QTE(randi_range(2, 4))
				var qte = QuickTimeButton.with(
					randi_range(2, 4),
					func():
						user.get_child(0).use(GameData.SpellLibrary[self.name], target)
						target.health_bar.health = target.getHP(),
					func(): chain_complete.emit(),
					1.0,
					0.8
				)
				
				#qte.position = get_viewport_rect().size / 2
				qte.position = user.global_position + Vector2.UP * 70
				qte.scale *= 0.2
				add_child(qte)
				
				await chain_complete
				shutdown.call()
		else:
			shutdown.call()
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	user.global_position.y = lagrerp.call(user.global_position.x)
	
	if Input.is_action_just_pressed("cancel") && !has_dodged && user in battle.get_node("Enemies").get_children():
		has_dodged = true
		if abs(user.global_position.x - target.global_position.x) < 30:
			create_tween().tween_property(target, "global_position:x", 100, 0.2).as_relative()
			create_tween().tween_property(target, "global_position", end_pos, 0.2).set_delay(0.4)
			battle.get_node("Battle HUD/BattlePrompt").player_dodged(target)


### quadratic interpolation for jumping ###

# start at start_pos

# midpoint is going to be higher(old_pos + Vector2(-200, -100), end_pos + Vector2(200, -100)),
# where higher returns the vector with higher y position (lower numeric value)

# end at end_pos
