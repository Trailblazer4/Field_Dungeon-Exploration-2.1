extends Node2D

# static class
class_name Parser

static func regex_from(pattern: String) -> RegEx:
	var regex = RegEx.new()
	regex.compile(pattern)
	return regex

# TODO: think of more things to check like
# if inventory contains item (\\\\if \\\\has item( x amount)?),
# if character is equipped with something (\\\\if \\\\equipped name item, such as \\\\if \\\\equipped \\\\party 0 name Primal)
# can also use \\\\has for comparing player's (numerical) stats.
# string stats such as equipment, name, etc. are handled differently by other commands.
# if has spell or move can be handled separately as well such as \\\\learned skill
static var patterns: Dictionary = {
	"party": regex_from("\\\\\\\\party (\\d+) ([a-zA-Z_]\\w*)(?: ?@(\\d+))?"),
	"give": regex_from("\\\\\\\\give (.+) x (\\d+)"),
	"romance": regex_from("\\\\\\\\romance (.+) (\\d+)"),
	"flag": regex_from("\\\\\\\\flag (\\w[\\w ]*)::(\\w[\\w ]*)::(\\d+)( flip)?"),
	"if": regex_from("\\\\\\\\if ([\\w: \\\\\\?<>=@\\.]+)\\s*{\\s*(\\w[\\w ]*?)\\s*\\|\\s*(\\w[\\w ]*?)\\s*}"),
	"jump": regex_from("\\\\\\\\jump (\\w[\\w ]*)"),
	"has": regex_from("\\\\\\\\has ([\\w\\\\][\\w\\\\@ ]*\\w)(?: ([<>=])(=)?x (\\d+))?"),
	"stronger": regex_from("\\\\\\\\stronger ([\\w\\\\][\\w\\\\ ]*?)\\s+v\\s+([\\w\\\\][\\w\\\\ ]*?)\\s+\\.([a-zA-Z_]\\w*)(?: ?@(\\d+))?"),
	"equipped": regex_from("\\\\\\\\equipped ([\\w\\\\][\\w\\\\ ]*) (([\\w][\\w ]*\\w))")
}

# TODO: delete/comment out once deployed
@export var example_lines: Array[String]


static var commands = ["\\\\give", "\\\\romance"]


