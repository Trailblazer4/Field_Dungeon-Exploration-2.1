extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var inventory
var chosen_item
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_node("../Highlight").visible:
		if Input.is_action_just_pressed("confirm") && PauseMenu.cursor == 0 && PauseMenu.pauseQ == 0: # or cursor == get_parent().get_children().find(self) - 2
			PauseMenu.pauseQ = 1
			inventory = load("res://BattleMenu.tscn").instantiate()
			inventory.item_selection.connect(choose_item_use)
			inventory.makeItems(GameData.inventory, 2)
			get_parent().add_child(inventory)
			inventory.z_index = get_parent().z_index + 5
			inventory.position = Vector2.ZERO
			inventory.get_child(0).size = get_viewport_rect().size
			inventory.get_child(1).scale = Vector2.ONE * 1.8
			inventory.get_child(1).position = Vector2(35, 80)
			print("MAKE INVENTORY")
		
		if Input.is_action_just_pressed("cancel") && PauseMenu.pauseQ == 1 && inventory.visible:
			PauseMenu.pauseQ = 0
			get_parent().remove_child(inventory)
			inventory.queue_free()
			inventory = null
	
	#if inventory && !inventory.visible:
		


func choose_item_use(item, box):
	if inventory:
		inventory.visible = false
		get_parent().get_node("Sprites/Pointer").visible = true
		chosen_item = item[0]
		print(chosen_item)
