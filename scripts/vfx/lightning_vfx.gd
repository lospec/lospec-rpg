class_name LightningVFX extends Node2D


@warning_ignore("shadowed_variable_base_class")
func setup(position : Vector2, points : PackedVector2Array) -> void:
	self.global_position = position
	%Lightning.points = points


func play_loop() -> void:
	%AnimationPlayer.play("start")
	emit_particle(false)


func play_one_shot() -> void:
	%AnimationPlayer.play("start")
	emit_particle(true)
	print("hello?")
	await %AnimationPlayer.animation_finished
	%AnimationPlayer.play("end")
	await %AnimationPlayer.animation_finished
	queue_free()


func emit_particle(one_shot : bool) -> void:
	%Spark.one_shot = one_shot
	%Spark.restart()
	%Flare.one_shot = one_shot
	%Flare.restart()


func stop() -> void:
	%AnimationPlayer.play("end")
