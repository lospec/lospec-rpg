# changes a sprite texture at the beginning of the match
func update_texture(sprite: AnimatedSprite2D, texture: Texture2D):
	var reference_frames := sprite.sprite_frames
	var updated_frames := SpriteFrames.new()

	for animation_name in reference_frames.get_animation_names():
		if animation_name != "default":
			updated_frames.add_animation(animation_name)
			updated_frames.set_animation_speed(animation_name, reference_frames.get_animation_speed(animation_name))
			updated_frames.set_animation_loop(animation_name, reference_frames.get_animation_loop(animation_name))

			for i in range(reference_frames.get_frame_count(animation_name)):
				var original_frame := reference_frames.get_frame_texture(animation_name, i) as AtlasTexture
				var updated_texture := original_frame.duplicate() as AtlasTexture
				updated_texture.atlas = texture

				# Copy the region from the original frame
				updated_texture.region = original_frame.region

				# Find the index of the frame with the matching texture
				var frame_index := -1
				for j in range(updated_frames.get_frame_count(animation_name)):
					if updated_frames.get_frame_texture(animation_name, j) == original_frame:
						frame_index = j
						break

				# If the frame is found, update it
				if frame_index != -1:
					updated_frames.set_frame(animation_name, frame_index, updated_texture)
				else:
					# Add the frame with the correct duration if not found
					updated_frames.add_frame(animation_name, updated_texture, reference_frames.get_frame_duration(animation_name, i))

	updated_frames.remove_animation("default")
	sprite.sprite_frames = updated_frames
	sprite.play() # Ensure the animation plays
	
