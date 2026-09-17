extends Node

var player : Player
var battle_manager : BattleManager
var player_party : Array[CharacterSheet] = []
var player_inv : Array[Item]


var money : int

@warning_ignore("unused_signal")
signal battle
@warning_ignore("unused_signal")
signal game_world


func _ready() -> void:
	battle_manager = load("res://scenes/battle_scene/battle_manager.tscn").instantiate()
	add_child(battle_manager)
	battle_manager.visible = false
	
