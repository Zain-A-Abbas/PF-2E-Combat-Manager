extends FileDialog


func choose_load_directory():
	visible = true


func _on_confirmed():
	visible = false
	EventBus.emit_signal("encounter_load_directory_chosen")
