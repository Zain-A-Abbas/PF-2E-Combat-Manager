@tool
extends FilterButton

const regular_trait = preload("res://Themes/TraitStyleboxes/RegularTrait.tres")
const uncommon_trait = preload("res://Themes/TraitStyleboxes/UncommonTrait.tres")
const rare_trait = preload("res://Themes/TraitStyleboxes/RareTrait.tres")
const size_trait = preload("res://Themes/TraitStyleboxes/SizeTrait.tres")
const alignment_trait = preload("res://Themes/TraitStyleboxes/AlignmentTrait.tres")
const unique_trait = preload("res://Themes/TraitStyleboxes/UniqueTrait.tres")

func set_trait(val):
	trait_name = val
	if trait_text:
		trait_text.text = val
	size.x = 0
	position = Vector2.ZERO
	match val:
		"RARE":
			add_theme_stylebox_override("panel", rare_trait)
		"UNCOMMON":
			add_theme_stylebox_override("panel", uncommon_trait)
		"TINY", "SMALL", "MEDIUM", "LARGE", "HUGE", "GARGANTUAN":
			add_theme_stylebox_override("panel", size_trait)
		"LG", "NG", "CG", "LN", "N", "CN", "LE", "NE", "CE":
			add_theme_stylebox_override("panel", alignment_trait)
		"UNIQUE":
			add_theme_stylebox_override("panel", unique_trait)
		_:
			add_theme_stylebox_override("panel", regular_trait)
