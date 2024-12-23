class_name CharacterSheet extends Resource

@export var char_name : String
@export var sprite_sheet : CompressedTexture2D

@export_group("Stats")

@export_range(1, 0, 1, "or_greater") var max_hp : int :
	set(value):
		max_hp = value
		max_hp = maxi(1, max_hp)
		hp_changed.emit(cur_hp, max_hp)

@export_range(0, 0, 1, "or_greater")  var max_mana : int:
	set(value):
		max_mana = value
		max_mana = maxi(0, max_mana)
		mana_changed.emit(cur_mana, max_mana)
		
@export_range(0, 0, 1, "or_greater") var dmg : int

@export var def : int

@export var magic : int

var cur_hp : int :
	set(value):
		cur_hp = value
		cur_hp = clampi(cur_hp, 0, max_hp)
		if cur_hp <= 0: death.emit(self)
		hp_changed.emit(cur_hp, max_hp)

var cur_mana : int :
	set(value):
		cur_mana = value
		cur_mana = clampi(cur_mana, 0, max_mana)
		mana_changed.emit(cur_mana, max_mana)

signal death(char_sheet : CharacterSheet)
signal hp_changed(value : int, max : int)
signal mana_changed(value : int, max : int)


@export_group("Skills")
@export var skill : Array[Skill]


var unit_ref : Unit

func Reset() -> void:
	cur_hp = max_hp
	cur_mana = max_mana
