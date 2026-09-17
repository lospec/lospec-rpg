class_name BattleManager extends CanvasLayer

signal end_turn
signal end_display_text
signal end_selection(index : int)
signal hide_selection
signal selection_index_changed(index : int)

enum UIMenuState {NONE, ATTACK, SKILL, ITEM}

const UNIT = preload("res://scenes/battle_scene/unit.tscn")
const UNIT_SPACING = 30
const NUMBER_POP_UP = preload("res://scenes/number_pop_up.tscn")
const TEXT_SPEED : float = 30
const TEXT_SPEED_UP_MULT : float = 2


var ally_units : Array[Unit] = []
var enemy_units : Array[Unit] = []

#Turn temp variables
var cur_player_unit : Unit
var cur_char_sheet : CharacterSheet
var selected_index : int = 0
var selection_size : int
var is_unit_selecting : bool:
	set(value):
		is_unit_selecting = value
		if value == true:
			prev_focused = get_viewport().gui_get_focus_owner()
			prev_focused.release_focus()
		else:
			if prev_focused != null: prev_focused.grab_focus()

var typed_text : float
var text_length : int

var get_reward : bool

var direct_end_fight : bool:
	set(value):
		direct_end_fight = value
		if value == true: end_turn.emit()

var is_fight_ended : bool:
	get:
		return direct_end_fight || ally_units.is_empty() || enemy_units.is_empty()

var prev_focused : Control


func _input(event: InputEvent):
	#TODO REMOVE THIS
	#Doesn't even stop the turn loop or any awaits, so this causes bugs
	if event is InputEventKey && event.pressed:
		match(event.keycode):
			KEY_R:
				get_tree().reload_current_scene()
				hide()
	
	if is_unit_selecting:
		if Input.is_action_just_pressed("Left"):
			selected_index -= 1
			selected_index = maxi(0, selected_index)
			selection_index_changed.emit(selected_index)
		
		elif Input.is_action_just_pressed("Right"):
			selected_index += 1
			selected_index = mini(selection_size - 1, selected_index)
			selection_index_changed.emit(selected_index)
		
		if Input.is_action_just_pressed("Confirm"):
			end_selection.emit()
		elif Input.is_action_just_pressed("Cancel"):
			select_cancel()


func _ready() -> void:
	end_selection.connect(func() -> void:
		if selected_index != -1:
			prev_focused = null
			is_unit_selecting = false
		
		for c in selection_index_changed.get_connections():
			selection_index_changed.disconnect(c.callable)
		)
	
	var act_btn : Array[Node] = %ActionContainer.get_children()
	var start_index : int = act_btn.size() - 1
	
	for i : int in range(start_index):
		act_btn[i].focus_neighbor_bottom = act_btn[i + 1].get_path()
	
	for i : int in range(start_index, 0, -1):
		act_btn[i].focus_neighbor_top = act_btn[i - 1].get_path()


func _process(delta : float) -> void:
	if typed_text < text_length:
		if Input.is_action_just_pressed("SpeedUpDialogue"):
			typed_text += delta * TEXT_SPEED * TEXT_SPEED_UP_MULT
		else:
			typed_text += delta * TEXT_SPEED
		if Input.is_action_just_pressed("SkipDialogue"):
			typed_text = text_length
		%Text.visible_characters = typed_text
		
		if typed_text >= text_length:
			%BlinkNext.start()
		
	else:
		if Input.is_action_just_pressed("SpeedUpDialogue") || Input.is_action_just_pressed("SkipDialogue"):
			end_display_text.emit()

