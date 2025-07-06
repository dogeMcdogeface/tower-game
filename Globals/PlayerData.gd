extends Node

const MAX_PLAYERS = 4



const player_res = preload("res://Player.tres")
var players: Dictionary[int, Player] = {}
signal playerDataChanged()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Engine.get_frames_drawn() % 100:
		print(players)



func register_player(targetInput):
	if not players.has(targetInput):
		var new_player := Player.new(targetInput)
		players[targetInput] =  new_player
		print("Player registered. Total players: ", get_active_players_num())
	else:
		print("Player already registered.")
	playerDataChanged.emit()


func remove_player(targetInput):
	if players.has(targetInput):
		players.erase(targetInput)
		print("Player removed. Total players: ", get_active_players_num())
	else:
		print("Player not found.")
	playerDataChanged.emit()

func get_active_players_num() -> int:
	return players.size()
