extends Node2D

signal battle_continue


@onready var battle = get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	battle.move_used.connect(on_move_used)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func on_move_used():
	$ColorRect/Label.text = "%s used %s!" % [battle.thisTurn.get_child(0).myName, battle.chosenMove.title]
	
	visible = true
	$Timer.start(1)
	await $Timer.timeout
	visible = false
	emit_signal("battle_continue")
