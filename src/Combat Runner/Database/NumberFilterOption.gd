@tool
extends VBoxContainer

@onready var spin_box = $SpinboxContainer/SpinBox
@onready var spin_box_2 = $SpinboxContainer/SpinBox2

@onready var label: Label = $HBoxContainer/Label
@export var filter_option: String = "Filter" : set = set_filter_option
@onready var menu_button : MenuButton = $HBoxContainer/MenuButton

@export var has_dropdown : bool = false

const ABILITY_SCORES : Array[String] = ["Strength", "Dexterity", "Constitution", "Charisma", "Wisdom", "Intelligence"]
const SPEEDS : Array[String]= ["Land", "Fly", "Swim", "Climb", "Burrow"]
const ELEMENTS : Array[String] = ["Acid", "All", "Bleed", "Bludgeoning", "Chaotic", "Cold", "Cold Iron", "Electricity", "Evil", "Fire", "Force", "Good", "Lawful", "Mental", "Negative", "Orichalum", "Physical", "Piercing", "Poison", "Positive", "Precision", "Silver", "Slashing", "Sonic", "Splash"]

enum ListFiltering {ABILITY_SCORES, SPEEDS, ELEMENTS}
@export var list_filtering : ListFiltering = ListFiltering.ABILITY_SCORES

func _ready():
	var popup : PopupMenu = menu_button.get_popup()
	popup.index_pressed.connect(change_dropdown_text)
	label.text = filter_option
	menu_button.visible = has_dropdown
	match list_filtering: 
		ListFiltering.ABILITY_SCORES: 
			create_pop_ups(ABILITY_SCORES)
		ListFiltering.SPEEDS: 
			create_pop_ups(SPEEDS)
		ListFiltering.ELEMENTS: 
			create_pop_ups(ELEMENTS)

func create_pop_ups(options : Array[String]):
	menu_button.get_popup().clear()
	for option in options:
		menu_button.get_popup().add_item(option)
	menu_button.text = menu_button.get_popup().get_item_text(0)

func return_filter() -> NumberFilterData:
	var return_value : NumberFilterData = NumberFilterData.new("", spin_box.value, spin_box_2.value)
	if has_dropdown:
		var popup = menu_button.get_popup()
		print(popup.get_item_text(popup.get_focused_item()))
		return_value.text = popup.get_item_text(popup.get_focused_item())
	else:
		print(filter_option)
		return_value.text = filter_option
	return return_value

func change_dropdown_text(x : int):
	print("Clicked is " + menu_button.get_popup().get_item_text(x))
	menu_button.text = menu_button.get_popup().get_item_text(x)

func set_filter_option(val):
	filter_option = val
	if label:
		label.text = filter_option
		