#Battle Logic
func fight(enemies : Array[CharacterAP], allies : Array[CharacterSheet] = Globals.player_party) -> void:
	if enemies.is_empty():
		push_error("There's no enemies!")
		return
	
	if allies.is_empty():
		push_error("There's no allies!")
		return
	
	direct_end_fight = false
	get_reward = true
	
	Globals.battle.emit()
	get_tree().current_scene.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	
	initialize_action_menu(%ItemContainer, Globals.player_inv, %ItemButton, item_initialize)
	
	show()
	
	ally_units.clear()
	enemy_units.clear()
	
	#Clear out unit holders
	for child in %AllyContainer.get_children() + %EnemyContainer.get_children():
		child.queue_free()
	
	#Spawn in Units
	var unit_position : Vector2 = Vector2((allies.size() - 1) / 2.0 * UNIT_SPACING, 0)
	for cs : CharacterSheet in allies:
		spawn_unit(cs, Unit.Group.ALLY, unit_position)
		unit_position.x -= UNIT_SPACING
	
	
	#Makes the charAp unique
	var new_enemies : Array[CharacterAP] = []
	for cap : CharacterAP in enemies:
		new_enemies.append(cap.duplicate(true))
	
	unit_position = Vector2((enemies.size() - 1) / 2.0 * -UNIT_SPACING, 0)
	for cap : CharacterAP in new_enemies:
		cap.char_sheet.Reset()
		var unit : Unit = spawn_unit(cap.char_sheet, Unit.Group.ENEMY, unit_position)
		unit.action_priorities = cap.action_priorities
		unit.get_node("CharacterSprite").flip_h = true
		unit_position.x += UNIT_SPACING
	
	await get_tree().process_frame
	await turn_loop()
	
	for a : CharacterSheet in allies:
		a.death.disconnect(remove_ally_unit)
		a.unit_ref = null
	
	for e : CharacterAP in new_enemies:
		e.char_sheet.death.disconnect(remove_enemy_unit)
		e.char_sheet.unit_ref = null
	
	if enemy_units.is_empty(): win()
	elif allies.is_empty(): lose()


func spawn_unit(char_sheet : CharacterSheet, group : Unit.Group, unit_position : Vector2) -> Unit:
	var parent_node : Node2D
	var on_remove_unit : Callable
	var group_unit : Array[Unit]
	
	match(group):
		Unit.Group.ALLY:
			parent_node = %AllyContainer
			on_remove_unit = remove_ally_unit
			group_unit = ally_units
		Unit.Group.ENEMY:
			parent_node = %EnemyContainer
			on_remove_unit = remove_enemy_unit
			group_unit = enemy_units
	
	
	var unit : Unit = UNIT.instantiate()
	parent_node.add_child.call_deferred(unit)
	unit.setup.call_deferred(char_sheet, group, group_unit.size(), self)
	unit.position = unit_position
	
	group_unit.append(unit)
	char_sheet.death.connect(on_remove_unit)
	char_sheet.unit_ref = unit
	hide_selection.connect(unit.select_cancel)
	end_selection.connect(unit.select_cancel)
	return unit


func turn_loop() -> void:
	while true:
		for ally : Unit in  ally_units:
			show_actions(ally)
			await end_turn
			if is_fight_ended: return
		
		for enemy : Unit in  enemy_units:
			enemy.perform_ai_action(self)
			await end_turn
			if is_fight_ended: return


func remove_ally_unit(char_sheet : CharacterSheet) -> void:
	ally_units.erase(char_sheet.unit_ref)


func remove_enemy_unit(char_sheet : CharacterSheet) -> void:
	enemy_units.erase(char_sheet.unit_ref)


func win() -> void:
	#TODO EXP, Money, and ITEMS based on enemy(?)
	await display_text(["You came out victorious!", "[wave][rainbow]Awesome!"])
	return_to_world()


func lose() -> void:
	print("lose")


func return_to_world() -> void:
	Globals.game_world.emit()
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_INHERIT
	visible = false

#UI
func show_actions(unit : Unit) -> void:
	cur_player_unit = unit
	cur_char_sheet = unit.char_sheet
	%Actions.show()
	%Menu.hide()
	%ActionInfo.hide()
	
	#Skills
	if cur_char_sheet.skills.is_empty():
		disable_button(%SkillButton, true)
	else:
		disable_button(%SkillButton, false)
		initialize_action_menu(%SkillContainer, cur_char_sheet.skills.keys(), %SkillButton, skill_initialize)
	
	disable_button(%ItemButton, Globals.player_inv.is_empty())
	
	show_action_menu(UIMenuState.ATTACK)
	%AttackButton.grab_focus()


