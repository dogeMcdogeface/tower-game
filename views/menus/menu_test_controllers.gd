extends Menu

var ControllerInfoScene = preload("res://ui_elements/controller_info_display.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MarginContainer/VBoxContainer/ScrollContainer/Control/ControllerInfoDisplay_keyboard.targetInput = PlayerInput.DEVICE_KEYBOARD_ID
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handleControllerInfo()
	handlePlayers()
	

@onready var ControllerInfo_container = $MarginContainer/VBoxContainer/ScrollContainer/Control/ControllerInfo_container
@onready var Label_controller_number = $MarginContainer/VBoxContainer/HBoxContainer/Label_controller_number
func handleControllerInfo():
	var controller_number = Input.get_connected_joypads().size()
	Label_controller_number.text = str(controller_number)
	while controller_number > ControllerInfo_container.get_children().size():
		var new_display = ControllerInfoScene.instantiate()
		new_display.targetInput = ControllerInfo_container.get_children().size()
		ControllerInfo_container.add_child(new_display)



func handlePlayers():
	for targetInput in range(PlayerInput.MAX_DEVICES):
		if PlayerInput.target_is_action_just_pressed("player_action1", targetInput):
			if not PlayerData.players.has(targetInput):
				PlayerData.register_player(targetInput)
			elif PlayerData.get_ready_status() != PlayerData.ALL_READY:
				PlayerData.players[targetInput].ready = true
			else :
				ui_manager.fsm_apply_transition("_close_with_players")
		if PlayerInput.target_is_action_just_pressed("player_action2", targetInput):
			if PlayerData.players.has(targetInput) and PlayerData.players[targetInput].ready:
				PlayerData.players[targetInput].ready = false
			elif PlayerData.get_active_players_num() != 0:
				PlayerData.remove_player(targetInput)
			else:
				ui_manager.fsm_apply_transition("_close_without_players")
		
		# Only process further input if player exists
		if not PlayerData.players.has(targetInput) or PlayerData.players[targetInput].ready:
			continue
		var player = PlayerData.players[targetInput]
		if PlayerInput.target_is_action_just_pressed("player_left", targetInput):
			player.titleIndex += 1
		if PlayerInput.target_is_action_just_pressed("player_right", targetInput):
			player.titleIndex -= 1
		if PlayerInput.target_is_action_just_pressed("player_left_dash", targetInput):
			player.termIndex += 1
		if PlayerInput.target_is_action_just_pressed("player_right_dash", targetInput):
			player.termIndex -= 1
		if PlayerInput.target_is_action_just_pressed("player_rotate", targetInput):
			player.colorIndex += 1
		if PlayerInput.target_is_action_just_pressed("player_down", targetInput):
			player.colorIndex -= 1
