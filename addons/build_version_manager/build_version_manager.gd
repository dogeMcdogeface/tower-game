@tool
extends EditorPlugin

# Constants
const SETTINGS_PATH = "res://addons/build_version_manager/record.json"
const EXPORT_PLUGIN_PATH = "res://addons/build_version_manager/build_version_export.gd"
const DOCK_SCENE_PATH = "res://addons/build_version_manager/build_version_manager_dock.tscn"
const UPDATE_INTERVAL_MS = 2000


# Runtime properties
var dock
var export_plugin
var versions: Array = []
var last_json_string = ""
var update_timer = 0
var versions_dirty = true

# Lifecycle Methods
func _enter_tree():
	add_autoload_singleton("BuildVersion", "res://addons/build_version_manager/BuildVersion.gd")
	
	var BuildVersionExportPlugin = preload(EXPORT_PLUGIN_PATH)
	export_plugin = BuildVersionExportPlugin.new()
	export_plugin.BuildVersionManager = self
	add_export_plugin(export_plugin)
	
	scene_saved.connect(_on_scene_saved)

	dock = preload(DOCK_SCENE_PATH).instantiate()
	dock.BuildVersionManager = self
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)

	_load_version_data()

func _exit_tree():
	remove_control_from_docks(dock)
	remove_autoload_singleton("BuildVersion")
	remove_export_plugin(export_plugin)
	dock.free()

func _process(delta):
	if not Engine.is_editor_hint():
		return

	if not versions_dirty and Time.get_ticks_msec() < update_timer:
		return

	versions_dirty = false
	update_timer = Time.get_ticks_msec() + UPDATE_INTERVAL_MS

	var json_string = JSON.stringify(versions)
	if json_string == last_json_string:
		return

	ProjectSettings.set_setting("application/config/version", versions[-1])
	ProjectSettings.save()

	dock.update()
	last_json_string = json_string
	
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_line(json_string)

# Version History I/O
func _load_version_data():
	if FileAccess.file_exists(SETTINGS_PATH):
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		while file.get_position() < file.get_length():
			var json_string = file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result != OK:
				push_warning("JSON Parse Error: %s in %s at line %d" % [
					json.get_error_message(), json_string, json.get_error_line()
				])
				continue

			versions = json.get_data()

	if versions.is_empty() or versions == [null]:
		reset_version_history()

func reset_version_history():
	versions = [get_default_version()]
	versions_dirty = true

# Versioning Logic
func increment_version(increment_type: String, friendly_name: String = "") -> void:
	if versions.is_empty():
		versions.append(get_default_version())

	var last = versions[-1]
	var new_version := {
		"major": last.get("major", 0),
		"minor": last.get("minor", 0),
		"sub": last.get("sub", 0),
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

	new_version["friendly_name"] = (
		friendly_name if friendly_name != "" else _generate_friendly_name()
	)

	versions.append(new_version)
	versions_dirty = true

# Utility Methods
func get_default_version() -> Dictionary:
	return {
		"major": 0,
		"minor": 0,
		"sub": 0,
		"friendly_name": _generate_friendly_name(),
		"release_timestamp": Time.get_unix_time_from_system()
	}

func get_readable_time(timestamp: int) -> String:
	var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
	return "%02d/%02d/%02d %02d:%02d" % [
		datetime.day, datetime.month, datetime.year % 100,
		datetime.hour, datetime.minute
	]

# Friendly Name Generator
const adjectives = [
	"Brave", "Silent", "Crimson", "Witty", "Bright", "Rapid", "Misty", "Clever", "Swift", "Frosty",
	"Jolly", "Sharp", "Quiet", "Zesty", "Bold", "Feisty", "Sunny", "Vivid", "Snappy", "Gleam",
	"Sly", "Breezy", "Loyal", "Fierce", "Tough", "Slick", "Lively", "Zany", "Agile", "Happy",
	"Smoky", "Nimble", "Fresh", "Dizzy", "Neat", "Chill", "Spicy", "Classy", "Rusty", "Nifty",
	"Shiny", "Funky", "Grimy", "Lofty", "Stark", "Giddy", "Noble", "Snug", "Flaky", "Edgy",
	"Cozy", "Rugged", "Wired", "Witty", "Zesty", "Bumpy", "Frisk", "Bland", "Flash", "Dank",
	"Fuzzy", "Jumpy", "Proud", "Sassy", "Soggy", "Thick", "Weird", "Yummy", "Spiky", "Tidy",
	"Faint", "Ghost", "Moody", "Hardy", "Stern", "Silly", "Breez", "Wavy", "Chunk", "Rigid",
	"Dusty", "Sleek", "Rough", "Grizz", "Crude", "Beige", "Amber", "Lilac", "Peach", "Aqua",
	"Coral", "Naked", "Hazel", "Ivory", "Jaded", "Khaki", "Mauve", "Olive", "Pale", "Royal"
]
const nouns = [
	"Falcon", "River", "Shadow", "Phoenix", "Mountain", "Blaze", "Ridge", "Comet", "Storm", "Flame",
	"Stone", "Glade", "Hawk", "Cloud", "Viper", "Drake", "Spire", "Flint", "Grove", "Breeze",
	"Frost", "Spark", "Moose", "Tiger", "Wolf", "Eagle", "Bison", "Crane", "Otter", "Whale",
	"Shark", "Jaguar", "Lynx", "Cobra", "Orca", "Puma", "Bat", "Beetle", "Lark", "Fawn",
	"Quail", "Snail", "Trout", "Squid", "Mouse", "Roach", "Swine", "Oxen", "Toad", "Aspen",
	"Thorn", "Cedar", "Maple", "Birch", "Sands", "Reef", "Cove", "Tundra", "Oasis", "Delta",
	"Valley", "Cliff", "Dunes", "Canyon", "Basin", "Marsh", "Jungle", "Forest", "Meadow", "Hollow",
	"Nest", "Pond", "Peak", "Plain", "Range", "Shore", "Woods", "Field", "Crater", "Icecap",
	"Bluff", "Islet", "Harbor", "Fjord", "Geyser", "Spray", "Glacier", "Mist", "Echo", "Ash",
	"Ember", "Drift", "Dust", "Wave", "Tide", "Slope", "Burrow", "Gloom", "Cinder", "Talon"
]


func _generate_friendly_name() -> String:
	var used_names := versions.map(func(v): return v.get("friendly_name"))
	for attempt in range(20):
		var name = "%s%s" % [
			adjectives[randi() % adjectives.size()],
			nouns[randi() % nouns.size()]
		]
		if name not in used_names:
			return name

	push_warning("Could not generate unique name after 20 attempts.")
	return "Unnamed Version %d" % Time.get_unix_time_from_system()

# Signal Callbacks
func _on_scene_saved(filepath: String) -> void:
	if dock.increment_on_save():
		increment_version("sub")

func _on_project_exported():
	if dock.increment_on_export():
		increment_version("sub")
