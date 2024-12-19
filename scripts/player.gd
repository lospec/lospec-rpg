extends Node2D

@onready var character : Character = get_parent()

func _ready() -> void:
	character.state = Character.State.MOVE

func _process(_delta):
	#print(character)
	var player_input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	character.input = player_input.normalized()
	
	
