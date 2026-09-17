extends SkillScene


@export var base_dmg : int
@export var incre_dmg : int
@export var channel_count : int = 3

@export_color_no_alpha var hit_color : Color

var incre_count : int = 0


const LIGHTNING_VFX = preload("res://scenes/vfx/lightning_vfx.tscn")


func start() -> void:
	%Initializer.global_position = initiator.global_position
	await %AnimationPlayer.animation_finished
	
	for i : int in range(0, channel_count):
		%AnimationPlayer.play("channel")
		await %AnimationPlayer.animation_finished
	
	init_animation_play("idle")
	%AnimationPlayer.play("float_up")
	
	await %AnimationPlayer.animation_finished
	
	var points = [Vector2.UP * 100, Vector2.ZERO]
	
	for target : Unit in targets:
		var vfx : LightningVFX  = LIGHTNING_VFX.instantiate()
		battle_manager.environment_add_child(vfx)
		vfx.setup(target.global_position, points)
		vfx.play_one_shot()
		target.hurt(base_dmg + (incre_count * incre_dmg))
		
		#burn effect
		target.character_sprite.modulate = hit_color
		
		get_tree().create_timer(1.8).timeout.connect(
			func() -> void:
				get_tree().create_tween().tween_property(target.character_sprite,"modulate", Color.WHITE, 1.5)
		)
	
	await get_tree().create_timer(1).timeout
	
	#TODO A CHECK
	battle_manager.end_turn.emit()
	
	await get_tree().create_timer(4).timeout
	
	queue_free()
	

func expand_ball() -> void:
	incre_count += 1
	initiator.animation_player.play("cast")
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(%Ball, "scale", Vector2.ONE * (1 + incre_count * 0.2), 0.3)
	tween.finished.connect(func () -> void: initiator.animation_player.play("idle"))
	%Ball.self_modulate = Color.WHITE
	get_tree().create_timer(0.1).timeout.connect(
		func() -> void: %Ball.self_modulate = Color.hex(0xffae00ff)
	)


func fail() -> void:
	initiator.animation_player.play("fail")
