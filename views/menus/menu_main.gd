extends Menu

func _on_button_play_pressed() -> void:
	ui_manager.ui_show_game_setup()

func _on_button_settings_pressed() -> void:
	ui_manager.ui_show_settings()

func _on_button_test_controllers_pressed() -> void:
	ui_manager.ui_show_testControllers()

func _on_button_quit_pressed() -> void:
	ui_manager.exit_game()



func switch_to():
	$MarginContainer/HBoxContainer/CenterContainer/VBoxContainer/Button_play.grab_focus()
