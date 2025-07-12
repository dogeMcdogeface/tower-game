@tool 
extends EditorPlugin 

const settings_path = "res://addons/build_version_manager/record.json"
var dock
var export_plugin 
var BuildVersionExportPlugin = preload("res://addons/build_version_manager/build_version_export.gd")

var versions: Array = []
 
func _enter_tree():
	add_autoload_singleton("BuildVersion", "res://addons/build_version_manager/BuildVersion.gd")
	export_plugin = BuildVersionExportPlugin.new()
	export_plugin.BuildVersionManager = self
	add_export_plugin(export_plugin)
	
	scene_saved.connect(_on_scene_saved)
	dock = preload("res://addons/build_version_manager/build_version_manager_dock.tscn").instantiate()
	dock.BuildVersionManager = self
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
	
	if FileAccess.file_exists(settings_path):
		var save_file = FileAccess.open(settings_path, FileAccess.READ)
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()
			var json = JSON.new()

			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue
			else:
				versions = json.get_data()

	if versions == [] or versions == [null]:
		resetVersionHistory()

func _exit_tree():
	remove_control_from_docks(dock)
	remove_autoload_singleton("BuildVersion")
	remove_export_plugin(export_plugin)
	# Erase the control from the memory.
	dock.free()


var last_json_string
var update_timer = 0
var update_interval = 2000
var _versions_changed = true
func _process(delta):
	if !Engine.is_editor_hint():return
	if !_versions_changed and Time.get_ticks_msec() < update_timer: return
	_versions_changed = false
	update_timer = Time.get_ticks_msec() + update_interval

	var json_string = JSON.stringify(versions)
	if last_json_string == json_string: return

	ProjectSettings.set_setting("application/config/version", versions[-1])
	ProjectSettings.save()
	dock.update()
	var save_file = FileAccess.open(settings_path, FileAccess.WRITE)
	last_json_string = json_string 
	save_file.store_line(json_string)


func resetVersionHistory():
	versions = [get_default_version()]
	_versions_changed = true



####################################################################
func get_default_version() -> Dictionary:
	return {
		"major": 0,
		"minor": 0,
		"sub": 0,
		"friendly_name": _generate_friendly_name(),
		"release_timestamp": Time.get_unix_time_from_system()
	}


const adjectives = [
	"Brave", "Silent", "Crimson", "Witty", "Bright",
	"Rapid", "Misty", "Clever", "Swift", "Frosty",
	"Jolly", "Sharp", "Quiet", "Zesty", "Bold",
	"Feisty", "Sunny", "Vivid", "Snappy", "Gleam"
]
const nouns = [
	"Falcon", "River", "Shadow", "Phoenix", "Mountain",
	"Blaze", "Ridge", "Comet", "Storm", "Flame",
	"Stone", "Glade", "Hawk", "Cloud", "Viper",
	"Drake", "Spire", "Flint", "Grove", "Breeze"
]


func _generate_friendly_name() -> String:
	var used_names := versions.map(func(v): return v.get("friendly_name"))
	var max_attempts = 20
	var attempt = 0
	while attempt < max_attempts:
		var name = "%s %s" % [
			adjectives[randi() % adjectives.size()],
			nouns[randi() % nouns.size()]
		]
		if name not in used_names:
			return name
		attempt += 1

	push_warning("Could not generate unique name after %d attempts." % max_attempts)
	return "Unnamed Version %d" % Time.get_unix_time_from_system()  # fallback name
	
	
func get_readable_time(timestamp: int) -> String:
	var datetime := Time.get_datetime_dict_from_unix_time(timestamp)
	return "%02d/%02d/%02d %02d:%02d" % [
		datetime.day, datetime.month, datetime.year % 100,
		datetime.hour, datetime.minute
	]
func increment_version(increment_type: String, friendly_name: String = "") -> void:
	if versions.is_empty():
		versions.append(get_default_version())

	var last_version = versions[-1]

	var new_version := {
		"major": last_version.get("major", 0),
		"minor": last_version.get("minor", 0),
		"sub": last_version.get("sub", 0),
		"friendly_name": "",
		"release_timestamp": Time.get_unix_time_from_system()
	}

	match increment_type:
		"major":
			new_version["major"] += 1
			new_version["minor"] = 0
			new_version["sub"] = 0
		"minor":
			new_version["minor"] += 1
			new_version["sub"] = 0
		"sub":
			new_version["sub"] += 1
		_:
			push_error("Invalid increment type: %s" % increment_type)
			return

	new_version["friendly_name"] = friendly_name if friendly_name != "" else _generate_friendly_name()

	versions.append(new_version)
	_versions_changed = true




func _on_scene_saved(filepath: String) -> void:
	if dock.increment_on_save():
		increment_version("sub")


func _on_project_exported():
	if dock.increment_on_export():
		increment_version("sub")
