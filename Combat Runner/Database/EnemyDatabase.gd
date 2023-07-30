extends Control

const ENEMY_DATABASE = "res://Data/Enemies/"

enum SORT_MODE {
	ALPHABETICAL,
	LEVEL
}

@onready var enemy_list := $Database/DatabaseSheets/EnemyList
@onready var enemy_sheet := $Database/DatabaseSheets/EnemySheet
var database_references: Array[String] = []

# Holds enemy data after it has been sorted
var sorted_enemies: Array
var sorting_mode: SORT_MODE = SORT_MODE.ALPHABETICAL : set = set_sorting
func set_sorting(val):
	if sorting_mode == val:
		return
	sorting_mode = val
	add_enemies()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_enemies()


# Adds enemies to the enemies array based on filters
func add_enemies():
	var enemies: Array
	database_references.clear()
	var directory := DirAccess.open(ENEMY_DATABASE)
	for subfolder in directory.get_directories():
		var bestiary_folder := DirAccess.open(ENEMY_DATABASE + subfolder)
		for file in bestiary_folder.get_files():
			var enemy_file_location := ENEMY_DATABASE + subfolder + "/" + file
			var enemy_file = FileAccess.open(enemy_file_location, FileAccess.READ)
			var json_conversion = JSON.new()
			json_conversion.parse(enemy_file.get_as_text())
			var enemy_data = json_conversion.get_data()
			if enemy_data["type"] == "hazard":
				continue
			enemies.append(enemy_data)
			database_references.append(enemy_file_location)
	sort_enemies(enemies)

# Sorts enemies after adding the
func sort_enemies(enemies: Array):
	enemy_list.clear()
	sorted_enemies.clear()
	sorted_enemies = enemies
	match sorting_mode:
		SORT_MODE.ALPHABETICAL:
			sorted_enemies.sort_custom(sort_alphabetic)
		SORT_MODE.LEVEL:
			sorted_enemies.sort_custom(sort_level)
	for enemy in sorted_enemies:
		enemy_list.add_item(enemy["name"])

static func sort_alphabetic(enemy_a, enemy_b):
	return enemy_a["name"] < enemy_b["name"]

static func sort_level(enemy_a, enemy_b):
	return enemy_a["system"]["details"]["level"]["value"] < enemy_b["system"]["details"]["level"]["value"]

func _on_enemy_list_item_selected(index):
	enemy_sheet.setup(sorted_enemies[index])


func _on_button_pressed():
	sorting_mode = SORT_MODE.ALPHABETICAL


func _on_button_2_pressed():
	sorting_mode = SORT_MODE.LEVEL
