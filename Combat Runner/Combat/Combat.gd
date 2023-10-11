extends Control

const ENEMY_INFO_TEMPLATE = preload("res://Combat/EnemyInfoTemplate.tscn")
const ENEMY_INITIATIVE = preload("res://Combat/EnemyInitiative.tscn")
@onready var enemies
@onready var enemy_sheet = $HBoxContainer/TrackerSheetSplit/SheetandDatabase/VSplitContainer/EnemySheet
@onready var initiative_container = $HBoxContainer/Panel/InitiativeRolling/Initiative/InitiativeMargins/VBoxContainer/ScrollContainer/InitiativeContainer

func _ready():
	enemies = $"HBoxContainer/TrackerSheetSplit/EncounterTracker/Encounter A/EnemyTrackerPanel/ScrollContainer/Enemies"

# Adding an enemy from a pre-existing sheet
func add_enemy_from_sheet(enemy_data):
	var new_sheet_enemy = ENEMY_INFO_TEMPLATE.instantiate()
	enemies.add_child(new_sheet_enemy)
	
	var enemy_combat_data = EnemyEncounterData.new()
	enemy_combat_data.initialize(enemy_data)
	
	new_sheet_enemy.setup_enemy(enemy_combat_data)
	new_sheet_enemy.viewing_enemy.connect(view_enemy_sheet)
	add_enemy_to_initiative(new_sheet_enemy)

# Adding a blank enemy
func _on_blank_enemy_button_pressed():
	var new_blank_enemy = ENEMY_INFO_TEMPLATE.instantiate()
	enemies.add_child(new_blank_enemy)
	
	var enemy_combat_data = EnemyEncounterData.new()
	enemy_combat_data.initialize(null)
	
	new_blank_enemy.setup_enemy(enemy_combat_data)
	add_enemy_to_initiative(new_blank_enemy)

# Creates a new initiative count, adds it to the initiative container, then sets it to an enemy sheet and node
func add_enemy_to_initiative(enemy):
	# Goes through every enemy, and makes sure their names are unique before adding to initiative
	check_names()
	
	# Creates an initiative object
	var new_initiative_count = ENEMY_INITIATIVE.instantiate()
	# Adds it to the initiative list, sets it up
	initiative_container.add_child(new_initiative_count)
	new_initiative_count.setup_initiative(enemy)
	new_initiative_count.enemy_node = enemy
	
	# Checks any
	
	
	enemy.deleted_enemy.connect(remove_enemy)
	enemy.renamed_enemy.connect(update_initiative_name)
	
	sort_initiative()

# Sorts Initiative
func sort_initiative():
	var initiatives = initiative_container.get_children()
	initiatives.sort_custom(sort_initiative_nodes)
	var i: int = 0
	for initiative_node in initiatives:
		initiative_container.move_child(initiative_node, i)
		i += 1

static func sort_initiative_nodes(a, b):
	return a.initiative > b.initiative

func update_initiative_name(enemy, new_name: String):
	for child in initiative_container.get_children():
		if child.enemy_node == enemy:
			child.rename_enemy(new_name)

# Ensures that every name in the combat is unique when creating an enemy instance
func check_names():
	var new_enemy = enemies.get_child(-1)
	for preexisting_enemy in enemies.get_children():
		if preexisting_enemy != new_enemy && new_enemy.enemy_name == preexisting_enemy.enemy_name:
			new_enemy.name_bar.text += "+"
			new_enemy.enemy_name += "+"

# Runs when you highlight an enemy to view its sheet
func view_enemy_sheet(enemy_data):
	enemy_sheet.setup(enemy_data)

# When an enemy is removed
func remove_enemy(enemy: Node):
	for child in initiative_container.get_children():
		if child.enemy_node == enemy:
			child.queue_free()
	enemy.queue_free()


func _on_reroll_initiative_button_pressed():
	if initiative_container.get_child_count() == 0:
		return
	for child in initiative_container.get_children():
		child.reroll_initiative()
	sort_initiative()


func _on_copy_initiative_button_pressed():
	if initiative_container.get_child_count() == 0:
		return
	
	var initiative_copy_text: String = ""
	for child in initiative_container.get_children():
		initiative_copy_text += child.enemy_name.text + " - " + str(child.initiative) + "\n"
	DisplayServer.clipboard_set(initiative_copy_text)


func _on_encounter_tracker_tab_changed(tab):
	print("tab changed to " + str(tab))
