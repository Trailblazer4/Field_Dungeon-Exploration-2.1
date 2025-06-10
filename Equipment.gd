extends Node

class_name Equipment

enum weapons {
	NONE,
	MISSING,
	BROADSWORD,
	POLEARM,
	STAFF,
	KATANA,
	DAGGERS,
	HANDGUN,
	GAUNTLETS,
	HAMMER,
	SNIPER,
	CHAIN,
}

enum armors {
	NONE = -1,
	LIGHT = -2,
	HEAVY = -3,
}

enum places { # where to go on body
	WEAPON,
	HEAD,
	ARMOR,
	LEG,
	SHOE,
	GLOVE,
	ACSRY,
}

var title
var type
var place
var element
var stats = [0, 0, 0, 0, 0, 0, 0] # stats added to user when they equip this piece
var moveset: Array[Spell] = [] # spells that enter user's moveset when they equip this piece

func _init(n, p, t, e, s, moves: Array[Spell] = []):
	title = n
	place = p
	type = t
	element = e
	stats = s
	moveset = moves


func move_titles():
	var moves = []
	for move in moveset:
		moves.append(move.title)
	return moves


func basic_attack():
	match type:
		weapons.NONE, weapons.MISSING, weapons.GAUNTLETS:
			return "Punch"
		weapons.BROADSWORD:
			return "Slash"
		weapons.KATANA:
			return "Cut"
		weapons.POLEARM:
			return "Pierce"
		weapons.DAGGERS:
			return "Stab"
		weapons.STAFF:
			return "Thrust"
		weapons.HANDGUN:
			return "Shoot"
		weapons.SNIPER:
			return "Snipe"
		weapons.HAMMER:
			return "Slam"
		weapons.CHAIN:
			return "Whip"


func _to_string():
	return '''%s
HP: %d   SP: %d
Atk: %d  Def: %d
Mag: %d  MgDf: %d
Spd: %d''' % ([title] + stats) + "\n\n" + ", ".join(move_titles())
