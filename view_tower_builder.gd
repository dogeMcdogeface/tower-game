extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("Children size ", get_children().size() )
	while $GridContainer.get_children().size() < PlayerData.MAX_PLAYERS:
		var newViewport = $GridContainer/Viewport_Tower_Builder.duplicate()
		$GridContainer.add_child(newViewport)
		push_warning("Using more players than intended. If something breaks look here (view_tower_builder)")
	#print("Children size ", get_children().size() )
	PlayerData.playerDataChanged.connect(_player_data_updated)
	_player_data_updated()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _player_data_updated():
	var playerNum =  PlayerData.get_active_players_num()
	if playerNum == 0:
		print("No players??")
	else:
		show_player_viewport(playerNum)


func show_player_viewport(num):
	$GridContainer.columns = num
	var children = $GridContainer.get_children()
	var player_list = PlayerData.players.values()
	
	for i in children.size():
		var child = children[i]

		child.visible = i < num
		
		if i < player_list.size():
			child.process_mode = Node.PROCESS_MODE_INHERIT
			child.get_node("SubViewport/tower_builder").assignedPlayer = player_list[i]
		else:
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.get_node("SubViewport/tower_builder").assignedPlayer = null
