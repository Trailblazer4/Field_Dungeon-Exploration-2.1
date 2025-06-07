extends Node2D

class_name SpellAnim


## triggered when animation starts
signal start
## can be used to have the animation subject fade in
## or begin emitting for particle effects.
signal appear
## marks the moment the spell hits the target
signal impact
## signals the end of this animation,
## so battle can continue
signal end

var start_pos: Vector2
var end_pos

var user
var target

## critical hit flag
var crit: bool
## super effective flag
var spr_eff: bool

## if this is true and the move used is a physical skill,
## it might have access to the user of the skill and be able to
## animate them to jump toward the enemy, perform sword/punch/etc. skills, etc.
var physical: bool = false


static func from(name: String, user, start_pos: Vector2, target, end_pos=null):
	if !FileAccess.file_exists("res://Animations/Spells/%s.tscn" % name):
		return null
	
	var anim_info = load("res://Animations/Spells/%s.tscn" % name)
	var new_anim = anim_info.instantiate()
	new_anim.user = user
	new_anim.start_pos = start_pos
	new_anim.target = target
	new_anim.end_pos = end_pos
	return new_anim


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
