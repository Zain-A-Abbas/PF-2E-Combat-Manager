extends Control

const trait_template := preload("res://Trait.tscn")
const SHEET_CONTENT := preload("res://EnemySheet/SheetContent.tscn")

const ONE_ACTION := preload("res://Icons/Action.png")
const TWO_ACTIVITY := preload("res://Icons/2Activity.png")
const THREE_ACTIVITY := preload("res://Icons/3Activity.png")
const REACTION := preload("res://Icons/Reaction.png")
const FREE_ACTION := preload("res://Icons/FreeAction.png")

# A lot of these are their own variable just for faster referencing
var enemy_data
var enemy_system
var enemy_abilities
var enemy_attributes

@onready var enemy_name := $SheetData/SheetScroller/SheetInfo/Header/EnemyName
@onready var enemy_level := $SheetData/SheetScroller/SheetInfo/Header/EnemyLevel
@onready var trait_container := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Traits
@onready var enemy_source := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Source
@onready var senses = $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Senses
@onready var languages := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Languages
@onready var skills := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Skills
@onready var abilities := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Abilities
@onready var ac_saves := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/ACSaves
@onready var hp_resistances := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/HPResistances
@onready var defensive_abilities := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/DefensiveAbilities
@onready var attacks := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/MeleeRangedAttacks


func _ready():
	setup()

func setup():
	# Gets the enemy sheet data
	var enemy_file = FileAccess.open("res://Data/Enemies/ancient-white-dragon.json", FileAccess.READ)
	var json_conversion = JSON.new()
	json_conversion.parse(enemy_file.get_as_text())
	enemy_data = json_conversion.get_data()
	
	enemy_system = enemy_data["system"]
	enemy_abilities = enemy_data["items"]
	enemy_attributes = enemy_system["attributes"]
	
	# Set up name and level
	enemy_name.text = enemy_data["name"]
	enemy_level.text = "CREATURE " + str(enemy_system["details"]["level"]["value"])
	
	# Set up traits
	setup_traits()
	# Enemy Source
	enemy_source.text = "[b]Source[/b] [i]" + enemy_system["details"]["source"]["value"] + "[/i]"
	
	# Enemy Senses
	setup_senses()
	
	# Enemy Languages
	setup_languages()
	
	# Enemy Skills
	setup_skills()
	
	# Enemy Ability Mods
	setup_ability_mods()
	
	# Enemy Defensive Abilities
	setup_defensive_abilities()
	
	# Enemy Attacks
	setup_attacks()



func setup_traits():
	# Clean up anything already there
	var trait_data = enemy_system["traits"]
	var i: int = 0
	for child in trait_container.get_children():
		if i > 0:
			trait_container.remove_child(child)
		i += 1
	
	# Rarity
	if trait_data["rarity"] != "common":
		insert_trait(trait_data["rarity"].to_upper())
	
	# Alignment
	insert_trait(enemy_system["details"]["alignment"]["value"])
	
	# Size
	insert_trait(trait_data["size"]["value"])
	
	# Remaining traits
	for regular_trait in trait_data["value"]:
		insert_trait(regular_trait.to_upper())

func insert_trait(trait_name: String):
	var new_trait = trait_template.instantiate()
	trait_container.add_child(new_trait)
	new_trait.trait_name = trait_name

func setup_senses():
	senses.text = ""
	var perception = "[b]Perception[/b] " + "+" + "[url]" + str(enemy_system["attributes"]["perception"]["value"]) + "[/url]"
	var enemy_senses = enemy_system["traits"]["senses"]["value"].split(",")
	var i: int = 0
	for sense in enemy_senses:
		if sense[0] == " ":
			enemy_senses[i] = sense.substr(1)
		i += 1
	
	senses.text += perception
	if enemy_senses.size() > 0:
		senses.text += "; "
	
	# Add tooltips to the senses
	i = 0
	for sense in enemy_senses:
		enemy_senses[i] = get_sheet_tooltip("sense", sense) + sense + "[/hint]"
		senses.text += enemy_senses[i]
		if enemy_senses.size() > i + 1:
			senses.text += ", "
		i += 1

func setup_languages():
	if enemy_system["traits"]["languages"]["value"].is_empty():
		languages.visible = false
		return
	languages.visible = true
	languages.text = "[b]Languages[/b] "
	var monster_languages: Array = enemy_system["traits"]["languages"]["value"]
	var i: int = 0
	for language in monster_languages:
		languages.text += "[i]" + language.capitalize() + "[/i]"
		i += 1
		if i < monster_languages.size():
			languages.text += ", "

func setup_skills():
	skills.text = "[b]Skills[/b] "
	var enemy_skills: Array = []
	for ability in enemy_abilities:
		if ability["type"] == "lore":
			enemy_skills.append(ability)
	
	var i: int = 0
	for skill in enemy_skills:
		var skill_text = "[i]" + skill["name"] + "[/i]" + " +" + "[url]" + str(skill["system"]["mod"]["value"]) + "[/url]"
		skills.text += skill_text
		i += 1
		if i < enemy_skills.size():
			skills.text += ", "

