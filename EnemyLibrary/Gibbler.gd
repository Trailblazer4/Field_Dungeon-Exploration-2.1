extends Entity


# Called when the node enters the scene tree for the first time.
func _init():
	level = 1
	myName = "Gibbler"
	print("initiating stats")
	stats = [
		120, # HP
		1000, # SP
		16, # atk
		10, # def
		16, # mag
		6, # mgdf
		5, # spd
	]
	maxHP = stats[0]; maxSP = stats[1]
	speedCounter = 0


func _ready():
	moveset.append(GameData.SpellLibrary["Punch"])
	moveset.append(GameData.SpellLibrary["Super Punch"])
	moveset.append(GameData.SpellLibrary["Ard"])
	moveset.append(GameData.SpellLibrary["Temp"])
	print(moveset[1].title)
