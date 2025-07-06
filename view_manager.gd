# Node responsible for handling which view (menu or game screen) 
# is being displayed to the user, as well as the current state of 
# the application, direct inputs to the right target and so on
class_name ui_manager extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Program Starting")
	ui_show_main()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hide_views():
	for child in $views.get_children():
		if child.has_method("switch_away"):
			child.switch_away()
		else:
			child.hide()
			child.process_mode = Node.PROCESS_MODE_DISABLED

func show_view(child):
	hide_views()
	if child.has_method("switch_to"):
		child.switch_to()
	else:
		child.show()
		child.process_mode = Node.PROCESS_MODE_INHERIT


#################################################################

func ui_show_main() -> void:
	print("game settings")
	var view = $views/menu_main
	show_view(view)

func ui_show_game_setup() -> void:
	print("game begin")
	var view = $views/view_tower_builder
	show_view(view)



func ui_show_settings() -> void:
	print("game settings")
	var view = $views/menu_settings
	show_view(view)



func ui_show_testControllers() -> void:
	print("test controllers")
	var view = $views/menu_test_controllers
	show_view(view)


func exit_game() -> void:
	print("exit game")
	pass # Replace with function body.
