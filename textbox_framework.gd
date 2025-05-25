extends CanvasLayer

#class_name Textbox


## the possible types of line encountered in dialogue.
## LINE is a normal line spoken by a character.
## CHOICE contains a line of dialogue followed by a choice to be made by the player, branching conversations out.
## ERROR means the given line was not of the right format.
enum LineType {
	LINE,
	CHOICE,
	ERROR
}

## returns the type of line read, or an error.
## a proper line of dialogue is an Array containing a name (for the speaker of the line),
## and either a line of dialogue or a dictionary containing a line of dialogue and a collection
## of responses mapped to following conversation blocks.
static func line_type(ln: Array) -> LineType:
	if len(ln) != 2: return LineType.ERROR
	
	match typeof(ln[1]):
		TYPE_STRING: return LineType.LINE
		TYPE_DICTIONARY: return LineType.CHOICE
		_: return LineType.ERROR


# TODO: make each prompt a tuple, containing (prompt: String, choices: Array[String] | null)
#		where choices is a list of options to choose from as answers to this prompt
#		(or null if there is not meant to be a choice).
#
# TODO: actually, do this instead:
var convo_blocks = {
	"start": [
		["Joe", "Hi there!"],
		["Joe", {"How's it hangin'?": { "Doing good!": "res0", "What's it to you?": "res1"} }]
	],
	"res0": [
		["Joe", "I see. That's good to hear!"]
	],
	"res1": [
		["Joe", "How rude! Hmph!"]
	]
  #"start": [
	#[name, "line_0"],
	#[name, "line_1"],
	#...
	#[name, {"line_n": { "response_0": "convo_0", "response_1": "convo_1" } }]
  #],
  #"convo_0": [...],
  #"convo_1": [...],
}



#var prompts := [
	#"I was wondering... why were you so enamored with him before? Could it be... you *like* him? Fufu.",
	#"Well, I won't pry much longer. I wouldn't want to... interrupt anything.",
	#"Ta-ta!"
#]


var prompts: Array[Array] = [ # TODO: deprecated?
	["QWERTY", null]
]
var prompt = "UYFJGKNUJHKYJHJK"
var prompt_idx = 0
var curr_block: String = "start"
var scroll_progress = 0
@export var scroll_speed = 1

var choices = null
var choice_menu = null
var choice_map: Dictionary = {}

var bound_to

func label(): return get_child(1)

static var tb_tscn = load("res://textbox.tscn")
static func from(messages: Array[Array], npc):
	var new_tb = tb_tscn.instantiate()
	new_tb.label().text = ""
	new_tb.convo_blocks = messages
	new_tb.prompt = messages[0][0]
	new_tb.prompt_idx = 0
	new_tb.choices = messages[0][1]
	new_tb.bound_to = npc
	new_tb.curr_block = "start"
	return new_tb


func _ready():
	#prompt = prompts[0]
	#$Label.text = ""
	#Textbox.from()
	GameData.party.slot(0).can_move = false
	bound_to.can_move = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if !is_node_ready(): return
	#
	#if Input.is_action_just_pressed("confirm"):
		## when the user presses 'X', finish the current textbox
		#if scroll_progress < prompt.length():
			#finish_scroll()
		## if the textbox is already done, move on to the next one
		#elif (prompt_idx + 1) < prompts.size():
			## only checked if user presses confirm.
			## So, we can safely do all of our operations for advancing dialogue in here.
			#prompt_idx += 1
			#scroll_progress = 0
			#prompt = prompts[prompt_idx][0]
			#choices = prompts[prompt_idx][1]
		## if all of the prompts are finished, close the textbox
		#else:
			#visible = false
			#GameData.party.slot(0).can_move = true
			#bound_to.can_move = true
			#GameData.current_scene.remove_child(self)
			#GameData.current_scene.interaction = null
			#queue_free()
	#
	#scroll_text()

func _process(delta):
	if !is_node_ready(): return
	
	if Input.is_action_just_pressed("confirm"):
		# when the user presses 'X', finish the current textbox
		if scroll_progress < prompt.length():
			finish_scroll()
		# if the textbox is already done, move on to the next one
		elif (prompt_idx + 1) < convo_blocks[curr_block].size():
			# only checked if user presses confirm.
			# So, we can safely do all of our operations for advancing dialogue in here.
			prompt_idx += 1
			var line_info = convo_blocks[curr_block][prompt_idx]
			var nm = line_info[0]
			var ln = line_info[1]
			match line_type(ln):
				LineType.LINE:
					prompt = Parser.cleanup(ln)
					scroll_progress = 0
				LineType.CHOICE:
					var dialogue = ln.keys(0)
					prompt = Parser.cleanup(dialogue)
					scroll_progress = 0
					
					choice_map = ln[dialogue]
					var choices = choice_map.keys()
					var choice_menu = load("res://ChoiceMenu.tscn").instantiate()
					choice_menu.makeChoices(choices)
					add_child(choice_menu)
					choice_menu.position = Vector2(750, 300)
				_:
					print("Err")
			#prompt = prompts[prompt_idx][0]
			#choices = prompts[prompt_idx][1]
		# if all of the prompts are finished, close the textbox
		elif !choice_menu:
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
		
		if scroll_progress >= prompt.length() && choice_menu:
			var user_choice = await choice_menu.answer # TODO: make choice_menu.answer
			jump(choice_map[user_choice])
			#choice_menu = load("res://ChoiceMenu.tscn").instantiate()
			#choice_menu.makeChoices(choices)
			#add_child(choice_menu)
			#choice_menu.position = Vector2(750, 300)


func finish_scroll():
	label().text = prompt
	scroll_progress = prompt.length()


func on_choice_selection(selection):
	print(selection)
	remove_child(choice_menu)
	choice_menu.queue_free()
	choice_menu = null


func jump(new_block: String):
	curr_block = new_block
	prompt_idx = 0
	scroll_progress = 0
	prompt = ""


func say(w: String):
	prompt = w
	scroll_progress = 0


'''
pseudo-code for iterating over dialogue

if pressed confirm:
	prompt_idx += 1
	var line_info = blocks[curr_block][prompt_idx]
	var nm = line_info[0]
	var ln = line_info[1]
	match line_type(ln):
		LineType.LINE:
			say(Parser.cleanup(ln))
		LineType.CHOICE:
			var dialogue = ln.keys(0)
			say(Parser.cleanup(dialogue))
			ln = ln[dialogue]
			var choices = ln.keys()
			var tb = Textbox.from(choices)
			...
			var user_choice = answer based on index chosen from tb
			jump(ln[user_choice])
		_:
			print("Err")
'''
