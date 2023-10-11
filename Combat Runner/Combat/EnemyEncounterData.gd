extends Node
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
func initialize_from_info_template(info_template: EnemyInfoTemplate) -> EnemyEncounterData:
	enemy_name = info_template.enemy_name
	hp = info_template.hp
	max_hp = info_template.max_hp
	enemy_data = info_template.enemy_data
	conditions = info_template.conditions
	return self
