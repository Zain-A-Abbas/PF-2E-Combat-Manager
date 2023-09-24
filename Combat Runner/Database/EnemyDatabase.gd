extends Control

const ENEMY_DATABASE = "res://Data/Enemies/"

enum SORT_MODE {
	ALPHABETICAL,
	LEVEL
}

@onready var enemy_list := $Database/DatabaseSheets/EnemyList
@onready var enemy_sheet := $Database/DatabaseSheets/EnemySheet

# The filter menus; the filtering data is retrieved directly from them
@onready var size_filter_menu := $CenterContainer/SizeFilterMenu


# Holds all enemy data
var enemies: Array[EnemyFilterData]
# Holds enemies that have been filtered and sorted
var filtered_sorted_enemies: Array[EnemyFilterData] = enemies
var sorting_mode: SORT_MODE = SORT_MODE.ALPHABETICAL : set = set_sorting
func set_sorting(val):
	if sorting_mode == val:
		return
	sorting_mode = val
	sort_filter_enemies()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_enemies()


# Adds enemies to the enemies array
func add_enemies():
	enemies.clear()
	
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
			enemies.append(enemy_filter_data)
	sort_filter_enemies()

# Filters enemies, sorts them, then makes them visible
func sort_filter_enemies():
	enemy_list.clear()
	
	filtered_sorted_enemies = enemies
	
	filtered_sorted_enemies = size_filter(filtered_sorted_enemies)
	
	match sorting_mode:
		SORT_MODE.ALPHABETICAL:
			filtered_sorted_enemies.sort_custom(sort_alphabetic)
		SORT_MODE.LEVEL:
			filtered_sorted_enemies.sort_custom(sort_level)
	for enemy in filtered_sorted_enemies:
		enemy_list.add_item(enemy.creature_name)

static func sort_alphabetic(enemy_a: EnemyFilterData, enemy_b: EnemyFilterData):
	return enemy_a.creature_name < enemy_b.creature_name

static func sort_level(enemy_a: EnemyFilterData, enemy_b: EnemyFilterData):
	return enemy_a.level < enemy_b.level


# Filters

func filter_enemies(enemies_to_filter: Array[EnemyFilterData]) -> Array[EnemyFilterData]:
	var filtering := enemies_to_filter
	filtering = size_filter(filtering)
	return filtering

func size_filter( enemies_to_filter: Array[EnemyFilterData] ) -> Array[EnemyFilterData]:
	
	
	# Enemies to include and enemies to remove, as well as "unexcluded" enemies
	var include_enemies: Array[EnemyFilterData] = []
	var remove_enemies: Array[EnemyFilterData] = []
	
	# Goes through every enemy, stacks them up to the filter
	for enemy in enemies_to_filter:
		for filter_button in size_filter_menu.filter_container:
			if enemy.size.to_lower() == filter_button.trait_name.to_lower():
				if filter_button.filter_state == FilterButton.FilterState.INCLUDE:
					include_enemies.append(enemy)
				elif filter_button.filter_state == FilterButton.FilterState.EXCLUDE:
					remove_enemies.append(enemy)
	
	if !include_enemies.is_empty():
		var final_enemies: Array[EnemyFilterData] = []
		for enemy in include_enemies:
			if !remove_enemies.has(enemy):
				final_enemies.append(enemy)
		return final_enemies
	
	if !remove_enemies.is_empty():
		var final_enemies: Array[EnemyFilterData] = []
		for enemy in enemies_to_filter:
			if !remove_enemies.has(enemy):
				final_enemies.append(enemy)
		return final_enemies
	
	return enemies_to_filter

# Signals

func _on_enemy_list_item_selected(index):
	var enemy_file = FileAccess.open(filtered_sorted_enemies[index].database_reference, FileAccess.READ)
	var json_conversion = JSON.new()
	json_conversion.parse(enemy_file.get_as_text())
	var enemy_data = json_conversion.get_data()
	enemy_sheet.setup(enemy_data)


func _on_button_pressed():
	sorting_mode = SORT_MODE.ALPHABETICAL

func _on_button_2_pressed():
	sorting_mode = SORT_MODE.LEVEL



## Filter buttons

func _on_size_filter_button_button_pressed():
	if !size_filter_menu.visible:
		size_filter_menu.visible = true
	else:
		size_filter_menu.visible = false

func _on_size_filter_menu_apply_filter():
	size_filter_menu.visible = false
	$Database/MarginContainer/SortingFiltering/SizeFilterButton.button_pushed()
	sort_filter_enemies()
