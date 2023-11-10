extends FileDialog


func choose_save_directory():
	visible = true


func _on_confirmed():
	visible = false
	EventBus.emit_signal("encounter_save_directory_chosen")
