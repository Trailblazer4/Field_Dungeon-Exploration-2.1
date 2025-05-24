extends Node2D

# static class
class_name Parser

static func regex_from(pattern: String) -> RegEx:
	var regex = RegEx.new()
	regex.compile(pattern)
	return regex

static var patterns: Dictionary = {
	"party": regex_from("\\\\\\\\party (\\d+) ([a-zA-Z_]\\w*)( @\\d+)?"),
	"give": regex_from("\\\\\\\\give (.+) x (\\d+)"),
	"romance": regex_from("\\\\\\\\romance (.+) (\\d+)")
}

# TODO: delete/comment out once deployed
@export var example_lines: Array[String]


static var commands = ["\\\\give", "\\\\romance"]


static func process_cmd(cmd: String):
	var first_word = cmd.substr(0, cmd.find(" "))
	
	match first_word:
		"\\\\party":
			var srch = patterns["party"].search(cmd)
			
			var idx = srch.get_string(1)
			var field = srch.get_string(2)
			var field_idx = srch.get_string(3)
			
			var member: Entity = GameData.party.member(int(idx))
			
			if !field_idx.is_empty():
				return member.get(field)[int(field_idx)]
			else:
				return member.get(field)
		
		"\\\\give":
			var srch = patterns["give"].search(cmd)
			var item_name = srch.get_string(1)
			var item_amt = srch.get_string(2)
			
			#GameData.add_to_inventory(item_name, int(item_amt)) # in progress
			print("You added %s %s%s to your inventory." % [item_amt, item_name, "s" if int(item_amt) != 1 else ""])
		
		"\\\\romance": # nested commands.
					   # might just process \\\\party commands first always to avoid.
			var srch = patterns["romance"].search(cmd)
			
			var whom = srch.get_string(1)
			var rom_amt = srch.get_string(2)
			
			if whom.begins_with("\\\\party"): whom = process_cmd(whom)
			
			print("You romanced %s by %d." % [whom, int(rom_amt)])


static func cleanup(messy_msg: String) -> String:
	var srch = patterns["party"].search(messy_msg)
	while srch:
		var start = srch.get_start()
		var end = srch.get_end()
		var processed0 = process_cmd(messy_msg.substr(start, end))
		
		messy_msg = messy_msg.substr(0, start) + str(processed0) + messy_msg.substr(end)
		
		srch = patterns["party"].search(messy_msg)
	
	return messy_msg


func _ready():
	GameData.addToParty(GameData.ALL_PLAYABLE_CHARACTERS[0], 0)
	GameData.addToParty(GameData.ALL_PLAYABLE_CHARACTERS[1], 1)

	for line in example_lines:
		if commands.any(func(w): return line.begins_with(w)):
			process_cmd(line)
		else:
			print(cleanup(line))
	
	#
	#process_cmd("\\\\give Silver Sword x 0")
	#
	#print(process_cmd("\\\\party 0 stats 5"))
	#process_cmd("\\\\romance Celeste 4")
	#process_cmd("\\\\romance \\\\party 0 name 4")
	#
	#
	#var msg = cleanup("\\\\party 0 name attacked \\\\party 1 name! How sad.")
	#print(msg)
	
	#var re1 = RegEx.new()
	#re1.compile("\\\\\\\\party (\\d+) ([a-zA-Z_]\\w*)( \\d+)?")
	#
	#
	#var srch = re1.search(msg)
	#while srch:
		#var start = srch.get_start()
		#var end = srch.get_end()
		#print("%d %d" % [start, end])
		#var processed0 = process_cmd(msg.substr(start, end))
		#print(processed0)
		#
		#msg = msg.substr(0, start) + processed0 + msg.substr(end)
		#print(msg)
		#
		#srch = re1.search(msg)
	pass
