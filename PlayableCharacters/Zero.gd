extends Entity


func _init():
	super()
	myName = "Zero"


# Called when the node enters the scene tree for the first time.
func _ready():
	moveset.append(GameData.SpellLibrary["Temp"])
	moveset.append(GameData.SpellLibrary["Pew Pew"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func walk(v: Vector2):
	if v.x < 0:
		$Sprite2D.flip_h = false
	elif v.x > 0:
		$Sprite2D.flip_h = true
	$Sprite2D/AnimationPlayer.play("run")


func face(d: Vector2):
	$Sprite2D/AnimationPlayer.play("idle")


func face_left():
	$Sprite2D/AnimationPlayer.play("idle")
	$Sprite2D.flip_h = false
