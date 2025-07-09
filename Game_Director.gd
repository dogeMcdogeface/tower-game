extends Node

const block_size = 32

var block_pools := {
	"easy": [
		preload("res://blocks/block_O.tscn"),
		preload("res://blocks/block_L1.tscn"),
		preload("res://blocks/block_L2.tscn"),
		preload("res://blocks/block_I.tscn"),
		preload("res://blocks/block_S1.tscn"),
		preload("res://blocks/block_S2.tscn"),
		preload("res://blocks/block_T.tscn"),
	],
	"medium": [
		preload("res://blocks/block_L1.tscn"),
	],
	"hard": [
		preload("res://blocks/block_S2.tscn"),
	]
}

var current_block_pool = "easy"
var current_block_list_length = 50
var current_block_list = []


func generate_block_list():
	current_block_list.clear()
	var pool = block_pools.get(current_block_pool, [])
	if pool.is_empty():
		push_warning("Block pool '%s' is empty!" % current_block_pool)
		return
	for i in current_block_list_length:
		var random_scene: PackedScene = pool[randi() % pool.size()]
		current_block_list.append(random_scene)


func _ready() -> void:
	randomize()
	generate_block_list()


signal _on_game_finished
signal _on_round_finished

func _on_player_game_finished(_player:Player):
	var not_finished = false
	for player:Player in PlayerData.players.values():
		not_finished = not_finished or player.game_in_progress
	
	if !not_finished:
		await get_tree().create_timer(5).timeout
		print("All Players Finished")
		_on_round_finished.emit()
		_on_game_finished.emit()

	pass