func disable_button(button : Button, condition : bool) -> void:
	button.disabled = condition
	button.focus_mode = Control.FOCUS_NONE if condition else Control.FOCUS_ALL


func initialize_action_menu(container : Control, array : Array, left_path : Control, on_press : Callable) -> void:
	if array.is_empty(): return
	
	for child : Node in container.get_children():
		child.queue_free()
	
	var path : NodePath = left_path.get_path()
	var btn_array : Array[Button] = []
	for element in array:
		var btn : Button = Button.new()
		container.add_child(btn)
		btn.text = element.name
		btn.focus_neighbor_left = path
		btn.pressed.connect(on_press.bind(element))
		btn_array.append(btn)
	
	var temp_btn : Button = btn_array[0]
	temp_btn.focus_neighbor_top = temp_btn.get_path()
	
	temp_btn = btn_array[btn_array.size() - 1]
	temp_btn.focus_neighbor_bottom = temp_btn.get_path()


func show_action_menu(menu : UIMenuState) -> void:
	%InfoPanel.hide()
	%Menu.show()
	%AttackMenu.visible = menu == UIMenuState.ATTACK
	%SkillMenu.visible = menu == UIMenuState.SKILL
	%ItemMenu.visible = menu == UIMenuState.ITEM
	
	var action_button : Button
	var container : Control
	
	match(menu):
		UIMenuState.ATTACK:
			action_button = %AttackButton
		UIMenuState.SKILL:
			action_button = %SkillButton
			container = %SkillContainer
		UIMenuState.ITEM:
			action_button = %ItemButton
			container = %ItemContainer
	
	if action_button:
		UiNavigation.connect_cancel(action_button.grab_focus)
	else:
		UiNavigation.clear_cancel()
	
	if container:
		action_button.focus_neighbor_right = container.get_child(0).get_path()
	
	selected_index = -1
	end_selection.emit()


func select(group : BattleNamespace.TargetGroup, type : BattleNamespace.TargetType, targetable_self : bool) -> Array[Unit]:
	var selectable_units : Array[Unit]
	var selected : Array[Unit] = []
	var ally_units : Array[Unit] = self.ally_units.duplicate()
	ally_units.reverse()
	
	match(group):
		BattleNamespace.TargetGroup.ENEMY:
			selectable_units = enemy_units
			
		BattleNamespace.TargetGroup.ALLY:
			selectable_units = ally_units
			
		BattleNamespace.TargetGroup.BOTH:
			selectable_units = ally_units + enemy_units
			
		BattleNamespace.TargetGroup.SELF:
			return [await select_unit_single([cur_player_unit])]
	
	if !targetable_self:
		selectable_units.erase(cur_player_unit)
	
	selectable_units = selectable_units.duplicate()
	
	match(type):
		BattleNamespace.TargetType.SINGLE:
			return [await select_unit_single(selectable_units)]
		BattleNamespace.TargetType.ALL:
			return await select_group_all_unit(selectable_units)
		BattleNamespace.TargetType.ALL_SEPERATE:
			return await select_group_seperate_unit(selectable_units)
	
	return []


func select_unit_single(group_unit : Array[Unit]) -> Unit:
	is_unit_selecting = true
	selected_index = 0
	selection_size = group_unit.size()
	
	hide_selection.emit()
	for i : int in range(0, group_unit.size()):
		var unit : Unit = group_unit[i]
		unit.set_select_index(i)
		connect_select_show_signal(unit)
	
	selection_index_changed.emit(0)
	
	await end_selection
	
	if selected_index != -1:
		return group_unit[selected_index]
	else:
		return null


func select_group_all_unit(group_unit : Array[Unit]) -> Array[Unit]:
	is_unit_selecting = true
	selected_index = 0
	selection_size = 1
	
	hide_selection.emit()
	for unit : Unit in group_unit:
		unit.set_select_index(0)
		connect_select_show_signal(unit)
	
	selection_index_changed.emit(0)
	
	await end_selection
	
	if selected_index != -1:
		return group_unit
	else:
		return []


