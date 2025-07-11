# Node responsible for handling which view (menu or game screen) 
# is being displayed to the user, as well as the current state of 
# the application, direct inputs to the right target and so on
class_name ui_manager extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Program Starting")
	
	GameDirector._on_game_finished.connect(_on_game_finished)
	
	fsm_set_state("main")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hide_views():
	for child in $views.get_children():
		if child.has_method("switch_away"):
			child.switch_away()
		
		child.hide()
		child.process_mode = Node.PROCESS_MODE_DISABLED

func show_view(child):
	hide_views()
	if child.has_method("switch_to"):
		child.switch_to()

	child.show()
	child.process_mode = Node.PROCESS_MODE_INHERIT


#################################################################
## State Machine

var state
@onready var states = {
	"main": {
		"scene": $views/menu_main,
		"trans":{
			"_on_button_play_pressed_with_players": "tower_builder",
			"_on_button_play_pressed_without_players": "check_players_to_play",
			"_on_button_settings_pressed": "settings",
			"_on_button_test_controllers_pressed": "test_controller",
		}
	},
	"test_controller": {
		"scene": $views/menu_test_controllers,
		"trans":{
			"_close_with_players": "main",
			"_close_without_players": "main",
		}
	},
	"check_players_to_play": {
		"scene": $views/menu_test_controllers,
		"trans":{
			"_close_with_players": "tower_builder",
			"_close_without_players": "main",
		}
	},
	"tower_builder": {
		"scene": $views/view_tower_builder,
		"trans":{
			"_close": "main",
		}
	},
}

func fsm_apply_transition(trans:String, args = []):
	print("current state ", state, " Transition ", trans)
	if state not in states:
		print("Unknown state...")
		print("Resetting")
		if not fsm_set_state("main"):
			push_error("Fatal error: Can't find fallback UI state")
			#get_tree().quit(1)
		return false
	
	if trans not in states[state].trans:
		print("Unknown Transition...")
		return false
	
	
	fsm_set_state(states[state].trans[trans])

		
		
func fsm_set_state(newState):
	print("Changing to state ", newState)
	if newState not in states:
		print("Unknown state...")
		return false
	state = newState
	show_view(states[state].scene)
#################################################################

func _on_game_finished():
	fsm_apply_transition("_close")
	print("GAME FINISHEIRHIEHRI")

func exit_game() -> void:
	print("exit game")
	pass # Replace with function body.
