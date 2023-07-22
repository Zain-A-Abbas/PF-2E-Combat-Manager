@tool
extends PanelContainer

@onready var trait_text := $MarginContainer/TraitText
@export var trait_name: String = "UNCOMMON" : set = set_trait

const regular_trait = preload("res://Themes/TraitStyleboxes/RegularTrait.tres")
const uncommon_trait = preload("res://Themes/TraitStyleboxes/UncommonTrait.tres")
const rare_trait = preload("res://Themes/TraitStyleboxes/RareTrait.tres")
const size_trait = preload("res://Themes/TraitStyleboxes/SizeTrait.tres")
const alignment_trait = preload("res://Themes/TraitStyleboxes/AlignmentTrait.tres")

func set_trait(val):
	if !trait_text:
		return
	
	# Interprets the name if it's something else
	var real_val: String = trait_interpreter(val)
	
	trait_name = real_val
	trait_text.text = real_val
	
	match real_val:
		"RARE":
			add_theme_stylebox_override("panel", rare_trait)
		"UNCOMMON":
			add_theme_stylebox_override("panel", uncommon_trait)
		"TINY", "SMALL", "MEDIUM", "LARGE", "HUGE", "GARGANTUAN":
			add_theme_stylebox_override("panel", size_trait)
		"LG", "NG", "CG", "LN", "N", "CN", "LE", "N", "CE":
			add_theme_stylebox_override("panel", alignment_trait)
		_:
			add_theme_stylebox_override("panel", regular_trait)


func trait_interpreter(val) -> String:
	match val:
		"tiny":
			return "TINY"
		"sm":
			return "SMALL"
		"med":
			return "MEDIUM"
		"lg":
			return "LARGE"
		"huge":
			return "HUGE"
		"grg":
			return "GARGANTUAN"
		_:
			return val
	
