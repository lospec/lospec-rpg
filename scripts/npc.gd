class_name NPC extends Node2D

## Attach as a child of a Character (same as Player). Walk up to it and press Confirm to talk.

@export_multiline var dialogue : Array[String]

@onready var character : Character = get_parent()

var player_in_range : Character
var is_talking : bool = false


func _unhandled_input(event : InputEvent) -> void:
	if is_talking || player_in_range == null || Globals.dialogue_box.is_open: return
	
	if event.is_action_pressed("Confirm"):
		get_viewport().set_input_as_handled()
		talk()


func talk() -> void:
	if dialogue.is_empty(): return
	
	is_talking = true
	face(player_in_range)
	await Globals.dialogue_box.display_text(dialogue)
	is_talking = false


func face(target : Node2D) -> void:
	character.sprite.flip_h = target.global_position.x < character.global_position.x


func _on_interact_area_body_entered(body : Node2D) -> void:
	if body is Character && body != character:
		player_in_range = body


func _on_interact_area_body_exited(body : Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
