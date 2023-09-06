@tool
extends PanelContainer

const NORMAL_THEME = preload("res://Themes/FilteringSorting.tres")
const SELECTED_THEME = preload("res://Themes/FilteringSortingSelected.tres")

@onready var filter_type := $FilterName
@export var filter_name: String = "Numbers" : set = set_filter
@export var filter_window: Node

var theme_type = NORMAL_THEME

func _ready():
	filter_type.text = filter_name

func set_filter(val):
	filter_name = val
	if filter_type:
		filter_type.text = val


func _on_filter_option_button_pressed():
	if theme_type == NORMAL_THEME:
		theme_type = SELECTED_THEME
	else:
		theme_type = NORMAL_THEME
	theme = theme_type
