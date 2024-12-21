extends Area2D

@export var enemies : Array[CharacterAP]

func _on_body_entered(_body: Node2D) -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	Globals.battle_manager.Fight(enemies)
