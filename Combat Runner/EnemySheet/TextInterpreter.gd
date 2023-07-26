extends Node
class_name TextInterpreter

# Parsing ability descriptions

func ability_parser(ability_text: String) -> String:
	var parsed_description = remove_unnecessary(ability_text)
	parsed_description = area_parser(parsed_description)
	parsed_description = condition_parser(parsed_description)
	parsed_description = damage_parser(parsed_description)
	parsed_description = save_parser(parsed_description)
	parsed_description = recharge_parser(parsed_description)
	parsed_description = format_parser(parsed_description)
	return parsed_description

# Removes unnecessary things such as <>'s, \ns, bestiary-ability and bestiary-effects from description
func remove_unnecessary(ability_text: String) -> String:
	var regex = RegEx.new()
	
	# Gets rid of line breaks
	regex.compile("\n")
	var parsed_description = regex.sub(ability_text, " ", true)
	
	# Gets rid of html codes
	regex.compile("(<hr \\/>|<p>|<\\/p>)")
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
	regex.compile("@Template\\[type:(\\w+)\\|distance:(\\w+)]{([^}]*)}")
	if regex.search(ability_text) == null:
		return ability_text
	var area_text = regex.search(ability_text).strings
	return area_parser(regex.sub(ability_text, area_text[3]))

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

# Get saves from @Check[type:X|dc:Y|Z]
func save_parser(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("@Check\\[type:(.*?)\\|dc:([0-9]+)(?:\\|(.+?))?]")
	var save_strings = regex.search(description_text)
	if regex.search(description_text) == null:
		return description_text
	print(regex.search(description_text).strings[2])
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

# Corrects formatting such as turning <strong> to [b]
func format_parser(description_text: String) -> String:
	var regex = RegEx.new()
	regex.compile("<strong>")
	if regex.search(description_text) == null:
		return description_text
	var formatted_description: String = regex.sub(description_text, "[b]")
	regex.compile("</strong>")
	return format_parser(regex.sub(formatted_description, "[/b]"))

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
