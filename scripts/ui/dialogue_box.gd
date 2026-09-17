class_name DialogueBox extends CanvasLayer

## Overworld textbox. Instanced by Globals; NPCs call display_text() and await it.

var is_open : bool = false


func display_text(texts : Array[String]) -> void:
	is_open = true
	Globals.dialogue_started.emit()
	show()
	
	await %TextBox.display_text(texts)
	
	hide()
	Globals.dialogue_ended.emit()
	is_open = false
