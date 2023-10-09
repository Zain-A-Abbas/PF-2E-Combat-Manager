extends PanelContainer

@onready var name_bar:= $HBoxContainer/Control/MarginContainer/HPBarControl/EnemyName
@onready var hp_bar := $HBoxContainer/Control/MarginContainer/HPBarControl/HPBar
@onready var current_hp := $HBoxContainer/Control/MarginContainer2/PanelContainer/MarginContainer/HBoxContainer/CurrentHP
@onready var max_hp_box := $HBoxContainer/Control/MarginContainer2/PanelContainer/MarginContainer/HBoxContainer/MaxHP
@onready var damage := $HBoxContainer/Control/MarginContainer2/PanelContainer/MarginContainer/HBoxContainer/Damage

# For displaying the sheet on the combat page
signal viewing_enemy(enemy_data)
signal deleted_enemy(enemy)
signal renamed_enemy(enemy, new_name)

var regex := RegEx.new()
var hp: int = 0 : set = set_hp
var max_hp: int = 0

func set_hp(val: int):
	hp = max(0, val)
	current_hp.text = str(hp)
	max_hp_box.text = str(max_hp)
	hp_bar.value = max(0, float(hp) / float(max_hp) * 100)

# The enemy JSON data
var enemy_data = null
# The enemy's name
var enemy_name: String

func _ready():
	regex.compile("^[0 -9]*$")

func setup_enemy(enemy_sheet_data):
	# Makes it a blank enemy if no directory is given
	if enemy_sheet_data == null:
		enemy_name = ""
		max_hp = 100
		hp = 100
		return
	
	enemy_data = enemy_sheet_data
	# Access the name and hp values from the sheet
	enemy_name = enemy_data["name"]
	max_hp = enemy_data["system"]["attributes"]["hp"]["max"]
	hp = max_hp
	name_bar.text = enemy_name

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			enemy_focus()

# Tells the program to show the current sheet on the right-hand side
func enemy_focus():
	# Don't do anything if blank sheet
	if enemy_data == null:
		return
	
	emit_signal("viewing_enemy", enemy_data)

func _on_current_hp_text_submitted(new_text):
	hp = int(new_text)

func _on_current_hp_focus_exited():
	hp = int(current_hp.text)

func _on_max_hp_text_submitted(new_text):
	max_hp = int(new_text)
	set_hp(hp)

func _on_max_hp_focus_exited():
	max_hp = int(max_hp_box.text)
	set_hp(hp)


func _on_damage_button_pressed():
	enemy_focus()
	if int(current_hp.text):
		if int(damage.text):
			hp -= int(damage.text)
			damage.text = ""


func _on_delete_button_pressed():
	emit_signal("deleted_enemy", self)


func _on_enemy_name_focus_entered():
	enemy_focus()


func _on_damage_focus_entered():
	enemy_focus()


func _on_max_hp_focus_entered():
	enemy_focus()


func _on_current_hp_focus_entered():
	enemy_focus()



func _on_enemy_name_text_changed(new_text):
	emit_signal("renamed_enemy", self, new_text)
