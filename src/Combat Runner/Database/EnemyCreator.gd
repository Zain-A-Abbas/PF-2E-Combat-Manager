extends PanelContainer

signal sheet_created

const EnemySheetExample = preload("res://EnemySheet/EnemySheetExample.gd")
const CUSTOM_ENEMIES_LOCATION: String = "res://Data/Enemies/custom-enemies/"
@onready var name_line = %NameLine
@onready var level_spinbox = %LevelSpinbox

func create_enemy():
	var new_enemy_sheet: Dictionary = {}
	var example = EnemySheetExample.new()
	new_enemy_sheet = example.DEFAULT.duplicate(true)
	example.queue_free()
	
	var details: Dictionary = new_enemy_sheet["system"]["details"]
	
	new_enemy_sheet["name"] = name_line.text
	details["level"]["value"] = int(level_spinbox.value)
	
	var file_name: String = new_enemy_sheet["name"]
	var base_file_name: String = file_name
	var directory := DirAccess.open(CUSTOM_ENEMIES_LOCATION)
	var i: int = 1
	while has_file_name(file_name, directory):
		file_name = base_file_name + "-" + str(i)
		print(file_name)
		i += 1
	
	var new_file = FileAccess.open(CUSTOM_ENEMIES_LOCATION + file_name + ".json", FileAccess.WRITE)
	new_file.store_line(JSON.stringify(new_enemy_sheet, "\t"))
	new_file.close()
	emit_signal("sheet_created")

func has_file_name(file_name: String, folder: DirAccess):
	return folder.get_files().has(file_name + ".json")

func _on_save_sheet_button_pressed():
	create_enemy()