func select_group_seperate_unit(group_unit : Array[Unit]) -> Array[Unit]:
	is_unit_selecting = true
	selected_index = 0
	selection_size = 2
	
	hide_selection.emit()
	for unit : Unit in group_unit:
		unit.set_select_index(unit.group)
		connect_select_show_signal(unit)
	
	selection_index_changed.emit(0)
	
	await end_selection
	
	match(selected_index as Unit.Group):
		Unit.Group.ALLY:
			return ally_units.duplicate()
		Unit.Group.ENEMY:
			return enemy_units.duplicate()
		_:
			return []


func connect_select_show_signal(unit : Unit) -> void:
	if !selection_index_changed.is_connected(unit.show_select_ui):
			selection_index_changed.connect(unit.show_select_ui)


func select_cancel() -> void:
	is_unit_selecting = false
	selected_index = -1
	end_selection.emit()

#TODO Idk where to put this, so here for now
func basic_atk(char_sheet : CharacterSheet, target : Unit) -> void:
	await display_text(["%s does a basic attack!" % char_sheet.name])
	await display_text([
		"%s took %d damage!" % [target.char_sheet.name, target.hurt(char_sheet.dmg)]
	])
	end_turn.emit()


func hide_actions() -> void:
	%Actions.hide()
	UiNavigation.clear_cancel()


func skill_initialize(skill : SkillResource) -> void:
	var selected_units : Array[Unit] = await select(skill.target_group, skill.target_type, skill.targetable_self)
	skill.initialize(self, cur_player_unit, selected_units, false)


func item_initialize(item : Item) -> void:
	print(item.name)


func display_text(texts : Array[String]) -> void:
	%Actions.hide()
	%DisplayText.show()
	
	set_process(true)
	for t : String in texts:
		%Next.hide()
		%BlinkNext.stop()
		%Text.visible_ratio = 0
		%Text.text = t
		typed_text = 0
		text_length = t.length()
		await end_display_text
	
	set_process(false)
	await get_tree().create_timer(0.1).timeout
	%DisplayText.hide()


func create_num_popup(value : int, num_pos : Vector2, color : Color = Color.WHITE) -> void:
	var num : Label = NUMBER_POP_UP.instantiate()
	
	num_pos += Vector2.UP * 3
	
	environment_add_child(num)
	num.text = str(value)
	num.global_position = num_pos + Vector2.DOWN * 3
	num.set("theme_override_colors/font_color", color)
	num.scale = Vector2.ZERO
	
	var tween : Tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(
		num, "global_position", num_pos, 0.4
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT).set_delay(0.05)
	tween.tween_property(num, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		num, "modulate", Color.TRANSPARENT, 0.5
		).set_trans(Tween.TRANS_LINEAR).set_delay(1.2)
	
	tween.finished.connect(func(): num.queue_free())


func environment_add_child(node: Node, force_readable_name: bool = false, internal: InternalMode = 0) -> void:
	%EnvironmentContainer.add_child(node, force_readable_name, internal)


func _on_attack_pressed() -> void:
	var unit : Unit = await select_unit_single(enemy_units)
	if unit:
		basic_atk(cur_char_sheet, unit)


func _on_skill_button_pressed() -> void:
	if %SkillContainer.get_child_count() != 0:
		%SkillContainer.get_child(0).grab_focus()


func _on_item_button_pressed() -> void:
	if %ItemContainer.get_child_count() != 0:
		%ItemContainer.get_child(0).grab_focus()


func _on_run_pressed() -> void:
	await display_text(["You tried to [wave]run away!", "..."])
	
	if randf_range(0.0, 1.0) >= 0.5:
		await display_text(["You successfully ran away!", "Run now you little chicken 🐔🐤"])
		#TODO play chick sfx :)
		get_reward = false
		direct_end_fight = true
		return_to_world()
	else:
		await display_text(["It failed!"])
		end_turn.emit()
