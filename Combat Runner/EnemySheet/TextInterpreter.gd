extends Node
class_name TextInterpreter

# Parsing ability descriptions

func ability_parser(ability_text: String) -> String:
	var parsed_description = remove_unnecessary(ability_text)
	parsed_description = area_parser(parsed_description)
	parsed_description = condition_parser(parsed_description)
	parsed_description = damage_parser(parsed_description)
	parsed_description = damage_parser2(parsed_description)
	parsed_description = damage_parser3(parsed_description)
	parsed_description = spell_parser(parsed_description)
	parsed_description = save_parser(parsed_description)
	parsed_description = recharge_parser(parsed_description)
	parsed_description = action_parser(parsed_description)
	parsed_description = enemy_name_parser(parsed_description)
	parsed_description = format_parser(parsed_description)
	parsed_description = list_parser(parsed_description)
	return parsed_description

# Removes unnecessary things such as <>'s, \ns, bestiary-ability and bestiary-effects from description
func remove_unnecessary(ability_text: String) -> String:
	var regex = RegEx.new()
	
	# Gets rid of line breaks
	regex.compile("\n")
	var parsed_description = regex.sub(ability_text, " ", true)
	
	# Gets rid of html codes
	regex.compile("(<hr \\/>|<p>|<\\/p>|<em>|<\\/em>)")
	parsed_description = regex.sub(parsed_description, "", true)
	
	# Gets rid of unnecessary ability text
	regex.compile("@UUID\\[Compendium\\.pf2e\\.bestiary-ability-glossary-srd\\.(\\S+)\\]")
	parsed_description = regex.sub(parsed_description, "", true)
	
	# Gets rid of unnecessary bestiary effect text
	regex.compile("@UUID\\[Compendium\\.pf2e\\.bestiary-effects\\.(.+?)\\]")
	parsed_description = regex.sub(parsed_description, "", true)
	
	# Cleans up multiple whitespaces
	regex.compile("\\s{2,}")
	parsed_description = regex.sub(parsed_description, ". ", true)
	
	# Cleans up multiple periods
	regex.compile("\\.\\.")
	parsed_description = regex.sub(parsed_description, ".", true)
	
	return parsed_description