static func process_cmd(cmd: String):
	var first_word = cmd.substr(0, cmd.find(" "))
	
	# TODO: works like a charm! Make it so that there is a pop-up displaying the item(s),
	# or the romance, etc.
	# Or, maybe we can have a flag for each of these on whether a pop-up is displayed or dialogue just continues.
	# This can help with having hidden effects like hidden romance boosts, or items added to your inventory naturally
	# in a cutscene. But if we want there to be a pop-up, we can turn the flag on to say to put it.
	# We can make this flag true by default to always show a pop-up unless a false flag indicates to make it hidden.
	match first_word:
		"\\\\party":
			var srch = patterns["party"].search(cmd)
			
			var idx = srch.get_string(1)
			var field = srch.get_string(2)
			var field_idx = srch.get_string(3)
			print(field_idx)
			
			var member: Entity = GameData.party.member(int(idx))
			
			if !field_idx.is_empty():
				return member.get(field)[int(field_idx)]
			else:
				return member.get(field)
		
		"\\\\give":
			var srch = patterns["give"].search(cmd)
			var item_name = srch.get_string(1)
			var item_amt = int(srch.get_string(2))
			
			#GameData.add_to_inventory(item_name, int(item_amt)) # in progress
			print("You added %s %s%s to your inventory." % [str(item_amt), item_name, "s" if item_amt != 1 else ""])
			var item_popup = load("res://popup.tscn").instantiate()
			var maybe_plural = ["", ""]
			if item_amt != 1:
				maybe_plural[0] = str(item_amt) + " "
				maybe_plural[1] = "s"
			item_popup.get_child(0).text = "You received %s%s%s." % [maybe_plural[0], item_name, maybe_plural[1]]
			return item_popup
		
		"\\\\romance": # nested commands.
					   # might just process \\\\party commands first always to avoid.
			var srch = patterns["romance"].search(cmd)
			
			var whom = srch.get_string(1)
			var rom_amt = int(srch.get_string(2))
			
			if whom.begins_with("\\\\party"): whom = process_cmd(whom)
			
			print("You romanced %s by %d." % [whom, rom_amt])
			var rom_popup = load("res://popup.tscn").instantiate()
			rom_popup.get_child(0).text = "You got closer to %s." % whom
			return rom_popup
		"\\\\flag":
			# GameData will contain flags for events that have occurred. If predicate is satisfied,
			# then go to a true condition, else to a false condition
			# this command will return true or false on whether the given flag is true or false.
			# there will be an \\\\if command that uses \\\\flag to check t/f values to do things,
			# like get_jump(if_stmt) returning the right jump location from the if.
			
			var srch = patterns["flag"].search(cmd)
			var where = srch.get_string(1)
			var whom = srch.get_string(2)
			var idx = int(srch.get_string(3))
			var flip = srch.get_string(4)
			if flip: GameData.flags[where][whom][idx] = !GameData.flags[where][whom][idx]
			
			return GameData.flags[where][whom][idx]
		"\\\\jump":
			return patterns["jump"].search(cmd).get_string(1)
		"\\\\has":
			var srch: RegExMatch = patterns["has"].search(cmd)
			var item_name = srch.get_string(1)
			var item_amt = -1
			
			var op = null
			var valid = 0
			for i in range(1, srch.get_group_count()+1):
				if srch.get_strings()[i] != "": valid += 1
			
			match valid:
				1: return GameData.inventory.any(func(item): return item[0].title == item_name)
				_:
					item_amt = int(srch.get_string(4))
					op = srch.get_string(2) + srch.get_string(3)
			
			var comp_func: Callable
			
			if cmd.contains("\\\\party"):
				var found_stat = process_cmd(cmd.substr(cmd.find("\\\\party")))
				match op:
					"<": comp_func = func(item): return item < item_amt
					">": comp_func = func(item): return item > item_amt
					"<=": comp_func = func(item): return item <= item_amt
					">=": comp_func = func(item): return item >= item_amt
					"=", "==": comp_func = func(item): return item == item_amt
				return comp_func.call(found_stat)

			
			match op:
				"<": comp_func = func(item): return item[0].title == item_name && item[1] < item_amt
				">": comp_func = func(item): return item[0].title == item_name && item[1] > item_amt
				"<=": comp_func = func(item): return item[0].title == item_name && item[1] <= item_amt
				">=": comp_func = func(item): return item[0].title == item_name && item[1] >= item_amt
				"=", "==": comp_func = func(item): return item[0].title == item_name && item[1] == item_amt
			
			return GameData.inventory.any(comp_func)
		"\\\\stronger":
			var srch = patterns["stronger"].search(cmd)
			var p1 = srch.get_string(1)
			var p2 = srch.get_string(2)
			var stat = srch.get_string(3)
			var idx = srch.get_string(4)
			
			if p1.begins_with("\\\\party"): p1 = process_cmd(p1)
			if p2.begins_with("\\\\party"): p2 = process_cmd(p2)
			
			if idx:
				p1 = GameData.party.find(p1).get(stat)[int(idx)]
				p2 = GameData.party.find(p2).get(stat)[int(idx)]
			else:
				p1 = GameData.party.find(p1).get(stat)
				p2 = GameData.party.find(p2).get(stat)
			
			return p1 > p2
		"\\\\equipped":
			var srch = patterns["equipped"].search(cmd)
			var player = srch.get_string(1)
			var eq = srch.get_string(2)
			
			if player.begins_with("\\\\party"): player = process_cmd(player)
			player = GameData.party.find(player)
			
			for e in player.current_equipment:
				if player.current_equipment[e].title == eq:
					return true
			return false


static func cleanup(messy_msg: String) -> String:
	var srch = patterns["party"].search(messy_msg)
	while srch:
		var start = srch.get_start()
		var end = srch.get_end()
		var processed0 = process_cmd(messy_msg.substr(start, end))
		
		messy_msg = messy_msg.substr(0, start) + str(processed0) + messy_msg.substr(end)
		
		srch = patterns["party"].search(messy_msg)
	
	return messy_msg


