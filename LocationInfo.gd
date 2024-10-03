extends Node

class_name LocationInfo

var locationName: String
var subLocationName: String
var enemyPool = [] # [[enemy_name, enemy_prcnt], [enemy_name, enemy_prcnt], ...]
var adjacentLocations = [] # make "portals" in each level's borders which each take from adjacentLocations

var entryPoint: Vector2 = Vector2.ZERO # where was the party node when entering the area?
var partyLocations: Array[Vector2] = [] # where were all of the party members (in relation to entryPoint)?
var partyDirections: Array[Vector2] = [] # which direction were each of them facing?

func _init(ln: String, sln: String = ""):
	locationName = ln
	subLocationName = sln


func addToEnemyPool(enemyName: String, enemyPrcnt: float):
	if enemyPrcnt <= 0.0 or enemyPrcnt > 100.0:
		print("Enemy appearance rate should only be within range .00...01 - 100")
		return
	enemyPool.append([enemyName, enemyPrcnt])


func addAdjacent(locName: String):
	adjacentLocations.add(locationName)
	pass


func _to_string():
	var retStr = ""
	
	retStr += "Location: " + locationName
	if subLocationName:
		retStr += "\n" + subLocationName
	for nme in enemyPool:
		retStr += "\n" + nme[0] + ": " + str(nme[1]) + "%"
	retStr += "\nEntry Point: "+ str(entryPoint)
	retStr += "\nDirections: " + str(partyDirections)
	retStr += "\nLocations: " + str(partyLocations)
	
	return retStr
