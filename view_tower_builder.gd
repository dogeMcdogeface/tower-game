extends Menu


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
		print("No players")
	else:
		show_player_viewport(playerNum)

var max_rows:int = 4
func show_player_viewport(num):
	var children = $GridContainer.get_children()
	var player_list = PlayerData.players.values()

	var rows = 1
	if num <= max_rows:
		$GridContainer.columns = num
	else:
		$GridContainer.columns = ceil( num / 2.0)
		rows = num /  (num / 2.0)
	print(num, "using rows ", $GridContainer.columns, " rows ",rows)

	
	for i in children.size():
		var child:TextureRect = children[i]

		child.visible = i < num
		
		var s = get_viewport_rect().size
		s.x /= $GridContainer.columns
		s.y /= rows
		


			
		if i < player_list.size():
			child.process_mode = Node.PROCESS_MODE_INHERIT
			child.propagate_call("set", ["assigned_player", player_list[i]])
			

			if rows == 1 and s.x > s.y:
				print("mode 1")
				child.expand_mode = TextureRect.EXPAND_FIT_WIDTH
				child.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			elif rows == 1 and s.x <= s.y:
				print("mode 2")
				child.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
				child.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			elif rows == 2 and s.x > s.y:
				print("mode 3")
				child.expand_mode = TextureRect.EXPAND_FIT_WIDTH
				child.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			elif rows == 2 and s.x <= s.y:
				print("mode 4")
				child.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
				child.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			else:
				print("Error generating view_tower_builder layout")

			
			print("Container size ", s, " ", child.expand_mode, " ", child.stretch_mode)
			print(num, "using rows ", $GridContainer.columns, " rows ",rows)






		else:
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.propagate_call("set", ["assigned_player", null])
	

		


func switch_to():
	print("switching to game view")
	GameDirector.start_game()
	
