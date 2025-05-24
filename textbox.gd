extends CanvasLayer

class_name Textbox


# TODO: make each prompt a tuple, containing (prompt: String, choices: Array[String] | null)
#		where choices is a list of options to choose from as answers to this prompt
#		(or null if there is not meant to be a choice).
#		
#var prompts := [
	#"I was wondering... why were you so enamored with him before? Could it be... you *like* him? Fufu.",
	#"Well, I won't pry much longer. I wouldn't want to... interrupt anything.",
	#"Ta-ta!"
#]
var prompts: Array[Array]
var prompt = "UYFJGKNUJHKYJHJK"
var prompt_idx = 0
var scroll_progress = 0
@export var scroll_speed = 1

var choices = null
var choice_menu = null

var bound_to

func label(): return get_child(1)

static var tb_tscn = load("res://textbox.tscn")
static func from(messages: Array[Array], npc):
	var new_tb = tb_tscn.instantiate()
	new_tb.label().text = ""
	new_tb.prompts = messages
	new_tb.prompt = messages[0][0]
	new_tb.choices = messages[0][1]
	new_tb.bound_to = npc
	return new_tb


func _ready():
	#prompt = prompts[0]
	#$Label.text = ""
	#Textbox.from()
	GameData.party.slot(0).can_move = false
	bound_to.can_move = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_node_ready(): return
	
	if Input.is_action_just_pressed("confirm"):
		# when the user presses 'X', finish the current textbox
		if scroll_progress < prompt.length():
			finish_scroll()
		# if the textbox is already done, move on to the next one
		elif (prompt_idx + 1) < prompts.size():
			prompt_idx += 1
			scroll_progress = 0
			prompt = prompts[prompt_idx][0]
			choices = prompts[prompt_idx][1]
		# if all of the prompts are finished, close the textbox
		else:
			visible = false
			GameData.party.slot(0).can_move = true
			bound_to.can_move = true
			GameData.current_scene.remove_child(self)
			GameData.current_scene.interaction = null
			queue_free()
	
	scroll_text()


func scroll_text():
	if scroll_progress < prompt.length():
		label().text = prompt.substr(0, scroll_progress + scroll_speed)
		scroll_progress += scroll_speed
		
		if scroll_progress >= prompt.length() && choices:
			choice_menu = load("res://ChoiceMenu.tscn").instantiate()
			choice_menu.makeChoices(choices)
			add_child(choice_menu)
			choice_menu.position = Vector2(750, 300)


func finish_scroll():
	label().text = prompt
	scroll_progress = prompt.length()


func on_choice_selection(selection):
	print(selection)
	remove_child(choice_menu)
	choice_menu.queue_free()
	choice_menu = null
