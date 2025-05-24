extends CharacterBody2D


const SPEED = 50.0
## time interval which NPC walks/stops for before changing direction
@export var walk_time: float = 3.0
var can_move: bool = true
@export var my_name: String = "Foo Bar"
@export var messages: Array[Array]
var walking = false
var walk_dirs = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]
var direction = Vector2.ZERO


func _ready():
	$Timer.start(walk_time)


func _physics_process(delta):
	velocity = direction * SPEED * (1 if can_move else 0)
	move_and_slide()


func _on_timer_timeout():
	walking = !walking
	if walking:
		direction = walk_dirs.pick_random()
	else:
		direction = Vector2.ZERO


func speak():
	if !GameData.current_scene.interaction:
		print("Hi, I'm %s" % my_name)
		var tb = Textbox.from(messages, self)
		GameData.current_scene.add_child(tb)
		GameData.current_scene.interaction = tb


func _on_area_2d_body_entered(body):
	if body == GameData.party.slot(0):
		print("What up")
		GameData.listening.append(self)


func _on_area_2d_body_exited(body):
	if body == GameData.party.slot(0):
		print("Goodbye my-")
		GameData.listening.erase(self)
