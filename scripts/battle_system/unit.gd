class_name Unit extends Node2D

@export var char_sheet : CharacterSheet

var action_priorities : Array[ActionPriority]
var battle_manager : BattleManager
var is_selectiable : bool = false
var select_index : int

@onready var selection_area: Area2D = %SelectionArea
@onready var selection_collision : CollisionShape2D = %SelectionCollision
@onready var shader : ShaderMaterial = %CharacterSprite.material
var character_sprite: Sprite2D


func _ready() -> void:
	%Tombstone.hide()
	character_sprite = %CharacterSprite

func Setup(char_sheet : CharacterSheet, battle_manager : BattleManager) -> void:
	self.char_sheet = char_sheet
	self.battle_manager = battle_manager
	%CharacterSprite.texture = char_sheet.sprite_sheet
	%SelectUI.hide()
	
	SetHpBar(char_sheet.cur_hp, char_sheet.max_hp)
	char_sheet.hp_changed.connect(SetHpBar)
	char_sheet.death.connect(death)
	shader.set_shader_parameter("enable", false)


func SetHpBar(value : int, max : int) -> void:
	%HPBar.value = value
	%HPBar.max_value = max
	%HPLabel.text = "%d/%d" % [value, max]

func death(_charSheet : CharacterSheet):
	%CharacterSprite.hide()
	%Tombstone.show()

func perform_ai_action(battle_scene : BattleManager) -> void:
	#TODO Change this to its ai
	battle_scene.basic_atk(char_sheet, battle_scene.ally_units.pick_random())


func take_damage(dmg : int) -> int:
	var dmgDealt : int = maxi(1, dmg - char_sheet.def)
	char_sheet.cur_hp -= dmgDealt
	return dmgDealt

func set_select_index(index : int) -> void:
	select_index = index
	shader.set_shader_parameter("enable", true)
	is_selectiable = true

#TODO Maybe add a tooltip to show character sheet's stats
func _on_selection_area_mouse_entered() -> void:
	if is_selectiable:
		%SelectUI.show()
		%SelectAnimation.play("Show")
	else:
		shader.set_shader_parameter("enable", true)


func _on_selection_area_mouse_exited() -> void:
	if is_selectiable:
		%SelectUI.hide()
		%SelectAnimation.stop()
	else:
		shader.set_shader_parameter("enable", false)


func select_cancel()-> void:
	%SelectUI.hide()
	%SelectAnimation.stop()
	shader.set_shader_parameter("enable", false)
	is_selectiable = false


func _on_selection_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_selectiable:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			battle_manager.selected_index = select_index
			battle_manager.end_selection.emit()
