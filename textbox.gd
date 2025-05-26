extends CanvasLayer

class_name Textbox

signal finished_line

## the possible types of line encountered in dialogue.
## LINE is a normal line spoken by a character.
## CHOICE contains a line of dialogue followed by a choice to be made by the player, branching conversations out.
## ERROR means the given line was not of the right format.
enum LineType {
	LINE,
	CHOICE,
	COMMAND,
	CONDITION,
	JUMP,
	FLAG,
	ERROR
}

var SCREEN_CENTER = DisplayServer.screen_get_size() / 2 # i dont think this works

## returns the type of line read, or an error.
## a proper line of dialogue is an Array containing a name (for the speaker of the line),
## and either a line of dialogue or a dictionary containing a line of dialogue and a collection
## of responses mapped to following conversation blocks.
static func line_type(ln: Variant) -> LineType:
	## LINE, CHOICE, COMMAND, ERROR
	if ln is Array:
		match len(ln):
			2: return LineType.LINE
			3: return LineType.CHOICE
			_: return LineType.ERROR
	else:
		if ln.begins_with("\\\\if"): return LineType.CONDITION
		if ln.begins_with("\\\\jump"): return LineType.JUMP
		if ln.begins_with("\\\\flag"): return LineType.FLAG
		if ln.begins_with("\\\\"): return LineType.COMMAND
		return LineType.ERROR


## holds all of the possible 'routes' for the conversation to go down
var convo_blocks: Dictionary = {}
## holds the current prompt to be spoken
var prompt: String
## the index of the current prompt, within this block of conversation
var prompt_idx: int = 0
## the block of conversation currently happening. Must always start at "start"
var curr_block: String = "start"
## tracks how much progress of the current prompt has been read
var scroll_progress: int = 0
## the speed of this message being output in the textbox
@export var scroll_speed: int = 1

## tracks the choices being shown on screen.
var choices = null
var choice_menu = null
## keeps track of the mappings between player answers and following blocks of dialogue
var choice_map: Dictionary = {}

var bound_to

func label(): return get_child(1)
func set_speaker(nm: String): get_child(2).get_child(0).text = nm

static var tb_tscn = load("res://textbox.tscn")
static func from(messages: Dictionary, npc):
	var new_tb = tb_tscn.instantiate()
	new_tb.label().text = ""
	new_tb.convo_blocks = messages
	new_tb.prompt_idx = 0
	new_tb.curr_block = "start"
	new_tb.process_prompt()
	new_tb.bound_to = npc
	return new_tb


func _ready():
	GameData.party.slot(0).can_move = false
	bound_to.can_move = false


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
			process_prompt()
		# if all of the prompts are finished, close the textbox
		elif !choice_menu:
			close()
	
	scroll_text()


var finished = false
func scroll_text():
	if scroll_progress < prompt.length():
		finished = false
		label().text = prompt.substr(0, scroll_progress + scroll_speed)
		scroll_progress += scroll_speed
	elif !finished:
		finished = true
		finished_line.emit()


func finish_scroll():
	label().text = prompt
	scroll_progress = prompt.length()


func jump(new_block: String):
	print(new_block)
	curr_block = new_block
	prompt_idx = 0
	if convo_blocks[curr_block].is_empty() || convo_blocks[curr_block] == null:
		close()
		return
	process_prompt()
	scroll_progress = 0


func add_choice_menu(ch):
	await finished_line
	choice_map = ch
	choices = choice_map.keys()
	choice_menu = load("res://ChoiceMenu.tscn").instantiate()
	choice_menu.makeChoices(choices)
	add_child(choice_menu)
	choice_menu.position = Vector2(750, 300)


func process_prompt():
	if prompt_idx >= len(convo_blocks[curr_block]): close(); return
	
	var line_info = convo_blocks[curr_block][prompt_idx]
	
	var lin_typ = line_type(line_info)
	
	if get_child(0).visible == (lin_typ == LineType.COMMAND):
		toggle_display()
	
	match lin_typ:
		LineType.LINE:
			var nm = line_info[0]
			var ln = line_info[1]
			set_speaker(nm)
			prompt = Parser.cleanup(ln)
			scroll_progress = 0
		LineType.CHOICE:
			var nm = line_info[0]
			var ln = line_info[1]
			var ch = line_info[2]
			set_speaker(nm)
			prompt = Parser.cleanup(ln)
			scroll_progress = 0
			add_choice_menu(ch)
		LineType.COMMAND:
			var popup = Parser.process_cmd(line_info)
			add_child(popup)
			popup.position = Vector2(575 - (popup.size.x / 2), 150)
			#prompt_idx += 1 maybe have a boolean to control whether this happens automatically or not
			#process_prompt()
		LineType.CONDITION, LineType.JUMP:
			var jump_loc = Parser.get_jump(line_info)
			print("Jumping to: ", jump_loc)
			jump(jump_loc)
		LineType.FLAG:
			print(Parser.process_cmd(line_info))
			prompt_idx += 1
			process_prompt()
		_:
			print("Err")


func say(w: String):
	prompt = w
	scroll_progress = 0
	label().text = ""


func got_answer(answer):
	print(answer)
	remove_child(choice_menu)
	choice_menu.queue_free()
	choice_menu = null
	choices = null
	jump(choice_map[answer])


func close():
	visible = false
	GameData.party.slot(0).can_move = true
	bound_to.can_move = true
	GameData.current_scene.remove_child(self)
	GameData.current_scene.interaction = null
	queue_free()


func toggle_display():
	for child in get_children():
		child.visible = !child.visible
