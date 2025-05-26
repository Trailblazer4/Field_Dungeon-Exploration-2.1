extends CharacterBody2D


const SPEED = 50.0
## time interval which NPC walks/stops for before changing direction
@export var walk_time: float = 3.0
var can_move: bool = true
@export var my_name: String = "Foo Bar"
#@export var messages: Array[Array]
@export var messages: Dictionary
var walking = false
var walk_dirs = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]
var direction = Vector2.ZERO

# TODO: try \\\\jump to merge blocks back into a single conversation (diamond shape control flow)
func _ready():
	$Timer.start(walk_time)
	messages = {
		"start": [
			["You", "Should I talk to Joe?", {"Yes": "y", "No": "n"}],
		],
		"y": [
			["Joe", "Hi there, \\\\party 1 name!"],
			"\\\\if \\\\flag Town::Joe::0 y2 | y1"
		],
		"y1": [
			"\\\\give Sword x 1",
			"\\\\romance Misty 10",
			"\\\\flag Town::Joe::0 flip",
			"\\\\jump y2"
		],
		"y2": [
			["Joe", "How's it hangin', \\\\party 0 name?", {"Doing good!": "res0", "What's it to you?": "res1"}]
		],
		"n": [], #["\\\\give Lion's Shield x 1"],
		"res0": [
			["Joe", "I see. That's good to hear!"],
			"\\\\give Potion x 5",
			["Link", "..."],
			["Link", "So you thought I couldn't speak?", {"Uh, yeah?": "link0", "Of course not!": "link1"}]
		],
		"res1": [
			["Joe", "How rude! Hmph!"]
		],
		"link0": [
			["Link", "Damn, ok."]
		],
		"link1": [
			["Link", "Hmm, ok."],
			"\\\\romance Link 7"
		]
	}


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
