extends Node2D
# extends Node?

# returns the current size of the active party
func size():
	return len(viewMembers())


# returns a slot from the party
func slot(i: int):
	return get_child(i)


# returns a member within a slot in the party
func member(i: int):
	return slot(i).get_child(0)


# adds a character to the end of the party. returns true if successful and
# false if the party is full
# for moving characters into a potentially full party, see Party.addAt(Entity, int) and
# Party.swap(int, int)
func add(e) -> bool:
	if size() < 4:
		slot(size()).add_child(e)
		var collObj = e.get_child(1)
		e.remove_child(collObj)
		slot(size()-1).add_child(collObj)
		
		if size() == 1:
			restoreCamera()
		
		return true
	return false


func addAt(e, i):
	if slot(i).get_child_count() > 0:
		takeOut(i)
	slot(i).add_child(e)
	var collObj = e.get_child(1)
	e.remove_child(collObj)
	slot(i).add_child(collObj)
	if i == 0:
		restoreCamera()


func fixSlots():
	for i in range(len(get_children()) - 1):
		if slot(i+1).get_children() && !slot(i).get_children():
			var reorder = member(i+1)
			var collObj = slot(i+1).get_child(1)
			slot(i+1).remove_child(reorder)
			slot(i+1).remove_child(collObj)
			slot(i).add_child(reorder)
			slot(i).add_child(collObj)
			reorder.move_child(collObj, 1)


func takeOut(i: int):
	var remMem = member(i)
	var collObj = slot(i).get_child(1)
	slot(i).remove_child(remMem)
	slot(i).remove_child(collObj)
	remMem.add_child(collObj)
	remMem.move_child(collObj, 1)
	if i == 0:
		removeCamera()
	return remMem


# removes the party member from its slot, which is given by the user as i,
# and returns the Entity
func remove(i: int):
	var remMem = takeOut(i)
	fixSlots()
	if i == 0 && size() > 0:
		slot(0).add_child(GameData.partyCamera)
	return remMem


# takes each member out of a party slot
# is usable when transferring party members from this overworld party to battle scene party
# this function returns the cleared members as well
func clear():
	var remMems = []
	var iterations = size()
	removeCamera()
	for i in range(iterations):
		remMems.append(takeOut(i))
		#var remMem = member(i)
		#var collObj = slot(i).get_child(1)
		#slot(i).remove_child(collObj)
		#remMem.add_child(collObj)
		#remMems.append(remMem)
		#slot(i).remove_child(remMem)
	return remMems


func swap(i: int, j: int): # swap places of two characters in party
	var pm1 = takeOut(i)
	var pm2 = takeOut(j)
	addAt(pm2, i)
	addAt(pm1, j)


# to be used when removing member(0)
func removeCamera():
	slot(0).remove_child(GameData.partyCamera)


# to be used when adding child to slot(0)
func restoreCamera():
	slot(0).add_child(GameData.partyCamera)


func viewSlots():
	return get_children()\
	.filter(func(slot): return slot.get_child_count() > 0)


func viewMembers():
	return viewSlots()\
	.map(func(slot): return slot.get_child(0))


func teleport(location: Vector2):
	# also, first reset walk history
	position = location
	for pm in viewSlots():
		pm.position = Vector2.ZERO


func face(direction: Vector2):
	for pm in viewMembers():
		pm.face(direction)


func treeView():
	return '''*****Party*****
*************************
	Slot 1
	%s, %s, %s,
	
	Slot 2
	%s, %s,
	
	Slot 3
	%s, %s,
	
	Slot 4
	%s, %s,''' %\
	[member(0).myName if member(0) else "Empty", str(slot(0).get_child(1)), str(slot(0).get_child(2)),
	member(1).myName if member(1) else "Empty", str(slot(1).get_child(1)),
	member(2).myName if member(2) else "Empty", str(slot(2).get_child(1)),
	member(3).myName if member(3) else "Empty", str(slot(3).get_child(1)),]


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Party formed")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
