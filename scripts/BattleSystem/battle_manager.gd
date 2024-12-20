class_name BattleManager extends CanvasLayer



signal EndTurn
signal DisplayTextEnd

#Display Text Variables
var typedText : float
var textLength : int
const TEXT_SPEED : float = 30
const TEXT_SPEED_UP_MULT : float = 2

var curCharSheet : CharacterSheet

const UNIT = preload("res://scenes/unit.tscn")

var allyUnits : Array[Unit] = []
var enemyUnits : Array[Unit] = []

var directEndFight : bool:
	set(value):
		directEndFight = value
		if directEndFight: EndTurn.emit()

var hasEndReward : bool

var isFightEnded : bool:
	get:
		return directEndFight || allyUnits.is_empty() || enemyUnits.is_empty()


func Fight(enemies : Array[CharacterAP], allies : Array[CharacterSheet] = Globals.player_party) -> void:
	if enemies.is_empty():
		push_error("There's no enemies!")
		return
	
	if allies.is_empty():
		push_error("There's no allies!")
		return
	
	directEndFight = false
	hasEndReward = true
	
	#%Background.frame = randi_range(0, %Background.hframes * %Background.vframes - 1)
	
	allyUnits.clear()
	enemyUnits.clear()
	
	#Clear out unit holders
	for child in %AllyContainer.get_children() + %EnemyContainer.get_children():
		child.queue_free()
	
	#Spawn in Units
	
	for a : CharacterSheet in allies:
		var unit : Unit = UNIT.instantiate()
		unit.Setup(a)
		%AllyContainer.add_child(unit)
		allyUnits.append(unit)
		a.OnDeath.connect(RemoveAllyUnit)
		a.unitRef = unit
	
	for e : CharacterAP in enemies:
		var unit : Unit = UNIT.instantiate()
		e.character_sheet.Reset()
		unit.Setup(e.character_sheet)
		%EnemyContainer.add_child(unit)
		enemyUnits.append(unit)
		e.character_sheet.OnDeath.connect(RemoveEnemyUnit)
		e.character_sheet.unitRef = unit
	
	
	Globals.Battle.emit()
	get_tree().current_scene.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	show()
	
	await TurnLoop()
	
	for a : CharacterSheet in allies:
		a.OnDeath.disconnect(RemoveAllyUnit)
	
	for e : CharacterAP in enemies:
		e.character_sheet.OnDeath.disconnect(RemoveEnemyUnit)
	
	if enemyUnits.is_empty(): Win()
	elif allies.is_empty(): Lose()

func TurnLoop() -> void:
	while true:
		for ally : Unit in  allyUnits:
			ShowActions(ally.char_sheet)
			await EndTurn
			if isFightEnded: return
		
		for enemy : Unit in  enemyUnits:
			enemy.PerformAIAction(self)
			await EndTurn
			if isFightEnded: return

func ShowActions(char_sheet : CharacterSheet) -> void:
	curCharSheet = char_sheet
	%Actions.show()
	%TextContainer.hide()


func RemoveAllyUnit(char_sheet : CharacterSheet) -> void:
	allyUnits.erase(char_sheet.unitRef)

func RemoveEnemyUnit(char_sheet : CharacterSheet) -> void:
	enemyUnits.erase(char_sheet.unitRef)

func Win() -> void:
	#TODO EXP and Money based on enemy(?)
	await DisplayText(["You came out victorious!", "[wave][rainbow]Awesome!"])
	ReturnToGameWorld()


func Lose() -> void:
	print("Lose")
	pass


func ReturnToGameWorld() -> void:
	Globals.GameWorld.emit()
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_INHERIT
	visible = false


func DisplayText(texts : Array[String]) -> void:
	%Actions.hide()
	%TextContainer.show()
	set_process(true)
	
	for t : String in texts:
		%Next.hide()
		%Text.visible_ratio = 0
		%Text.text = t
		typedText = 0
		textLength = t.length()
		await DisplayTextEnd
	
	set_process(false)
	await get_tree().create_timer(0.1).timeout


func _process(delta : float) -> void:
	if typedText < textLength:
		if Input.is_action_just_pressed("SpeedUpDialogue"):
			typedText += delta * TEXT_SPEED * TEXT_SPEED_UP_MULT
		else:
			typedText += delta * TEXT_SPEED
		if Input.is_action_just_pressed("SkipDialogue"):
			typedText = textLength
		%Text.visible_characters = typedText
	else:
		%Next.show()
		if Input.is_action_just_pressed("SpeedUpDialogue") || Input.is_action_just_pressed("SkipDialogue"):
			
			DisplayTextEnd.emit()


#TODO Idk where to put this so here for now
func BasicAtk(char_sheet : CharacterSheet, target : Unit) -> void:
	await DisplayText(["%s does a basic attack!" % char_sheet.char_name])
	await DisplayText([
		"%s took %d damage!" % [target.char_sheet.char_name, target.TakeDamage(char_sheet.dmg)]
	])
	EndTurn.emit()


func _on_attack_pressed() -> void:
	BasicAtk(curCharSheet, %EnemyContainer.get_child(0))


func _on_skill_pressed() -> void:
	pass # Replace with function body.


func _on_item_pressed() -> void:
	pass # Replace with function body.


func _on_run_pressed() -> void:
	await DisplayText(["You tried to [wave]run away!", "..."])
	
	if randf_range(0.0, 1.0) >= 0.5:
		await DisplayText(["You successfully ran away!", "Run now little chicken 🐔🐤"])
		#TODO play chick sfx :)
		hasEndReward = false
		directEndFight = true
		ReturnToGameWorld()
	else:
		await DisplayText(["It failed!"])
		EndTurn.emit()
	
