extends CharacterBody2D



@export var character_name : String
@export var sprite_sheet:CompressedTexture2D

const SPEED = 200.0
const ACCEL = 10.0
const FRICTION = 10.0

var input: Vector2 = Vector2.ZERO
var STATE = 'move'

@onready var sprite = $AnimatedSprite2D

func _ready():
	if (sprite_sheet):
		var update_texture = load("update-texture.gd").new()
		update_texture.update_texture(sprite, sprite_sheet)


func _physics_process(delta: float) -> void:
	if STATE == 'move': state_move(delta)

func state_move(delta):
	var angle = rad_to_deg(velocity.angle()) - 90
	if angle < 0: angle += 360
	
	if (input == Vector2.ZERO): 
		sprite.speed_scale = (velocity.length() / SPEED * 2)+1
		sprite.play()
		sprite.animation = "walk"
		
		if velocity.length() < 10: 
			sprite.animation = "idle"
			sprite.speed_scale = 1
			velocity = lerp(velocity, Vector2.ZERO, delta * FRICTION * 2)
		else:
			velocity = lerp(velocity, Vector2.ZERO, delta * FRICTION)
	else:
		sprite.speed_scale = 2
		sprite.animation = "walk"
		sprite.flip_h = (angle > 0 && angle < 180)
		velocity = lerp(velocity, input * SPEED, delta * ACCEL)

	move_and_slide()
