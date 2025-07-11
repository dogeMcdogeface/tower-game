@tool
extends MarginContainer

var BuildVersionManager
var gui = EditorInterface.get_base_control()

func _ready():
	pass

func update(): 
	$VBoxContainer/HBoxContainer/Label_curr_version.text = BuildVersionManager.get_latest_version_string()
	$VBoxContainer/ScrollContainer/GridContainer/Label_date.text = _format_time_now()
	
	
	#Clear old rows
	var after_spacer = false
	for child in $VBoxContainer/ScrollContainer/GridContainer.get_children():
		if child.name == "Spacer":
			after_spacer = true
			continue
		elif !after_spacer: continue
		
		$VBoxContainer/ScrollContainer/GridContainer.remove_child(child)
		child.queue_free()
	
	#create new rows
	for i in BuildVersionManager.versions.size():
		var version = BuildVersionManager.versions[ BuildVersionManager.versions.size() -1 - i]
		var labels = create_version_labels(version)
		for label in labels:
			$VBoxContainer/ScrollContainer/GridContainer.add_child(label)
	
	pass


func create_version_labels(version: Dictionary) -> Array:
	var labels := []

	var major_label := Label.new()
	major_label.text = "%d" % version.get("major", 0)
	labels.append(major_label)

	var minor_label := Label.new()
	minor_label.text = "%d" % version.get("minor", 0)
	labels.append(minor_label)

	var sub_label := Label.new()
	sub_label.text = "%d" % version.get("sub", 0)
	labels.append(sub_label)

	var name_label := Label.new()
	name_label.text = "%s" % version.get("friendly_name", "Unnamed Version")
	labels.append(name_label)

	var timestamp := version.get("release_timestamp", Time.get_unix_time_from_system())
	var readable_time = BuildVersionManager.get_readable_time(timestamp)
	var time_label := Label.new()
	time_label.text = "%s" % readable_time
	labels.append(time_label)

	return labels

func _format_time_now() -> String:
	var now := Time.get_datetime_dict_from_system()
	var formatted := "%02d/%02d/%02d %02d:%02d" % [
		now.day, now.month, now.year % 100, now.hour, now.minute
	]
	return formatted


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


func _on_button_major_pressed() -> void:
	BuildVersionManager.increment_version("major", $VBoxContainer/ScrollContainer/GridContainer/LineEdit_friendly.text)  
	$VBoxContainer/ScrollContainer/GridContainer/LineEdit_friendly.text = ""


func _on_button_minor_pressed() -> void:
	BuildVersionManager.increment_version("minor", $VBoxContainer/ScrollContainer/GridContainer/LineEdit_friendly.text)  
	$VBoxContainer/ScrollContainer/GridContainer/LineEdit_friendly.text = ""


func _on_button_sub_pressed() -> void:
	BuildVersionManager.increment_version("sub", $VBoxContainer/ScrollContainer/GridContainer/LineEdit_friendly.text)  
	$VBoxContainer/ScrollContainer/GridContainer/LineEdit_friendly.text = ""


func _on_button_reset_pressed() -> void:
	BuildVersionManager.resetVersionHistory()
	pass # Replace with function body.
