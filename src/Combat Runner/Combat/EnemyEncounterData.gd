extends Resource
class_name EnemyEncounterData

# This script holds the information of individual enemies in a fight

# When an enemy is added to the combat, this object is created, given the preliminary information, and then that
# information is used to set up an EnemyInfoTemplate

# When saving an encounter file, these objects are created, given whatever information they need, then saved (collectively)
# When loading an encounter file, these objects are just loaded and used to create an EnemyInfoTemplate

var enemy_name: String

var hp: int
var max_hp: int

# Whatever conditions or stat changes the enemy has
var conditions = {}

# The enemy's initiative
var initiative: int = 0

# The enemy JSON data
var enemy_data = null

# Making one when adding an enemy to an encounter
func initialize(enemy_sheet_data):
# Makes it a blank enemy if no directory is given
	if enemy_sheet_data == null:
		enemy_name = "Blank"
		max_hp = 100
		hp = 100
		return
	
	enemy_data = enemy_sheet_data
	# Access the name and hp values from the sheet
	enemy_name = enemy_data["name"]
	max_hp = enemy_data["system"]["attributes"]["hp"]["max"]
	hp = max_hp

# Just creates one and returns itself
func initialize_from_save_data(save_enemy) -> EnemyEncounterData:
	enemy_name = save_enemy["enemy_name"]
	hp = save_enemy["hp"]
	max_hp = save_enemy["max_hp"]
	enemy_data = save_enemy["enemy_data"]
	conditions = save_enemy["conditions"]
	return self



func _get_property_list():
	var property_usage = PROPERTY_USAGE_STORAGE

	var properties = []
	properties.append({
		"name": "enemy_name",
		"type": TYPE_STRING,
		"usage": property_usage, # See above assignment.
	})
	
	properties.append({
		"name": "hp",
		"type": TYPE_INT,
		"usage": property_usage, # See above assignment.
	})
	
	properties.append({
		"name": "max_hp",
		"type": TYPE_INT,
		"usage": property_usage, # See above assignment.
	})
	
	properties.append({
		"name": "conditions",
		"type": TYPE_DICTIONARY,
		"usage": property_usage, # See above assignment.
	})
	
	properties.append({
		"name": "initiative",
		"type": TYPE_INT,
		"usage": property_usage, # See above assignment.
	})
	
	properties.append({
		"name": "enemy_data",
		"type": TYPE_DICTIONARY,
		"usage": property_usage, # See above assignment.
	})
	
	return properties
