extends Node

var entering_from : String
#var current_scene : BaseScene

signal onSceneRestart

func ChangeScene(entrance : String, scene : String) -> void:
	#GameManager.camera.CameraOff()
	entering_from = entrance
	#GameManager.ReparentNodes(self)
	
	await Transition("fade_in")
	
	await get_tree().create_timer(0.1).timeout
	
	get_tree().change_scene_to_file(scene)
	
	await Transition("fade_out")
	
	#if !current_scene:
		#push_error("There is no current scene")
		#return
	
	#current_scene.GameStart()

func GoToTitleScreen() -> void:
	await Transition("fade_in")
	
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = false
	#Globals.ui.queue_free()
	
	get_tree().change_scene_to_file("res://Scene/TitleScreen/TitleScreen.tscn")
	
	await Transition("fade_out")

func RestartScene() -> void:
	await Transition("fade_in")
	
	#current_scene.Restart()
	onSceneRestart.emit()
	
	await Transition("fade_out")

#TODO Create Transition
func Transition(animation_name : String) -> void:
	#TransitionManager.animation_player.play(animation_name)
	#await TransitionManager.animation_player.animation_finished
	pass
