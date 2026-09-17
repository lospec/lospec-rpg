class_name SkillResource extends Resource

@export var name : String
@export var atk_type : BattleNamespace.AttackType
@export_range(0, 0, 1, "or_greater") var mana_cost : int
@export_range(0, 0, 1, "or_greater") var cooldown : int

@export var target_group : BattleNamespace.TargetGroup
@export var target_type : BattleNamespace.TargetType
@export var targetable_self : bool = true

@export var packed_scene : PackedScene

@export_multiline var description : String


func initialize(battle_manager : BattleManager, initiator : Unit, targets : Array[Unit], is_auto : bool) -> void:
	if targets.is_empty() || targets[0] == null:
		return
	battle_manager.hide_actions()
	
	var skill : SkillScene = packed_scene.instantiate()
	battle_manager.environment_add_child(skill)
	
	initiator.char_sheet.cur_mana -= mana_cost
	initiator.cld_counter[self] = cooldown
	
	skill.setup(battle_manager, initiator, targets, is_auto)
	
