@icon("res://images/Chio Icon.png")
extends CharacterBody2D

class_name Entity

var stats: Array[int]
var add_mod: Array[int] = [0, 0, 0, 0, 0, 0, 0] # add_mod and mult_mod are affected by de/buffs, equipment, statuses, etc.
var mult_mod: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

var maxHP; var maxSP
var SPEED = 100.0
var myName: String
var speedCounter: int
var moveset: Array[Spell] = []
@onready var basic_attack: Spell = GameData.SpellLibrary["Punch"]
var status_effects: Array[Callable] = []
var defending: bool = false

var health_bar

func _init():
	stats = [180, 24, 20, 15, 13, 12, 8]
	maxHP = stats[0]; maxSP = stats[1]
	speedCounter = 0


func setHP(shp):
	stats[0] = shp

func getHP():
	return (stats[0] + add_mod[0]) * mult_mod[0]

func setMaxHP(shp):
	maxHP = shp

func getMaxHP():
	return maxHP

func setSP(ssp):
	stats[1] = ssp

func getSP():
	return (stats[1] + add_mod[1]) * mult_mod[1]

func setMaxSP(ssp):
	maxSP = ssp

func getMaxSP():
	return maxSP

func setAtk(satk):
	stats[2] = satk

func addAtk(m: int):
	add_mod[2] += m

func multAtk(m: float):
	mult_mod[2] *= m

func getAtk():
	return (stats[2] + add_mod[2]) * mult_mod[2]

func setDef(sdef):
	stats[3] = sdef

func addDef(m: int):
	add_mod[3] += m

func multDef(m: float):
	mult_mod[3] *= m

func getDef():
	return (stats[3] + add_mod[3]) * mult_mod[3]
	
func setMag(smag):
	stats[4] = smag

func addMag(m: int):
	add_mod[4] += m

func multMag(m: float):
	mult_mod[4] *= m

func getMag():
	return (stats[4] + add_mod[4]) * mult_mod[4]

func setMgDf(smgdf):
	stats[5] = smgdf

func addMgDf(m: int):
	add_mod[5] += m

func multMgDf(m: float):
	mult_mod[5] *= m

func getMgDf():
	return (stats[5] + add_mod[5]) * mult_mod[5]

func setSpd(sspd):
	stats[6] = sspd

func addSpd(m: int):
	add_mod[6] += m

func multSpd(m: float):
	mult_mod[6] *= m

func getSpd():
	return (stats[6] + add_mod[6]) * mult_mod[6]


func updateCounter(reset: bool = false):
	if reset:
		speedCounter = 0
	else:
		speedCounter += stats[6]

func use(skill, target: Entity): # skill is of type Spell or Item
	var dmg_mod: float = 1.0
	var chance: Array[float] = skill.status_chances
	if skill is Spell:
		var totalDmg = (skill.power + getMag()) # - (target.getMgDf())
		if skill.element == GameData.Element.HEAL:
			target.setHP(target.getHP() + totalDmg)
		else:
			var until = len(target.status_effects)
			var handle_status_res = handle_statuses(until, target, skill, dmg_mod, chance)
			dmg_mod = handle_status_res[0]
			chance = handle_status_res[1]

			totalDmg = round(totalDmg * dmg_mod)
			target.setHP(target.getHP() - (totalDmg - target.getMgDf()))
			for j in range(len(chance)):
				if randi_range(0,99) < chance[j]:
					target.status_effects.append(skill.status_effects(j))
					skill.status_effects(j).call(target, 0)
	elif skill is Item:
		skill.apply_effect(target)
	else:
		print("Error: Selected action is neither Spell nor Item")

	if target.getHP() < 0:
		target.setHP(0)
	if target.getHP() > target.getMaxHP():
		target.setHP(target.getMaxHP())
	target.health_bar.health = target.getHP()


func handle_statuses(until: int, target: Entity, skill, dm: float, chance: Array[float]):
	var go_back: int = 0
	for i in range(until):
		var status = target.status_effects[i - go_back]
		var status_result = status.call(target, 4, skill)
		if status_result[0]:
			status.call(target, 1) # to remove effect
			target.status_effects.erase(status)
			go_back += 1
			if status_result[1] is float:
				dm *= status_result[1] # dmg_mod will be a float in Entity.use(),
											  #initialized to 1.0
				chance[i] *= status_result[2] # chance will be a float to mult the chance
											# of a move's status to land, initially set
											# to 1.0
			else:
				target.status_effects.append(status_result[1])
	return [dm, chance]
