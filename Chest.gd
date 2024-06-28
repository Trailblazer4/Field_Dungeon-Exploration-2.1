extends StaticBody2D

var chestNum: int
var place: String
#@onready var chest_item_data = load("res://ItemLibrary/%s.tscn" % GameData.chests[place][chestNum][0])
#hello
func _process(delta):
	if Input.is_key_pressed(KEY_K) and GameData.party.get_child(0) in $Area2D.get_overlapping_bodies():
		open()


func setChest(cn: int, pl: String, pos: Vector2):
	chestNum = cn
	place = pl
	position = pos
	if GameData.chests[place][chestNum][1]:
		$Sprite2D.set_frame(1)
	else:
		$Sprite2D.set_frame(0)


func open():
	if !GameData.chests[place][chestNum][1]:
		GameData.chests[place][chestNum][1] = true
		$Sprite2D.set_frame(1)
		var chest_item_data = load("res://ItemLibrary/%s.tscn" % GameData.chests[place][chestNum][0])
		var chest_item: Item = chest_item_data.instantiate()
		print("You got ", chest_item.title)
		add_child(chest_item)
		chest_item.position.y -= 10
		$Timer.set_wait_time(2.0); $Timer.start()
		#print(GameData.chests)
		#print(GameData.inventory)


func setIcon(path: String):
	$Sprite2D.set_texture(path)


func _on_timer_timeout():
	var chest_item = get_child(-1)
	remove_child(chest_item)
	GameData.add_to_inventory(chest_item)
	print(GameData.inventory)
