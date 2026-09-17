@tool
extends EditorScript

func _run() -> void:
	var total_lines: int = 0
	var blanks : int = 0
	var comments: int = 0
	var codes: int = 0
	var script_files: Array[String] = []
	
	var dir: DirAccess = DirAccess.open("res://")
	if dir:
		script_files = Get_script_files(dir)

	for script_file : String in script_files:
		var file: FileAccess = FileAccess.open(script_file, FileAccess.READ)
		if file:
			while not file.eof_reached():
				var text : String = file.get_line()
				total_lines += 1
				if text.is_empty():
					blanks += 1
				elif text.begins_with("#"):
					comments += 1
				else: 
					codes += 1
			file.close()
			
	print("Script count: ", script_files.size())
	print("Codes: ", codes)
	print("Blanks: ", blanks)
	print("Comments: ", comments)
	print("Total lines: ", total_lines)


func Get_script_files(dir: DirAccess) -> Array[String]:
	var script_files: Array[String] = []
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	
	while file_name != "":
		var current: String = dir.get_current_dir() + "/" + file_name
		
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			var subdir: DirAccess = DirAccess.open(current)
			if subdir:
				script_files += Get_script_files(subdir)
		elif file_name.ends_with(".gd"):
			script_files.append(current)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return script_files
