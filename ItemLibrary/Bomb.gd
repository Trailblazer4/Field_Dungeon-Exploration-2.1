extends Item


func _init():
	title = "Bomb"


func apply_effect(e: Entity):
	print(e.myName, " exploded")
	e.setHP(e.getHP() - 45)
