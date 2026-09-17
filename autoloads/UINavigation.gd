extends Node

signal on_cancel


func _ready() -> void:
	add_ui_inputs("Down", "ui_down")
	add_ui_inputs("Up", "ui_up")
	add_ui_inputs("Left", "ui_left")
	add_ui_inputs("Right", "ui_right")
	add_ui_inputs("Confirm", "ui_accept")
	add_ui_inputs("Cancel", "ui_cancel")


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Cancel"):
		on_cancel.emit()


func add_ui_inputs(action : StringName, ui : StringName) -> void:
	for input : InputEvent in InputMap.action_get_events(action):
		InputMap.action_add_event(ui, input)


func connect_cancel(callable : Callable) -> void:
	clear_cancel()
	on_cancel.connect(callable)


func clear_cancel() -> void:
	for c in on_cancel.get_connections():
		on_cancel.disconnect(c.callable)
