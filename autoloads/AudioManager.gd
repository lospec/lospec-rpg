extends AudioStreamPlayer

func PlayMusic(music : AudioStream, replay : bool = false)  -> void:
	if stream == music && !replay:
		return
	stream = music
	play()

func PlaySFX(sfx : AudioStream) -> void:
	var sfx_player : AudioStreamPlayer = AudioStreamPlayer.new()
	sfx_player.stream = sfx
	sfx_player.bus = "Sfx"
	add_child(sfx_player)
	sfx_player.play()
	await sfx_player.finished
	
	sfx_player.queue_free()
