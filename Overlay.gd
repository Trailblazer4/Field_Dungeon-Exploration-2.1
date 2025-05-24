extends ColorRect


@onready var anim: AnimationPlayer = get_child(0)

func play(anim_name):
	anim.play(anim_name)
	print("Played ", anim_name)


## abstracts the "animation finished" behavior for the Overlay animations.
## waits for the current animation to finish and then returns its result (if any)
func finished():
	return await anim.animation_finished


func scaleTo(screen: Vector2):
	size = screen * 1.3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
