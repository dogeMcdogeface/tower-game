extends TextureRect

var block_instance: Block

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_preview(bloc_resource:PackedScene) -> void:
	var block_parent = $SubViewport
	# Remove previous block if it exists
	if block_instance:
		block_instance.queue_free()

	if !bloc_resource: return
	block_instance = bloc_resource.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	block_instance.set_physics_process(false)
	block_parent.add_child(block_instance)

	var aabb = block_instance.get_combined_aabb()
	var s = 1.1 * max(aabb.size.x, aabb.size.y)
	#print("Block size:", aabb.size, " Viewport size:", s)

	$SubViewport.size = Vector2(s, s)
	block_instance.position = Vector2.ZERO  # or center as needed
