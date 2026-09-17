class_name SkillScene extends Node2D

signal input_success
signal input_fail

var initiator : Unit
var targets : Array[Unit]
var battle_manager : BattleManager

var is_successful : bool
var success_pending : bool
var is_crit : bool

var is_auto : bool
var auto_success_min : float
var auto_success_max : float



@warning_ignore("shadowed_variable")
func setup(battle_manager : BattleManager, initiator : Unit, targets : Array[Unit], is_auto) -> void:
	self.battle_manager = battle_manager
	self.initiator = initiator
	self.targets = targets
	%AnimationPlayer.call_deferred("play", "start")
	start()


func _ready() -> void:
	set_process(false)
	randomize()
	print(name, " is being cast")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Confirm"):
		is_successful = success_pending
		if is_successful:
			input_success.emit()
		else:
			input_fail.emit()
		set_process(false)


func start() -> void:
	pass


func start_input() -> void:
	if !is_auto:
		set_process(true)
		is_successful = false
		success_pending = false


func end_input() -> void:
	if !is_auto:
		set_process(false)
		if !is_successful:
			input_fail.emit()


func success_check() -> void:
	if is_auto:
		pass
	else:
		success_pending = true


func clear_signals() -> void:
	
	pass


func set_enable_crit(value : bool) -> void:
	is_crit = value


func hurt(target : int, value : int) -> void:
	pass


func heal(target , value : int) -> void:
	pass


func apply_status_effect() -> void:
	
	pass


func init_animation_play(animation_name : String) -> void:
	initiator.animation_player.play(animation_name)


func target_animation_play(index : int, animation_name : String) -> void:
	targets[index].animation_player.play(animation_name)