func setup_ability_mods():
	abilities.text = ""
	# This code is horrible but I would do this faster than finding a way to make it look better
	var positive_negative := "+"
	if enemy_system["abilities"]["str"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Str[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["str"]["mod"]) + "[/url]" + ", "
	if enemy_system["abilities"]["dex"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Dex[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["dex"]["mod"]) + "[/url]" + ", "
	if enemy_system["abilities"]["con"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Con[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["con"]["mod"]) + "[/url]" + ", "
	if enemy_system["abilities"]["int"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Int[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["int"]["mod"]) + "[/url]" + ", "
	if enemy_system["abilities"]["wis"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Wis[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["wis"]["mod"]) + "[/url]" + ", "
	if enemy_system["abilities"]["cha"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Cha[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["cha"]["mod"]) + "[/url]"

func setup_defensive_abilities():
	# AC and Saving Throws
	setup_ac_saves()
	
	# HP and Resistances
	setup_hp_immunities_weaknesses()
	
	# All other defensive abilities
	setup_other_defensive_abilities()

func setup_ac_saves():
	ac_saves.text = "[b]AC[/b] " + str(enemy_attributes["ac"]["value"]) + "; "
	var positive_negative := "+"
	if enemy_system["saves"]["fortitude"]["value"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	ac_saves.text += "[b]Fort[/b] " + positive_negative + "[url]" + str(enemy_system["saves"]["fortitude"]["value"]) + "[/url], "
	if enemy_system["saves"]["fortitude"]["value"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	ac_saves.text += "[b]Ref[/b] " + positive_negative + "[url]" + str(enemy_system["saves"]["reflex"]["value"]) + "[/url], "
	if enemy_system["saves"]["fortitude"]["value"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	ac_saves.text += "[b]Will[/b] " + positive_negative + "[url]" + str(enemy_system["saves"]["will"]["value"]) + "[/url]"
	
	if enemy_attributes["allSaves"]["value"] != "":
		ac_saves.text += "; " + enemy_attributes["allSaves"]["value"]

func setup_hp_immunities_weaknesses():
	hp_resistances.text = "[b]HP[/b] " + str(enemy_attributes["hp"]["value"])
	
	if enemy_attributes.has("immunities"):
		hp_resistances.text += "; "
		hp_resistances.text += "[b]Immunities[/b] "
		var i: int = 0
		for immunity in enemy_attributes["immunities"]:
			hp_resistances.text += "[i]" + immunity["type"] + "[/i]"
			i += 1
			if i < enemy_attributes["immunities"].size():
				hp_resistances.text += ", "
	
	
	if enemy_attributes.has("resistances"):
		hp_resistances.text += "; "
		hp_resistances.text += "[b]Resistances[/b] "
		var i: int = 0
		for resistance in enemy_attributes["resistances"]:
			hp_resistances.text += resistance["type"] + str(resistance["value"])
			i += 1
			if i < enemy_attributes["resistances"].size():
				hp_resistances.text += ", "
	
	
	if enemy_attributes.has("weaknesses"):
		hp_resistances.text += "; "
		hp_resistances.text += "[b]Weaknesses[/b] "
		var i: int = 0
		for weakness in enemy_attributes["weaknesses"]:
			hp_resistances.text += weakness["type"] + " " + str(weakness["value"])
			i += 1
			if i < enemy_attributes["weaknesses"].size():
				hp_resistances.text += ", "

func setup_other_defensive_abilities():
	var text_interpreter: TextInterpreter = TextInterpreter.new()
	defensive_abilities.visible = false
	for child in defensive_abilities.get_children():
		defensive_abilities.remove_child(child)
	
	for ability in enemy_abilities:
		var valid_ability: bool = false
		if ability["system"].has("category"):
			if ability["system"]["category"] is String:
				if ability["system"]["category"] == "defensive":
					valid_ability = true
		if !ability["system"]["rules"].is_empty():
			if ability["system"]["rules"][0]["key"] == "FlatModifier":
				valid_ability = false
		if !valid_ability:
			continue
		
		# Initialize ability
		var new_ability_entry = SHEET_CONTENT.instantiate()
		new_ability_entry.info_type = SheetContent.InfoTypes.TRAIT
		
		# Add name and reaction icon if applicable
		var ability_name = "[b]" + ability["name"] + "[/b] "
		var ability_icon: String = ""
		if ability["system"]["actionType"]["value"] == "reaction":
			ability_icon = "[img=24]" + REACTION.get_path() + "[/img] "
		
		# Add traits
		var ability_traits: String = "("
		var i: int = 0
		for ability_trait in ability["system"]["traits"]["value"]:
			ability_traits += get_sheet_tooltip("trait", ability_trait) + ability_trait + "[/hint]"
			i += 1
			if i < ability["system"]["traits"]["value"].size():
				ability_traits += ", "
		ability_traits += ") "
		
		# Add description
		var desc_text = text_interpreter.ability_parser(ability["system"]["description"]["value"])
		new_ability_entry.text = ability_name + ability_icon + ability_traits + desc_text
		defensive_abilities.add_child(new_ability_entry)
	if defensive_abilities.get_child_count() > 0:
		defensive_abilities.visible = true

func setup_attacks():
	var text_interpreter: TextInterpreter = TextInterpreter.new()
	attacks.visible = false
	for child in defensive_abilities.get_children():
		attacks.remove_child(child)
	
	for ability in enemy_abilities:
		if ability["type"] == "melee":
			pass

func get_sheet_tooltip(tooltip_type, tooltip_reference) -> String:
	var tooltip_list
	match tooltip_type:
		"sense":
			tooltip_list = Tooltips.senses_tooltips
		"trait":
			tooltip_list = Tooltips.traits_tooltips
	for tooltip in tooltip_list:
		if tooltip in tooltip_reference:
			return "[hint=" + tooltip_list[tooltip] + "]"
	return "[hint=]"
