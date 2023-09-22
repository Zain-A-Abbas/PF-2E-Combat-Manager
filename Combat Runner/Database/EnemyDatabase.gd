extends Control

const ENEMY_DATABASE = "res://Data/Enemies/"

enum SORT_MODE {
	ALPHABETICAL,
	LEVEL
}

@onready var enemy_list := $Database/DatabaseSheets/EnemyList
@onready var enemy_sheet := $Database/DatabaseSheets/EnemySheet

# Holds enemy data after it has been sorted
var sorted_enemies: Array[EnemyFilterData]
var sorting_mode: SORT_MODE = SORT_MODE.ALPHABETICAL : set = set_sorting
func set_sorting(val):
	if sorting_mode == val:
		return
	sorting_mode = val
	sort_enemies()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_enemies()


# Adds enemies to the enemies array based on filters
func add_enemies():
	sorted_enemies.clear()
	
	# Open the enemy database folder
	var directory := DirAccess.open(ENEMY_DATABASE)
	# Search through every subfolder, as enemies are placed into fodlers corresponding to rulebook source
	
	for subfolder in directory.get_directories():
		var bestiary_folder := DirAccess.open(ENEMY_DATABASE + subfolder)
		for file in bestiary_folder.get_files():
			# Take their file location, use it to create an enemy file and then parse it as text to enemies vairable
			var enemy_file_location := ENEMY_DATABASE + subfolder + "/" + file
			var enemy_file = FileAccess.open(enemy_file_location, FileAccess.READ)
			var json_conversion = JSON.new()
			json_conversion.parse(enemy_file.get_as_text())
			var enemy_data = json_conversion.get_data()
			if enemy_data["type"] != "npc":
				continue
			var enemy_filter_data = EnemyFilterData.new()
			enemy_filter_data.initialize(enemy_data, enemy_file_location)
			sorted_enemies.append(enemy_filter_data)
	sort_enemies()

# Sorts enemies after adding them to the enemies variable
func sort_enemies():
	enemy_list.clear()
	match sorting_mode:
		SORT_MODE.ALPHABETICAL:
			sorted_enemies.sort_custom(sort_alphabetic)
		SORT_MODE.LEVEL:
			sorted_enemies.sort_custom(sort_level)
	for enemy in sorted_enemies:
		enemy_list.add_item(enemy.creature_name)

static func sort_alphabetic(enemy_a: EnemyFilterData, enemy_b: EnemyFilterData):
	return enemy_a.creature_name < enemy_b.creature_name

static func sort_level(enemy_a: EnemyFilterData, enemy_b: EnemyFilterData):
	return enemy_a.level < enemy_b.level

func _on_enemy_list_item_selected(index):
	var enemy_file = FileAccess.open(sorted_enemies[index].database_reference, FileAccess.READ)
	var json_conversion = JSON.new()
	json_conversion.parse(enemy_file.get_as_text())
	var enemy_data = json_conversion.get_data()
	enemy_sheet.setup(enemy_data)


func _on_button_pressed():
	sorting_mode = SORT_MODE.ALPHABETICAL


func _on_button_2_pressed():
	sorting_mode = SORT_MODE.LEVEL
