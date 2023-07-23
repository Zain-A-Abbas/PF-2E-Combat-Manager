extends Node
class_name TextInterpreter

func ability_parser(ability_text: String) -> String:
	var parsed_description = remove_unnecessary(ability_text)
	parsed_description = condition_parser(parsed_description)
	parsed_description = template_parser(parsed_description)
	print(parsed_description)
	print("")
	return "A"

# Removes <>'s and \n's from description
func remove_unnecessary(ability_text: String) -> String:
	'if !ability_text.contains("\n<p>"):
		return ability_text
	var description_start_index: int = ability_text.find("\n<p>") + 4
	var description_end_index: int = ability_text.find("</p>", description_start_index)
	var parsed_description = ability_text.substr(description_start_index, description_end_index - description_start_index)
	return remove_unnecessary(parsed_description)'
	
	var regex = RegEx.new()
	regex.compile("</?p>")
	var parsed_description = regex.sub(ability_text, "", true)
	return parsed_description

# Recursive function that keeps sifting through the description for condition text
func condition_parser(description_text: String) -> String:
	if !description_text.contains("@UUID[Compendium.pf2e.conditionitems.Item."):
		return description_text
	var condition_start_index: int = description_text.find("@UUID[Compendium.pf2e.conditionitems.Item.") + 41
	var condition_end_index: int = description_text.find("]", condition_start_index)
	var parsed_condition = description_text.substr(condition_start_index + 1, condition_end_index - condition_start_index - 1).to_lower()
	var parsed_description = description_text.erase(condition_start_index - 41, 42 + parsed_condition.length() + 1)
	parsed_description = parsed_description.insert(condition_start_index - 41, parsed_condition)
	return condition_parser(parsed_description)

func template_parser(description_text: String) -> String:
	if !description_text.contains("@Template[type:"):
		return description_text
	
	var template_start_index: int = description_text.find("@Template[type:")
	var aoe_text_index: int = description_text.find("{", template_start_index)
	var parsed_description = description_text.erase(template_start_index, aoe_text_index - template_start_index + 1)
	parsed_description = parsed_description.erase(parsed_description.find("}", template_start_index), 1)
	return template_parser(parsed_description)
