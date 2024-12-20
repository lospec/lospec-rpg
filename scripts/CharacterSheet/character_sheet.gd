class_name CharacterSheet extends Resource

@export var char_name : String
@export var sprite_sheet : CompressedTexture2D

@export_group("Stats")

@export_range(1, 0, 1, "or_greater") var maxHp : int :
	set(value):
		maxHp = value
		maxHp = maxi(1, maxHp)
		OnHpChanged.emit(curHp, maxHp)

@export_range(0, 0, 1, "or_greater") var dmg : int

@export var def : int
@export var maxMana : int:
	set(value):
		maxMana = value
		maxMana = maxi(0, maxMana)
		OnManaChanged.emit(curMana, maxMana)

@export var magic : int

var curHp : int :
	set(value):
		curHp = value
		curHp = clampi(curHp, 0, maxHp)
		if curHp <= 0: OnDeath.emit(self)
		OnHpChanged.emit(curHp, maxHp)

var curMana : int :
	set(value):
		curMana = value
		curMana = clampi(curMana, 0, maxMana)
		OnManaChanged.emit(curMana, maxMana)

signal OnDeath(character : CharacterSheet)
signal OnHpChanged(value : int, max : int)
signal OnManaChanged(value : int, max : int)


@export_group("Skills")
@export var skill : Array[Skill]


var unitRef : Unit

func Reset() -> void:
	curHp = maxHp
	curMana = maxMana
