@tool
extends MarginContainer
class_name DetailTimeTrackerDock

var gui = EditorInterface.get_base_control()

func _ready():
	$Tree.columns = 2
	$Tree.column_titles_visible = true
	$Tree.hide_root = false
	$Tree.set_column_expand(0, true)
	$Tree.set_column_expand(1, false)
	$Tree.set_column_title(0, "Item")
	$Tree.set_column_title(1, "Time")
	$Tree.add_theme_constant_override("draw_relationship_lines", 0 )

func update(dict: Dictionary, get_aggregate_time: Callable):
	var root = $Tree.get_root()
	if root == null:
		root = $Tree.create_item()
	else:
		# Update root text and icon
		root.set_text(0, "Total Time on Project")
		root.set_icon(0, title_to_icon("Total Time on Project"))
		root.set_text(1, _format_time(get_aggregate_time.call(dict)))
		root.set_text_overrun_behavior(1, TextServer.OVERRUN_NO_TRIMMING)

	# Build/update recursively
	recursive_tree_build(dict, root, get_aggregate_time)

	# Align text
	root.call_recursive("set_text_alignment", 1, HORIZONTAL_ALIGNMENT_RIGHT)


func recursive_tree_build(dict: Dictionary, parent: TreeItem, get_aggregate_time: Callable):
	var children_map := {}  # Existing children by name
	var child := parent.get_first_child()
	while child != null:
		children_map[child.get_text(0)] = child
		child = child.get_next()

	var keys := dict.keys()
	keys.sort_custom(func(x: String, y: String) -> bool:
		if x.contains("other") or x.contains("unknown"):
			return false
		if y.contains("other") or y.contains("unknown"):
			return true
		if dict[x] is float and dict[y] is Dictionary:
			return true
		if dict[y] is float and dict[x] is Dictionary:
			return false
		return x < y)

	var used_keys := []

	for e in keys:
		var item: TreeItem

		if children_map.has(e):
			item = children_map[e]
		else:
			item = $Tree.create_item(parent)
			item.set_text(0, e)
			item.set_icon(0, title_to_icon(e))

		if dict[e] is float:
			item.set_text(1, _format_time(dict[e]))
		elif dict[e] is Dictionary:
			item.set_text(1, _format_time(get_aggregate_time.call(dict[e])))
			recursive_tree_build(dict[e], item, get_aggregate_time)

		used_keys.append(e)

	# Optionally remove children not in the updated data
	for key in children_map.keys():
		if not used_keys.has(key):
			children_map[key].free()

func title_to_icon(text):
	match text:
		"Total Time on Project": return gui.get_theme_icon("Time", "EditorIcons")
		"editing": return gui.get_theme_icon("3D", "EditorIcons")
		"control": return gui.get_theme_icon("Control", "EditorIcons")
		"node2D": return gui.get_theme_icon("Node2D", "EditorIcons")
		"node3D": return gui.get_theme_icon("Node3D", "EditorIcons")
		"object": return gui.get_theme_icon("Object", "EditorIcons")
		"script": return gui.get_theme_icon("Script", "EditorIcons")
		"playing": return gui.get_theme_icon("MainPlay", "EditorIcons")
		"outside": return gui.get_theme_icon("MakeFloating", "EditorIcons")
		"other": return gui.get_theme_icon("AssetLib", "EditorIcons")
		"unknown_node": return gui.get_theme_icon("ObjectDisabled", "EditorIcons")
		"unknown_file": return gui.get_theme_icon("File", "EditorIcons")
	return gui.get_theme_icon("Mouse", "EditorIcons")

func _format_time(t: float) -> String:
	var seconds = int(t) % 60
	var minutes = int(t) / 60 % 60
	var hours = int(t) / 3600 % 24
	var days = int(t) / 86400
	
	if days > 0:
		return "%sd %sh %sm %ss" % [days, hours, minutes, seconds]
	if hours > 0:
		return "%sh %sm %ss" % [hours, minutes, seconds]
	if minutes > 0:
		return "%sm %ss" % [minutes, seconds]
	return "%ss" % [int(t) % 60]
