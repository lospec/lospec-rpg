class_name Unit extends Node2D

var char_sheet : CharacterSheet
var char_ap : CharacterAP

func Setup(char_sheet : CharacterSheet) -> void:
	self.char_sheet = char_sheet
	%CharacterSprite.texture = char_sheet.sprite_sheet
	
	%HPBar.max_value = char_sheet.maxHp
	%HPBar.value = char_sheet.curHp
	char_sheet.OnHpChanged.connect(
		func(value : int, max : int):
			%HPBar.value = value
			%HPBar.max_value = max
	)


func PerformAIAction(battle_scene : BattleManager) -> void:
	battle_scene.BasicAtk(char_sheet, battle_scene.allyUnits[0])
	

func TakeDamage(dmg : int) -> int:
	var hurt_val : int = dmg - char_sheet.def
	char_sheet.curHp -= hurt_val
	return hurt_val
	