static func get_jump(stmt: String):
	if stmt.begins_with("\\\\if"):
		var flag = stmt.find("\\\\has")
		if flag == -1:
			flag = stmt.find("\\\\flag")
		if flag == -1:
			flag = stmt.find("\\\\stronger")
		if flag == -1:
			flag = stmt.find("\\\\equipped")
		flag = process_cmd(stmt.substr(flag))
		
		var srch = patterns["if"].search(stmt)
		var tt = srch.get_string(2)
		var ff = srch.get_string(3)
	
		return tt if flag else ff
	elif stmt.begins_with("\\\\jump"):
		return process_cmd(stmt)
	else:
		print("ERROR")
		return "ERROR"


func _ready():
	Overlay.color.a = 0
	
	var collect = JSON.parse_string(FileAccess.open("res://conversations.json", FileAccess.READ).get_as_text())
	#print(process_cmd("\\\\party 0 stats @0"))
	#print(process_cmd("\\\\has Elixir ==x 99"))
	#print(get_jump("\\\\if \\\\flag Town::Joe::0 { a bitch | ass bitch }"))
	#print(get_jump("\\\\if \\\\flag Town::Joe::1 { a | b  }"))
	#print(get_jump("\\\\if \\\\flag Town::Joe::2  { a  |  b }"))
	#print(get_jump("\\\\if \\\\has Elixir { a | b }"))
	#print(get_jump("\\\\if \\\\has Elixir <x 99    { a |  b   }"))
	#print(get_jump("\\\\if \\\\has Elixir >=x 99  {\na | b }"))
	#print(get_jump("\\\\if \\\\has Elixir <=x 100         { a   |  b      }"))
	#print(get_jump("\\\\if \\\\has Elixir >x 3         { a bitch   |  ahh bitch      }"))
	#print(get_jump("\\\\if \\\\has Elixir ==x 99         { a   |  b      }"))
	#print(get_jump("\\\\if \\\\has Elixir =x 98         { a   |  b      }"))
	# Expected Output: b a b a b a a a a b
	# thank god it all works
	
	#print(process_cmd("\\\\flag Town::Joe 0"))
	#print(get_jump("\\\\if \\\\flag Town::Joe 0 y2 | y1"))
	#print(process_cmd("\\\\flag Town::Joe 0 flip"))
	#print(get_jump("\\\\if \\\\flag Town::Joe 0 y2 | y1"))
	
	#GameData.addToParty(GameData.ALL_PLAYABLE_CHARACTERS[0], 0)
	#GameData.addToParty(GameData.ALL_PLAYABLE_CHARACTERS[1], 1)
	#GameData.addToParty(GameData.ALL_PLAYABLE_CHARACTERS[2], 2)
	#GameData.party.member(2).stats[1] += 1
	#process_cmd("\\\\stronger \\\\party 0 name v \\\\party 1 name .stats @1")
	#print(get_jump("\\\\if \\\\stronger Cinnamoroll v Misty .stats @0 { a | b }"))
	#print(get_jump("\\\\if \\\\stronger Link v Cinnamoroll .stats @1 { a | b }"))
	#print(get_jump("\\\\if \\\\stronger \\\\party 2 name v Cinnamoroll .stats @1 { a | b }"))
	
	#GameData.addToParty(GameData.ALL_PLAYABLE_CHARACTERS[1], 1)
	#print(process_cmd("\\\\party 0 stats @0"))
	#print(process_cmd("\\\\has \\\\party 0 stats @0 <=x 180"))
	#print(get_jump("\\\\if \\\\has \\\\party 0 stats @0 >=x 181 { a | b }"))
	
	#print(get_jump("\\\\if \\\\flag Town 0 do | dont"))
#
	#for line in example_lines:
		#if commands.any(func(w): return line.begins_with(w)):
			#process_cmd(line)
		#else:
			#print(cleanup(line))
	
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
