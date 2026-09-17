class_name Unit extends Node2D

enum Group {ALLY, ENEMY}

@export var char_sheet : CharacterSheet

@export_color_no_alpha var heal_color : Color


var action_priorities : Array[ActionPriority]
var battle_manager : BattleManager
var is_selectable : bool = false
var select_index : int
var group : Group
var group_index : int

var cld_counter : Dictionary = {}

@onready var selection_area: Area2D = %SelectionArea
@onready var selection_collision : CollisionShape2D = %SelectionCollision
@onready var shader : ShaderMaterial = %CharacterSprite.material
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var character_sprite: Sprite2D = %CharacterSprite

@warning_ignore("shadowed_variable")
func setup(char_sheet : CharacterSheet, group : Unit.Group, group_index : int, battle_manager : BattleManager) -> void:
	self.char_sheet = char_sheet
	self.battle_manager = battle_manager
	self.group = group
	self.group_index = group_index
	
	name = char_sheet.name
	cld_counter.clear()
	for skill : SkillResource in char_sheet.skills.keys():
		cld_counter[skill] = 0
	
	%CharacterSprite.texture = char_sheet.sprite_sheet
	%SelectUI.hide()
	
	set_hp_bar(char_sheet.cur_hp, char_sheet.max_hp)
	char_sheet.hp_changed.connect(set_hp_bar)
	char_sheet.death.connect(death)
	shader.set_shader_parameter("enable", false)


func _ready() -> void:
	%Tombstone.hide()


func perform_ai_action(battle_scene : BattleManager) -> void:
	#TODO Change this to its ai
	battle_scene.basic_atk(char_sheet, battle_scene.ally_units.pick_random())


func set_hp_bar(value : int, max_val : int) -> void:
	%HPBar.value = value
	%HPBar.max_value = max_val
	%HPLabel.text = "%d/%d" % [value, max_val]


func death(_charSheet : CharacterSheet):
	%CharacterSprite.hide()
	%UI.hide()
	%Tombstone.show()


func revive(heal : int = 1):
	heal(max(heal,1))
	

func hurt(dmg : int, ignore_def : bool = false, animation : String = "hurt") -> int:
	var dmg_dealt : int = dmg if ignore_def else maxi(1, dmg - char_sheet.def)
	char_sheet.cur_hp -= dmg_dealt
	battle_manager.create_num_popup(dmg_dealt, %NumberPopupPoint.global_position)
	animation_player.play(animation)
	return dmg_dealt


func heal(value : int) -> int:
	char_sheet.cur_hp += value
	battle_manager.create_num_popup(value, %NumberPopupPoint.global_position, heal_color)
	return value


func set_select_index(index : int) -> void:
	select_index = index
	is_selectable = true


func show_select_ui(index : int) -> void:
	if is_selectable:
		if index == select_index:
			%SelectUI.play()
			shader.set_shader_parameter("enable", true)
		else:
			%SelectUI.transparent()
			shader.set_shader_parameter("enable", false)
	else:
		%SelectUI.stop()
		shader.set_shader_parameter("enable", false)


#TODO Maybe add a tooltip that shows character sheet's stats
func _on_selection_area_mouse_entered() -> void:
	if is_selectable:
		battle_manager.selection_index_changed.emit(select_index)
	else:
		shader.set_shader_parameter("enable", true)


func _on_selection_area_mouse_exited() -> void:
	if is_selectable:
		pass
	else:
		shader.set_shader_parameter("enable", false)


func select_cancel() -> void:
	%SelectUI.stop()
	shader.set_shader_parameter("enable", false)
	is_selectable = false
	select_index = -1


func _on_selection_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_selectable:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			battle_manager.selected_index = select_index
			battle_manager.end_selection.emit()
