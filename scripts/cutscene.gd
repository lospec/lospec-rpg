extends Node2D


func _on_cutscene_trigger_body_entered(_body: Node2D) -> void:
	$CutsceneTrigger.set_deferred("monitoring", false)
	$CutsceneTrigger/CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("cutscene_name")


func set_enable_player_camera(value : bool) -> void:
	# = value
	pass
