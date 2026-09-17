extends Node

var player : Player
var battle_manager : BattleManager
var dialogue_box : DialogueBox
var player_party : Array[CharacterSheet] = []
var player_inv : Array[Item]


var money : int

@warning_ignore("unused_signal")
signal battle
@warning_ignore("unused_signal")
signal game_world
@warning_ignore("unused_signal")
signal dialogue_started
@warning_ignore("unused_signal")
signal dialogue_ended


func _ready() -> void:
	battle_manager = load("res://scenes/battle_scene/battle_manager.tscn").instantiate()
	add_child(battle_manager)
	battle_manager.visible = false
	
	dialogue_box = load("res://scenes/ui/dialogue_box.tscn").instantiate()
	add_child(dialogue_box)
	dialogue_box.visible = false

