@tool
extends VBoxContainer

@onready var label: Label = $Label
@export var filter_option: String = "Filter" : set = set_filter_option

func set_filter_option(val):
	filter_option = val
	if label:
		label.text = filter_option
