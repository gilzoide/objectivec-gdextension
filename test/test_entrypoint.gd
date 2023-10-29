extends SceneTree

const GDSCRIPT_TEST_DIR = "res://unit_tests"

func _initialize():
	var all_success = true
	
	if not Engine.has_singleton("ObjectiveC"):
		print("ObjectiveC singleton not found, skipping tests")
	else:
		for gdscript in DirAccess.get_files_at(GDSCRIPT_TEST_DIR):
			var file_name = str(GDSCRIPT_TEST_DIR, "/", gdscript)
			print("> ", gdscript, ":")
			
			var obj = load(file_name).new()
			for method in obj.get_method_list():
				var method_name = method.name
				if method_name.begins_with("test"):
					if not obj.call(method_name):
						all_success = false
						printerr("  ❌ ", method_name)
					else:
						print("  ✅ ", method_name)
	
	quit(0 if all_success else -1)
