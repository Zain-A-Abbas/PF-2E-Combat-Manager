extends PanelContainer

@export var filter_type: String
var filter_container: Array[Node]

signal apply_filter

func _ready():
	filter_container = find_children("", "FilterButton", true, true)


func _on_apply_button_pressed():
	emit_signal("apply_filter")
