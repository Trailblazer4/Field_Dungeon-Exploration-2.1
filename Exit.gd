extends Area2D

class_name Exit


@export var exitNumber: int = NAN
@export var destLevel: int = NAN
@export var entryPoint: Vector2 = Vector2(NAN, NAN)
@export var direction: Vector2 = Vector2(NAN, NAN)


func _init():
	body_entered.connect(_on_body_entered)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if Input.is_action_just_pressed("confirm"):
		#emit_signal("time_to_go", 1, Vector2(0, 0), Vector2(0, 0))
	pass


func _on_body_entered(body):
	print("Position %s entered: %s" % [str(body), str(body.position)])
	if body == GameData.party.slot(0) and body.position != Vector2.ZERO:
		print("%s Entered %d" % [body, exitNumber])
		print("%s	%s	%s" % [str(destLevel), str(entryPoint), str(direction)])
		get_parent().travel_to(destLevel, entryPoint, direction)
