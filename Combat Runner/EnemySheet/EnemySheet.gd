extends Control

const trait_template := preload("res://Trait.tscn")

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

func _ready():
	setup()

func setup():
	# Gets the enemy sheet data
	var enemy_file = FileAccess.open("res://Data/Enemies/ancient-magma-dragon.json", FileAccess.READ)
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
		for sense_tooltip in Tooltips.senses_tooltips_list:
			if sense_tooltip in sense:
				var tooltip = Tooltips.senses_tooltips[sense_tooltip]
				enemy_senses[i] = "[hint=" + str(tooltip) + "]" + sense + "[/hint]"
				break
		senses.text += enemy_senses[i]
		if enemy_senses.size() > i + 1:
			senses.text += ", "
		i += 1

func setup_languages():
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
	var enemy_skills: Array
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
