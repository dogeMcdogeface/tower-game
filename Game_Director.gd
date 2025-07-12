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
	],
	"debugO": [
		preload("res://blocks/block_O_mega.tscn"),
	]
}

var current_block_pool = "easy"
var current_block_list_length = 50
var current_block_list = []


var game_active = false
var round_active = false


func generate_block_list():
	randomize()
	current_block_list.clear()
	var pool = block_pools.get(current_block_pool, [])
	if pool.is_empty():
		push_warning("Block pool '%s' is empty!" % current_block_pool)
		return
	for i in current_block_list_length:
		var random_scene: PackedScene = pool[randi() % pool.size()]
		current_block_list.append(random_scene)


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if !game_active: return
	if Engine.get_frames_drawn() % 10 != 0: return
	
	update_round_status()



signal _on_round_start
signal _on_round_finish
signal _on_game_start
signal _on_game_finish


func start_game():
	print("Game director starting")
	game_active = true
	start_round()



func start_round():
	generate_block_list()
	round_active = true
	for tower_builder in  get_active_tower_builders():
		tower_builder.start_round(current_block_list.duplicate())


func get_active_tower_builders() -> Array:
	return get_tree().get_nodes_in_group("tower_builders").filter(
		func(tb): return tb.assignedPlayer != null
	)


func update_round_status():
	if !round_active: return
	var finished = true
	
	for tower_builder in  get_active_tower_builders():
		finished = finished and tower_builder.block_list.is_empty()
	
	#Logic to actually determine if the round has finished depending on game mode
	if finished:
		round_active = false
		await get_tree().create_timer(5).timeout
		print("All Players Finished")
		_on_round_finish.emit()
		_on_game_finish.emit()
