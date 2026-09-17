class_name TextBox extends Control

## Typewriter-style text display, shared between the battle UI and overworld dialogue.
## Call display_text() and await it; it resolves once every line has been read and dismissed.

signal end_display_text

const TEXT_SPEED : float = 30
const TEXT_SPEED_UP_MULT : float = 2

var typed_text : float
var text_length : int


func _ready() -> void:
	set_process(false)
	hide()


func _process(delta : float) -> void:
	if typed_text < text_length:
		if Input.is_action_pressed("SpeedUpDialogue"):
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


func display_text(texts : Array[String]) -> void:
	show()
	
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
	hide()


func _on_blink_next_timeout() -> void:
	%Next.visible = !%Next.visible
