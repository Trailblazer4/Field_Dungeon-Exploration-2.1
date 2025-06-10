extends Node

class_name Spell

enum weapon_types {
	NONE,
	MAGIC,
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

enum Stat {
	HP,
	SP,
	ATK,
	DEF,
	MAG,
	MGDF,
	SPD
}

var title: String
var element: GameData.Element
var power: int:
	set(v):
		if power == 0:
			power = v
		else:
			push_error("DO NOT CHANGE POWER")

var spReq: int
var status_effects: Array[Callable] = []
var status_chances: Array[float] = []
var weapon_type

func _init(t: String, e: GameData.Element, p: int, spr: int, wt: weapon_types, se: Array[Callable] = [], sc: Array[float] = []):
	title = t
	element = e
	power = p
	spReq = spr
	weapon_type = wt
	status_effects = se
	status_chances = sc
#
#func _ready():
	#pass # Replace with function body.
#
#
#func _process(delta):
	#pass


func damage_formula(user: Entity, target: Entity):
	# Sword: return (user.getAtk() * 0.7 + user.getDef() * 0.3) - (target.getDef())
	if element == GameData.Element.HEAL:
		return user.getMag()
	else:
		var pwr = 0
		match(weapon_type):
			weapon_types.MAGIC:
				pwr = user.getMag() - target.getMgDf()
			weapon_types.BROADSWORD:
				# atk + (def * 0.2) - (enemyDef)
				pwr = user.getAtk() + (user.getDef() * 0.2) - target.getDef()
				print(user.myName, " used broadsword!!!!!!")
			weapon_types.POLEARM:
				pwr = user.getAtk() - (target.getDef() * 2/3)
			weapon_types.STAFF:
				#(atk * 0.8 + mag * 0.4) - (enemyDef * 0.8 + enemyMgdf * 0.2)
				pwr = ((user.getAtk() * 0.8) + (user.getMag() * 0.4)) - ((target.getDef() * 0.8) + (target.getMgDf() * 0.2))
			weapon_types.KATANA:
				#(atk * 0.9 + mag * 0.3) - (enemyDef * 0.7 + enemyMgdf * 0.3)
				pwr = ((user.getAtk() * 0.9) + (user.getMag() * 0.3)) - ((target.getDef() * 0.7) + (target.getMgDf() * 0.3))
			weapon_types.DAGGERS:
				#(atk * 0.7 + spd * 0.5) - (enemyDef)
				pwr = ((user.getAtk() * 0.7) + (user.getSpd() * 0.5)) - target.getDef()
			weapon_types.HANDGUN:
				#(atk * 0.2 + mag * 0.2 + spd * 0.5)
				pwr = (user.getAtk() * 0.2) + (user.getMag() * 0.2) + (user.getSpd() * 0.5)
			weapon_types.NONE, weapon_types.GAUNTLETS:
				pwr = user.getAtk() - target.getDef()
				print(user.myName, " used punch!!")
			weapon_types.HAMMER:
				# (atk * 1.1) - (enemyDef * 0.9) - (enemySpd - spd * 0.6)
				pwr = ((user.getAtk() * 1.1) - (target.getDef() * 0.9)) - ((target.getSpd() - user.getSpd()) * 0.6)
			weapon_types.SNIPER:
				pwr = (user.getAtk() * 0.4) + (user.getMag() * 0.4)
			weapon_types.CHAIN:
				#(atk * 0.7 + mag * 0.3) - (enemyDef * 0.8 + enemyMgdf * 0.2)
				pwr = ((user.getAtk() * 0.7) + (user.getMag() * 0.3)) - ((target.getDef() * 0.8) + (target.getMgDf() * 0.2))
		# if element is not VOID, add some extra damage from user.getMag()
		if element != GameData.Element.VOID:
			pwr += (user.getMag() * 0.07)
		return pwr


func clone() -> Spell:
	var new_spell = Spell.new(
		title,
		element,
		power,
		spReq,
		weapon_type,
		status_effects.duplicate(true),
		status_chances.duplicate(true)
	)
	
	return new_spell
