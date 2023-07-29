extends PanelContainer

@onready var name_bar:= $HBoxContainer/Control/MarginContainer/HPBarControl/EnemyName
@onready var hp_bar := $HBoxContainer/Control/MarginContainer/HPBarControl/HPBar
@onready var current_hp := $HBoxContainer/Control/MarginContainer2/PanelContainer/MarginContainer/HBoxContainer/CurrentHP
@onready var max_hp := $HBoxContainer/Control/MarginContainer2/PanelContainer/MarginContainer/HBoxContainer/MaxHP
@onready var damage := $HBoxContainer/Control/MarginContainer2/PanelContainer/MarginContainer/HBoxContainer/Damage

var regex := RegEx.new()
var hp: int = 0 : set = set_hp

func set_hp(val: int):
	hp = max(0, val)
	current_hp.text = str(hp)
	hp_bar.value = max(0, float(hp) / float(max_hp.text) * 100)

# The enemy JSON data
var enemy_data
# The enemy's name
var enemy_name: String

func _ready():
	regex.compile("^[0-9]*$")

func setup_enemy(enemy_directory: String):
	# Makes it a blank enemy if no directory is given
	if enemy_directory == null:
		enemy_name = ""
		max_hp.text = 1
		hp = 1
		return
	
	# Gets the enemy sheet data and name
	var enemy_file = FileAccess.open(enemy_directory, FileAccess.READ)
	var json_conversion = JSON.new()
	json_conversion.parse(enemy_file.get_as_text())
	enemy_data = json_conversion.get_data()
	enemy_name = enemy_data["name"]
	name_bar.text = enemy_name

func _on_current_hp_text_changed(new_text):
	hp = int(new_text)

func _on_damage_button_pressed():
	if int(current_hp.text):
		if int(damage.text):
			hp -= int(damage.text)
			damage.text = ""
