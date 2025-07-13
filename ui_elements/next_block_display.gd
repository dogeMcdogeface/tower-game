extends Control


var assigned_tower_builder:TowerBuilder
var assigned_player: Player

@onready var Label_count: Label = find_child("Label_count")
@onready var scroll_container:ScrollContainer = find_child("ScrollContainer")
@onready var icons = [
	find_child("block_display"),
	find_child("block_display2"),
	find_child("block_display3"),
	find_child("block_display4"),
	find_child("block_display5"),
	]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var last_block_list_size = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !assigned_player: return
	if !assigned_tower_builder:get_tower_builder_for_player()

	Label_count.text = str(assigned_tower_builder.block_list.size())

	if(last_block_list_size != assigned_tower_builder.block_list.size()):
		last_block_list_size = assigned_tower_builder.block_list.size()
		animate_icons()


func animate_icons():
	# Animate scroll from current to second element
	if icons.size() >= 2:
		var from_scroll = icons[0].position.y
		var to_scroll = icons[1].position.y 
		var tween := get_tree().create_tween()
		tween.tween_property(
			scroll_container,
			"scroll_vertical", 
			to_scroll,
			0.5
			).from(from_scroll).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

		# Wait for the tween to finish
		await tween.finished
		scroll_container.scroll_vertical = 0

	# Update icon previews
	for i in icons.size():
		var block_index := -1 * (i + 1)
		var block = null
		if abs(block_index) <= assigned_tower_builder.block_list.size():
			block = assigned_tower_builder.block_list[block_index]
		icons[i].set_preview(block)

		
		
func get_tower_builder_for_player():
	for tb in get_tree().get_nodes_in_group("tower_builders"):
		if tb.assigned_player == assigned_player:
			assigned_tower_builder = tb
			return
	assigned_tower_builder = null
