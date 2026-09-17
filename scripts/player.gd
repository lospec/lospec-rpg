class_name Player extends Node2D


@export var party : Array[CharacterSheet]
@onready var character : Character = get_parent()

func _ready() -> void:
	character.state = Character.State.MOVE
	Globals.battle.connect(stop)
	Globals.game_world.connect(start)
	
	#TODO Remove this and to be replaced in start game or load save
	Globals.player_party.clear()
	for char : CharacterSheet in party:
		var new_char : CharacterSheet = char.duplicate(true)
		Globals.player_party.append(new_char)
		new_char.Reset()
	

func _process(_delta):
	
	var player_input = Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	)
	
	character.input = player_input.normalized()
	

func stop():
	character.input = Vector2.ZERO
	character.velocity = Vector2.ZERO
	set_process(false)
	

func start():
	set_process(true)
	
