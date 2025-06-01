extends ColorRect


@onready var anim: AnimationPlayer = get_child(0)
signal change_color(color)
signal change_back


func play(anim_name):
	anim.play(anim_name)
	print("Played ", anim_name)


## abstracts the "animation finished" behavior for the Overlay animations.
## waits for the current animation to finish and then returns its result (if any)
func finished():
	return await anim.animation_finished


func scaleTo(screen: Vector2):
	size = screen * 1.3


func _ready():
	change_color.connect(on_change_color)
	change_back.connect(on_change_back)


func _process(delta):
	pass


func on_change_color(c: Color):
	create_tween().tween_property(self, "color", c, 0.75)


func on_change_back():
	create_tween().tween_property(self, "color", Color(0), 0.75)
