extends CanvasLayer

signal battle_continue

@onready var battle = get_parent().get_parent()
## holds all of the status updates to make once move impact strikes
var status_cache: Array[Callable] = []
# Called when the node enters the scene tree for the first time.
func _ready():
	battle.move_used.connect(on_move_used)
	GameData.status_update.connect(update_cache)


func update_cache(f: Callable):
	status_cache.append(f)


func player_dodged(target):
	target.setHP(round(target.health_bar.health))
	status_cache.clear()


func on_move_used(user, move, target, crit_hit):
	#$ColorRect/Label.text = "%s used %s!" % [battle.thisTurn.get_child(0).myName, battle.chosenMove.title]
	$ColorRect/Label.text = "%s used %s!" % [user.get_child(0).myName, move.title]
	
	visible = true
	$Timer.start(1.5)
	$Timer.timeout.connect(func(): visible = false)
	# TODO:
	# get move name and set up animation spell animation.
	# await this spell animation's end signal before emitting battle_continue
	var move_dir = user.global_position.direction_to(target.global_position).x
	move_dir /= abs(move_dir) # if move_dir is 0 do some other shit here (use y instead)
	var anim_offset = move_dir * Vector2(100, 0)
	
	var spell_anim = SpellAnim.from(move.title, user, user.global_position + anim_offset, target, target.global_position)
	if spell_anim == null:
		target.health_bar.health = target.getHP()
		for update in status_cache:
			update.call()
		status_cache.clear()
		await $Timer.timeout
		emit_signal("battle_continue")
		return
	
	battle.add_child(spell_anim)
	
	await spell_anim.impact
	if crit_hit:
		Engine.time_scale = 0.4
		get_tree().create_timer(0.8).timeout.connect(func(): Engine.time_scale = 1)
	target.health_bar.health = target.getHP()
	for update in status_cache:
		update.call()
	status_cache.clear()
	# ideally, this should also be when the target's statuses
	# are visually updated
	
	await spell_anim.end
	emit_signal("battle_continue")
