extends Node2D

class_name Level


#@onready var fadebox = preload("res://fadebox.tscn").instantiate()
var fadebox
var fadeboxInfo = preload("res://fadebox.tscn")

func _init():
	print("initialized")
	fadebox = fadeboxInfo.instantiate()
	#fadebox.color = "#00000000"
	add_child(fadebox)
	fadebox.name = "myFade"
	fadebox.get_child(0).animation_finished.connect(on_fadeout_end)
	GameData.current_scene = self
	PauseMenu.current_scene = self
	fadebox.play("fadein")

# var chests = ...

var travelInfo: Dictionary = {}

func travel_to(level: int, entryPoint: Vector2, direction: Vector2):
	travelInfo["level"] = level
	travelInfo["entryPoint"] = entryPoint
	travelInfo["direction"] = direction
	
	fadebox.play("exit_zone_fadeout")
	#var fe = func():
		#print(level, entryPoint, direction)
		#print("lambda over")
	#fe.call()


func on_fadeout_end(anim_name):
	print("!!!!!!!!!!!!!!!",anim_name,"!!!!!!!!!!!!!!!!!")
	if anim_name == "exit_zone_fadeout":
		GameData.party.teleport(travelInfo["entryPoint"])
		# set position to travelInfo["entryPoint"]
		# face travelInfo["direction"]
		print(travelInfo)
		GameData.travel_to(travelInfo["level"], travelInfo["entryPoint"], travelInfo["direction"])


# Called when the node enters the scene tree for the first time.
func _ready():
	#add_child(fadebox)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(fadebox.size)
	#print(get_child(0).size)
	pass
