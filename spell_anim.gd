extends Node2D

class_name SpellAnim


enum Anim {
	SHOT, # shoots from source to destination position
	STATIONARY, # spawns on target
	MIDDLE # spawns in the middle of the screen
}


## describes what position to start at
var start: Vector2
## describes what position to travel to
var fin: Vector2
## refers to the object being displayed (Sprite2D, C/GPUParticles, etc.).
## visuals like animation/particle effects will be handled in the subject scene.
## this spell_anim will handle movement and placement
var subject
var type: Anim

signal begin
signal appear
signal move
signal impact # when it hits the enemy
signal finished

# Constructors (Rust-like)

static func shot(sub, s: Vector2, f: Vector2) -> SpellAnim:
	var new_sp_an = SpellAnim.new()
	new_sp_an.subject = sub
	new_sp_an.start = s
	new_sp_an.fin = f
	new_sp_an.type = Anim.SHOT
	return new_sp_an

static func stationary(sub, s: Vector2) -> SpellAnim:
	var new_sp_an = SpellAnim.new()
	new_sp_an.subject = sub
	new_sp_an.start = s
	new_sp_an.fin = null
	new_sp_an.type = Anim.STATIONARY
	return new_sp_an

static func middle(sub) -> SpellAnim:
	var new_sp_an = SpellAnim.new()
	new_sp_an.subject = sub
	new_sp_an.start = null
	new_sp_an.fin = null
	new_sp_an.type = Anim.MIDDLE
	return new_sp_an


# Called when the node enters the scene tree for the first time.
func _ready():
	#visible = false # instead, color modulate subject
	if type == Anim.MIDDLE:
		start = get_viewport().get_visible_rect().size / 2
	
	position = start
	# wait for appear and fade in
	appear.connect(on_appear)
	# wait for move and then move toward target
	move.connect(on_move)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# maybe also add signals/flags like "impact"
# for when something should explode/shatter


## when appear signal is given, fade in for half a second
## or, just call appear() on subject (have this turn emitting on for particles,
## or fade in for sprites)
func on_appear():
	subject.appear()


## when move signal is given, move for 1 second toward the enemy
func on_move():
	var mv_tween = create_tween()
	mv_tween.tween_property(self, "position", fin, 1)
