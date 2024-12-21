class_name Player extends Node2D


@export var char_sheet : CharacterSheet
@onready var character : Character = get_parent()

func _ready() -> void:
	character.state = Character.State.MOVE
	Globals.Battle.connect(Stop)
	Globals.GameWorld.connect(Start)
	Globals.player_party.append(char_sheet)
	char_sheet.curHp = char_sheet.maxHp

func _process(_delta):
	
	var player_input = Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	)
	
	character.input = player_input.normalized()
	

func Stop():
	character.input = Vector2.ZERO
	character.velocity = Vector2.ZERO
	set_process(false)
	

func Start():
	set_process(true)
	
