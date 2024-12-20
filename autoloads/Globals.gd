extends Node

var player : Player
var battle_manager : BattleManager
var player_party : Array[CharacterSheet] = []

var money : int

signal Battle
signal GameWorld


func _ready() -> void:
	battle_manager = load("res://scenes/battle_manager.tscn").instantiate()
	add_child(battle_manager)
	battle_manager.visible = false
	
