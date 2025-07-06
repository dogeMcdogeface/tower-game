extends Control




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for targetInput in range(PlayerInput.MAX_DEVICES):
		if PlayerInput.target_is_action_just_pressed("player_action1", targetInput):
			PlayerData.register_player(targetInput)
		if PlayerInput.target_is_action_just_pressed("player_action2", targetInput):
			PlayerData.remove_player(targetInput)
		
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
