extends RigidBody2D

var hasCollided = false
var is_controlled =false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(is_controlled):

		var aabb = get_combined_aabb()
		$Trail.mesh.size.x = aabb.size.x
		$Trail.global_position = aabb.get_center()


	if get_colliding_bodies().size() > 0:
		hasCollided = true
		#print(get_colliding_bodies())
		for collider in get_colliding_bodies():
			if collider.has_meta("WorldBorder"):
				die()
	pass

func die():
	queue_free()


func set_controlled(controlled:bool):
	is_controlled = controlled
	$Trail.visible = is_controlled
	
	if (is_controlled):
		gravity_scale = 0
	else:
		gravity_scale = 0.5
		set_axis_velocity(Vector2.ZERO)


func get_combined_aabb() -> Rect2:
	var aabb: Rect2
	var first_shape := true

	for child in get_children():
		if child is CollisionShape2D:
			var shape = child.shape
			if shape:
				var shape_aabb = shape.get_rect()
				# Transform the shape AABB to global position
				shape_aabb.position = child.global_position + shape_aabb.position.rotated(child.rotation)
				if first_shape:
					aabb = shape_aabb
					first_shape = false
				else:
					aabb = aabb.merge(shape_aabb)

	return aabb
