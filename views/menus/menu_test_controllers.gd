extends Menu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for targetInput in range(PlayerInput.MAX_DEVICES):
		if PlayerInput.target_is_action_just_pressed("player_action1", targetInput):
			if not PlayerData.players.has(targetInput):
				PlayerData.register_player(targetInput)
			elif PlayerData.get_ready_status() != PlayerData.ALL_READY:
				PlayerData.players[targetInput].ready = true
			else :
				ui_manager.ui_show_main()
		if PlayerInput.target_is_action_just_pressed("player_action2", targetInput):
			if PlayerData.players.has(targetInput) and PlayerData.players[targetInput].ready:
				PlayerData.players[targetInput].ready = false
			elif PlayerData.get_active_players_num() != 0:
				PlayerData.remove_player(targetInput)
			else:
				ui_manager.ui_show_main()
		
		# Only process further input if player exists
		if not PlayerData.players.has(targetInput):
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
