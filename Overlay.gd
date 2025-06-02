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
	size = screen * 3
	position = Vector2.ZERO - (size / 2)


func _ready():
	change_color.connect(on_change_color)
	change_back.connect(on_change_back)


func _process(delta):
	pass


func on_change_color(c: Color):
	color = c
	create_tween().tween_property(self, "color:a", c.a, 0.75).from(0)


func on_change_back():
	create_tween().tween_property(self, "color:a", 0, 1.5)
