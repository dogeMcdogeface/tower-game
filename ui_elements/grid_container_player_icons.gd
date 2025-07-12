extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("Children size ", get_children().size() )
	while get_children().size() < PlayerData.MAX_PLAYERS:
		var newPlayerIcon = $PlayerIconContainer.duplicate()
		self.add_child(newPlayerIcon)
	#print("Children size ", get_children().size() )
	PlayerData.playerDataChanged.connect(_player_data_updated)
	_player_data_updated()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _player_data_updated():
	var playerNum =  PlayerData.get_active_players_num()
	if playerNum == 0:
		show_player_icon(PlayerData.MAX_PLAYERS)
	else:
		show_player_icon(playerNum)
		

func show_player_icon(num):
	columns = num
	var children = get_children()
	var player_list = PlayerData.players.values()
	
	for i in children.size():
		var child = children[i]
		child.visible = i < num
		
		if i < player_list.size():
			child.assigned_player = player_list[i]
		else:
			child.assigned_player = null

	
