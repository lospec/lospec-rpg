@tool
extends Marker2D

const UNIT = preload("res://scenes/battle_scene/unit.tscn")

@export var spacing : int:
	set(value):
		spacing = value
		set_positions()

@export var count : int:
	set(value):
		if !Engine.is_editor_hint(): return
		count = maxi(0, value)
		
		var children : Array[Node] = get_children()
		if count > children.size():
			for i : int in range(count - children.size()):
				spawn_new()
		elif count < children.size():
			for i : int in range(children.size() - count):
				get_child(children.size() - i - 1).free()
		
		await get_tree().process_frame
		set_positions()

func spawn_new() -> void:
	var unit : Unit = UNIT.instantiate()
	add_child(unit)
	unit.owner = get_tree().edited_scene_root

func set_positions() -> void:
	var children : Array[Node] = get_children()
	var unit_position : Vector2 = Vector2((children.size() - 1) / -2.0 * spacing, 0)
	
	for c : Node2D in children:
		c.position = unit_position
		unit_position.x += spacing
