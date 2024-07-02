extends Node

class_name Spell

var title: String
var element: GameData.Element
var power: int
var spReq: int
var status_effects: Array[Callable] = []
var status_chances: Array[float] = []

func _init(t: String, e: GameData.Element, p: int, spr: int, se: Array[Callable] = [], sc: Array[float] = []):
	title = t
	element = e
	power = p
	spReq = spr
	status_effects = se
	status_chances = sc
#
#func _ready():
	#pass # Replace with function body.
#
#
#func _process(delta):
	#pass