# Turns bursts, cones, etc. into a readable format
func area_parser(ability_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("@Template\\[type:(\\w+)\\|distance:(\\w+)](?:{([^}]*)})?")
	if regex.search(ability_text) == null:
		return ability_text
	var area_text = regex.search(ability_text).strings
	var area_result
	
	# Makes it so "emanation" is not said
	if area_text[1] != "emanation":
		area_result = area_text[2] + " feet " + area_text[1]
	else:
		area_result = area_text[2] + " feet"
	return area_parser(regex.sub(ability_text, area_result))

# Recursive function that keeps sifting through the description for condition text
func condition_parser(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("@UUID\\[Compendium.pf2e.conditionitems.Item.(\\w+)]")
	if regex.search(description_text) == null:
		return description_text
	var condition_text = regex.search(description_text).strings[1]
	condition_text = regex.sub(description_text, condition_text)
	# Next step gets condition text stored as {Condition [number]}
	regex.compile("\\{([A-Za-z]+)\\s(\\d+)\\}")
	if regex.search(condition_text) != null:
		condition_text = regex.sub(condition_text, " " + regex.search(condition_text).strings[2])
	
	return condition_parser(condition_text)

# Gets damage from [[/r xdy[[element]]
func damage_parser(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[\\[/r (\\S+)\\[(\\S+)\\]\\]\\]")
	var damage_strings = regex.search(description_text)
	if regex.search(description_text) == null:
		return description_text
	var damage_text = damage_strings.strings[1] + " " + damage_strings.strings[2]
	return damage_parser(regex.sub(description_text, damage_text))

# Gets damage from @Damage[xdy[element]]
func damage_parser2(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("@Damage\\[(.*?)\\[(.*?)]]")
	var damage_strings = regex.search(description_text)
	if regex.search(description_text) == null:
		return description_text
	var damage_text = damage_strings.strings[1] + " " + damage_strings.strings[2]
	return damage_parser2(regex.sub(description_text, damage_text))

# Gets damage from [[/r xdy[[element]]{more stuff}
	# Having 3 functions for this is not nice but it is a lot faster than making the regex even more gritty
func damage_parser3(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[\\[/r (.*?)]]{([^}]*)}")
	var damage_strings = regex.search(description_text)
	if regex.search(description_text) == null:
		return description_text
	var damage_text = damage_strings.strings[2]
	return damage_parser3(regex.sub(description_text, damage_text))

# Gets spell names from @UUID[Compendium.pf2e.spells-srd.Item.X]
# TD: Add URL here for spell previews.
func spell_parser(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("@UUID\\[Compendium\\.pf2e\\.spells-srd\\.Item\\.(.*?)\\]")
	var damage_strings = regex.search(description_text)
	if regex.search(description_text) == null:
		return description_text
	var spell_text = damage_strings.strings[1]
	return spell_parser(regex.sub(description_text, spell_text))

# Get saves from @Check[type:X|dc:Y|Z]
func save_parser(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("@Check\\[type:(.*?)\\|dc:([0-9]+)(?: *\\|(.+?))?]")
	var save_strings = regex.search(description_text)
	if regex.search(description_text) == null:
		return description_text
	var saving_text: String = "DC " + regex.search(description_text).strings[2]
	for string in save_strings.strings:
		if string.contains("basic:true"):
			saving_text += " basic"
			break
	saving_text += " " + regex.search(description_text).strings[1].capitalize()
	return save_parser(regex.sub(description_text, saving_text))

# Get recharge rounds from [[/br X]{Y}
func recharge_parser(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[\\[/br\\s(.*?)\\]\\{(.*?)\\}")
	if regex.search(description_text) == null:
		return description_text
	return recharge_parser(regex.sub(description_text, regex.search(description_text).strings[2]))

# Parses common actions such as escaping
func action_parser(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("@UUID\\[Compendium\\.pf2e\\.actionspf2e\\.Item\\.(.*?)\\]")
	var action_strings = regex.search(description_text)
	if regex.search(description_text) == null:
		return description_text
	var action_name: String = action_strings.strings[1]
	return action_parser(regex.sub(description_text, action_name))

# Parses enemy names if it refers to another enemy
func enemy_name_parser(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("@UUID\\[Compendium\\.pf2e\\.(.*?)\\.Actor\\.(.*?)\\]")
	var enemy_strings = regex.search(description_text)
	if regex.search(description_text) == null:
		return description_text
	var enemy_name: String = enemy_strings.strings[2]
	return enemy_name_parser(regex.sub(description_text, enemy_name))

# Corrects formatting such as turning <strong> to [b]
func format_parser(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("<strong>")
	if regex.search(description_text) == null:
		return description_text
	var formatted_description: String = regex.sub(description_text, "[b]")
	regex.compile("</strong>")
	return format_parser(regex.sub(formatted_description, "[/b]"))

func list_parser(description_text: String) -> String:
	if !description_text.contains("<ul>"):
		return description_text
	
	# Sets start and end point of list
	var ul_pos: int = description_text.find("<ul>")
		# +5 is to account for </ul> itself
		
	var ul_end_len: int = description_text.find("</ul>") - description_text.find("<ul>") + 5
	var list_text: String = description_text.substr(ul_pos, ul_end_len)
	var list_items: PackedStringArray = list_text.split("</li> <li>")
	
	# Messily goes through every item in the list_items array and gets rid of unneeded html syntax
	var i: int = 0
	for list_item in list_items:
		if list_item.find("<ul> <li>") != -1:
			list_item = list_item.erase(list_item.find("<ul> <li>"), 9)
		if list_item.find("<ul><li>") != -1:
			list_item = list_item.erase(list_item.find("<ul><li>"), 8)
		if list_item.find("</li> </ul>") != -1:
			list_item = list_item.erase(list_item.find("</li> </ul>"), 11)
		if list_item.find("</li></ul>") != -1:
			list_item = list_item.erase(list_item.find("</li></ul>"), 10)
		list_items[i] = list_item
		i += 1
	
	# Finally edits the list into new_description and returns that
	var new_description: String = description_text
	var formatted_list: String = "\n [ul]"
	for list_item in list_items:
		formatted_list += list_item + "\n"
	formatted_list += "[/ul]\n "
	
	new_description = new_description.erase(ul_pos, ul_end_len)
	new_description = new_description.insert(ul_pos, formatted_list)
	
	
	return list_parser(new_description)

# Parsing trait names

func trait_name_parser(trait_name: String) -> String:
	var parsed_trait := range_parser(trait_name)
	return parsed_trait

# Changes "reach-20" to "reach 20 feet", etc.
func range_parser(trait_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("reach-(\\d+)")
	if regex.search(trait_text) == null:
		return trait_text
	
	return regex.sub(trait_text, "reach " + regex.search(trait_text).strings[1] + " feet")
