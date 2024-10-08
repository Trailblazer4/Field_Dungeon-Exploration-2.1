extends ProgressBar


@onready var timer = $Timer
@onready var dmg = $DamageBar


var health = 0: set = set_health


func init_health(h):
	max_value = h # make sure to establish max values before setting values
	dmg.max_value = h
	health = h
	value = h
	dmg.value = h
	
	$Label1.text = str(health)
	$Label3.text = str(health)


func set_health(h): # called each time health is changed
	var prev_health = health # record previous health
	health = min(max_value, h) # if h > max amount, health goes to max_amount
	value = health # health value in bar goes down
	$Label1.text = str(health)
	
	if health < prev_health:
		timer.start()
	else:
		dmg.value = health
	
	
func _ready():
	#var burn_symbol = TextureRect.new()
	#burn_symbol.texture = load("res://images/StatusIcons/Burn Symbol.png")
	#get_node("StatusIconList").add_child(burn_symbol)
	#burn_symbol.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	
	#init_health(9923)
	#var new_node = TextureRect.new()
	#new_node.texture = load("res://images/Chio Icon.png")
	#new_node.name = "Burn Symbol"
	#$StatusIconList.add_child(new_node)
	#for node in $StatusIconList.get_children():
		#print(node.name)
	# initialize health to parent entity health
	# if entity is target of a use(), then apply changes to health bar by changing health
	# target.get_node("HealthBar").health -= damage
	# target.get_node("HealthBar").health += heal_amount
	pass

#func _process(delta):
	#if Input.is_action_just_pressed("confirm"):
		#health -= 10

# have green bar on top, instantly dropping when receiving damage

# under the green bar, have a bar with an AnimationPlayer that with an animation called "health_fade"
# this starts the alpha color property of the bar at 255 and end at 0, animating for about half a second
# have a signal that sees that when this animation finishes, the bar's value is set to the current health of the character

#when a character takes damage:
#	$HealthBar/UnderBar/AnimationPlayer.stop()
#	$HealthBar/UnderBar.color.a = 255
#	$HealthBar/OverBar.value = characterHealth
#	wait for timer to finish
#	on_timer_finished():
#		$HealthBar/UnderBar/AnimationPlayer.play("health_fade")

#on_animation_finished(anim_name):
#	if anim_name == "health_fade":
#		$HealthBar/UnderBar.value = characterHealth


func _on_timer_timeout():
	dmg.value = health
