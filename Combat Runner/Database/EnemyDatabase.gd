extends Control

const ENEMY_DATABASE = "res://Data/Enemies/"

@onready var enemy_list := $Database/DatabaseSheets/EnemyList
@onready var enemy_sheet := $Database/DatabaseSheets/EnemySheet
var database_references: Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	add_enemies()


# Adds enemies to the enemy list
func add_enemies():
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
			enemy_list.add_item(enemy_data["name"])
			database_references.append(enemy_file_location)




func _on_enemy_list_item_selected(index):
	enemy_sheet.setup(database_references[index])
