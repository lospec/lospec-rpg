class_name BattleManager extends CanvasLayer

signal end_turn
signal end_display_text
signal end_selection

#Display Text Variables
var typed_text : float
var text_length : int
const TEXT_SPEED : float = 30
const TEXT_SPEED_UP_MULT : float = 2

var curCharSheet : CharacterSheet

const UNIT = preload("res://scenes/battle_scene/unit.tscn")
const UNIT_SPACING = 30

var ally_units : Array[Unit] = []
var enemy_units : Array[Unit] = []

var selected_index : int = 0

func _input(event: InputEvent):
	if event is InputEventKey && event.pressed && event.keycode == KEY_R:
		get_tree().reload_current_scene()

var direct_end_fight : bool:
	set(value):
		direct_end_fight = value
		if value == true: end_turn.emit()

var has_reward : bool

var is_fight_ended : bool:
	get:
		return direct_end_fight || ally_units.is_empty() || enemy_units.is_empty()


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
			%Next.show()
			%BlinkNext.start()
		
	else:
		if Input.is_action_just_pressed("SpeedUpDialogue") || Input.is_action_just_pressed("SkipDialogue"):
			
			end_display_text.emit()


func fight(enemies : Array[CharacterAP], allies : Array[CharacterSheet] = Globals.player_party) -> void:
	if enemies.is_empty():
		push_error("There's no enemies!")
		return
	
	if allies.is_empty():
		push_error("There's no allies!")
		return
	
	direct_end_fight = false
	has_reward = true
	
	Globals.battle.emit()
	get_tree().current_scene.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	show()
	
	ally_units.clear()
	enemy_units.clear()
	
	#Clear out unit holders
	for child in %AllyContainer.get_children() + %EnemyContainer.get_children():
		child.queue_free()
	
	#Spawn in Units
	var unit_position : Vector2 = Vector2((allies.size() - 1) / 2.0 * UNIT_SPACING, 0)
	for cs : CharacterSheet in allies:
		spawn_unit(cs, %AllyContainer, unit_position, ally_units, remove_ally_unit)
		unit_position.x -= UNIT_SPACING
	
	
	#Makes the charAp unique
	var new_enemies : Array[CharacterAP] = []
	for cap : CharacterAP in enemies:
		new_enemies.append(cap.duplicate(true))
	
	unit_position = Vector2((enemies.size() - 1) / 2.0 * -UNIT_SPACING, 0)
	for cap : CharacterAP in new_enemies:
		cap.char_sheet.Reset()
		var unit : Unit = spawn_unit(cap.char_sheet, %EnemyContainer, unit_position, enemy_units, remove_enemy_unit)
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


func spawn_unit(char_sheet : CharacterSheet, parent_node : Node2D, unit_position : Vector2, group_unit, on_remove_unit : Callable) -> Unit:
	var unit : Unit = UNIT.instantiate()
	parent_node.add_child.call_deferred(unit)
	unit.Setup.call_deferred(char_sheet, self)
	
	unit.position = unit_position
	
	group_unit.append(unit)
	char_sheet.death.connect(on_remove_unit)
	char_sheet.unit_ref = unit
	end_selection.connect(unit.select_cancel)
	return unit
	

func turn_loop() -> void:
	while true:
		for ally : Unit in  ally_units:
			show_actions(ally.char_sheet)
			await end_turn
			if is_fight_ended: return
		
		for enemy : Unit in  enemy_units:
			enemy.perform_ai_action(self)
			await end_turn
			if is_fight_ended: return
	

func show_actions(char_sheet : CharacterSheet) -> void:
	curCharSheet = char_sheet
	%Actions.show()
	%SelectPrompt.hide()
	%TextPrompt.hide()
	

func remove_ally_unit(char_sheet : CharacterSheet) -> void:
	ally_units.erase(char_sheet.unit_ref)


func remove_enemy_unit(char_sheet : CharacterSheet) -> void:
	enemy_units.erase(char_sheet.unit_ref)
	

func win() -> void:
	#TODO EXP and Money based on enemy(?)
	await display_text(["You came out victorious!", "[wave][rainbow]Awesome!"])
	return_to_world()
	

func lose() -> void:
	print("lose")
	

func return_to_world() -> void:
	Globals.game_world.emit()
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_INHERIT
	visible = false
	

func display_text(texts : Array[String]) -> void:
	%Actions.hide()
	%SelectPrompt.hide()
	%TextPrompt.show()
	
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
	

func _on_blink_next_timeout() -> void:
	%Next.visible = !%Next.visible 
	

func select_single_unit(group_unit : Array[Unit]) -> void:
	selected_index = 0
	%Actions.hide()
	%SelectPrompt.show()
	
	var i : int = 0
	for unit : Unit in group_unit:
		unit.set_select_index(i)
		i += 1


func select_group_unit(group_unit : Array[Unit]) -> void:
	pass


func _on_select_cancel_pressed() -> void:
	%SelectPrompt.hide()
	%Actions.show()
	selected_index = -1
	end_selection.emit()


#TODO Idk where to put this so here for now
func basic_atk(char_sheet : CharacterSheet, target : Unit) -> void:
	await display_text(["%s does a basic attack!" % char_sheet.char_name])
	await display_text([
		"%s took %d damage!" % [target.char_sheet.char_name, target.take_damage(char_sheet.dmg)]
	])
	end_turn.emit()


func _on_attack_pressed() -> void:
	if enemy_units.size() == 1:
		basic_atk(curCharSheet, enemy_units[0])
	else:
		select_single_unit(enemy_units)
		await end_selection
		if selected_index != -1:
			basic_atk(curCharSheet, enemy_units[selected_index])


func _on_skill_pressed() -> void:
	pass # Replace with function body.


func _on_item_pressed() -> void:
	pass # Replace with function body.


func _on_run_pressed() -> void:
	await display_text(["You tried to [wave]run away!", "..."])
	
	if randf_range(0.0, 1.0) >= 0.5:
		await display_text(["You successfully ran away!", "Run now little chicken 🐔🐤"])
		#TODO play chick sfx :)
		has_reward = false
		direct_end_fight = true
		return_to_world()
	else:
		await display_text(["It failed!"])
		end_turn.emit()
	
