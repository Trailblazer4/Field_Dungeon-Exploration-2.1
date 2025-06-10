extends Item


func _init():
	title = "Elixir"


func apply_effect(e: Entity):
	print(e.myName + " healed all HP and SP")
	
	e.setHP(e.getMaxHP())
	e.setSP(e.getMaxSP())
