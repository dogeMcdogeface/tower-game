class_name TowerBuilder extends Node2D

#var _assigned_player: Player
var target_input = -1
var assigned_player: Player:
	set(value):
		assigned_player = value
		if value:
			target_input = value.target_input
		else:
			target_input = null
	get:
		return assigned_player



var round_active = true
@onready var blockNode = $Blocks
var active_block:RigidBody2D = null
@export var fall_speed = 10

var tower_aabb:Rect2
var level_aabb:Rect2

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	pass


func _process(delta: float) -> void:
	if(!round_active):return

	if(active_block == null):
		var block = spawn_block()
		if(block):
			block.set_controlled(true)
			active_block = block
	elif active_block.hasCollided:
		active_block.set_controlled(false)
		active_block = null
	#else
		#control_block()
	#if(Engine.get_frames_drawn() % 10 == 0):
	update_tower_aabb()
	
	update_camera()


func update_tower_aabb():
	tower_aabb = get_combined_aabb()
	$tower_aabb.position = tower_aabb.get_center()
	$tower_aabb.scale.x = tower_aabb.size.x/100
	$tower_aabb.scale.y = tower_aabb.size.y/100

	var min_bounds:Rect2 = $min_aabb/CollisionShape2D.shape.get_rect()
	var max_x = min(min_bounds.position.x, tower_aabb.position.x)
	var max_y = min(min_bounds.get_center().y, tower_aabb.position.y)

	level_aabb.position.x = max_x
	level_aabb.position.y = max_y
	
	$block_spawner.global_position.y = max_y - min_bounds.size.y /2
	var camera_y = min( min_bounds.get_center().y, tower_aabb.position.y)
	if active_block:
		camera_y = min(camera_y, active_block.position.y+ get_viewport_rect().size.y /2)
	$Camera2D.global_position.y = camera_y 
	$debug_view_rect.position.y =min( min_bounds.get_center().y, tower_aabb.position.y)
	$debug_view_rect.scale.x = 0.01 * get_viewport_rect().size.x
	$debug_view_rect.scale.y = 0.01 * get_viewport_rect().size.y
	
	get_viewport().size.y = max(get_parent().get_parent().size.y, min_bounds.size.y)
	get_viewport().size.x = max(get_parent().get_parent().size.x, min_bounds.size.x)


func update_camera():
	pass
	#print(level_aabb, $Camera2D.get_viewport().get_visible_rect())
	

	#	$Camera2D.position.y = min()

func spawn_block():
	if block_list.is_empty():
		stop_game()
		return
	var res = block_list.pop_back()
	var block:Block = res.instantiate()
	update_tower_aabb()
	block.global_position = $block_spawner.global_position
	block.assigned_player = assigned_player
	blockNode.add_child(block)
	return block



var block_list = []
func start_round(_block_list):
	for block in blockNode.get_children():
		block.queue_free()
	block_list = _block_list
	round_active = true

func stop_game():
	round_active = false

func _physics_process(delta):
	if active_block == null:
		return

	var final_fall_speed = fall_speed

	# Define movement map: action name -> pixel offset
	var move_actions := {
		"player_left": -GameDirector.block_size * 0.5,
		"player_left_dash": -GameDirector.block_size ,
		"player_right": GameDirector.block_size* 0.5,
		"player_right_dash": GameDirector.block_size,
	}

	for action in move_actions.keys():
		if PlayerInput.target_is_action_just_pressed(action, target_input):
			var current_transform = PhysicsServer2D.body_get_state(
				active_block.get_rid(),
				PhysicsServer2D.BODY_STATE_TRANSFORM
			)
			var new_transform = current_transform.translated(Vector2(move_actions[action], 0))
			PhysicsServer2D.body_set_state(
				active_block.get_rid(),
				PhysicsServer2D.BODY_STATE_TRANSFORM,
				new_transform
			)
			#print(target_input, action)


# Handle rotation
	if PlayerInput.target_is_action_just_pressed("player_rotate", target_input):
		var current_transform = PhysicsServer2D.body_get_state(
			active_block.get_rid(),
			PhysicsServer2D.BODY_STATE_TRANSFORM
		)

		# Rotate 90 degrees clockwise (use -PI/2 for counter-clockwise)
		var angle := deg_to_rad(90)
		var rotated_transform = current_transform.rotated(angle)

		var center = current_transform.origin
		rotated_transform = current_transform.translated(-center).rotated(angle).translated(center)


		# Optional: round position to avoid subpixel drift
		rotated_transform.origin = rotated_transform.origin.round()

		PhysicsServer2D.body_set_state(
			active_block.get_rid(),
			PhysicsServer2D.BODY_STATE_TRANSFORM,
			rotated_transform
		)
		#print(target_input, "player_rotate")
	if PlayerInput.target_is_action_pressed("player_down", target_input):
		final_fall_speed = fall_speed * 2
		#print(target_input, "player_down")
	if PlayerInput.target_is_action_just_pressed("player_action1", target_input):
		print(target_input, "player_action1")
	if PlayerInput.target_is_action_just_pressed("player_action2", target_input):
		print(target_input, "player_action2")

	# Constant falling
	active_block.set_axis_velocity(Vector2.DOWN * final_fall_speed )



func get_combined_aabb() -> Rect2:
	var aabb: Rect2
	var first_shape := true

	for child in $Blocks.get_children():
		if child is Block and not child.is_controlled:
			var shape_aabb = child.get_combined_aabb()
			# Transform the shape AABB to global position
			if first_shape:
				aabb = shape_aabb
				first_shape = false
			else:
				aabb = aabb.merge(shape_aabb)
	return aabb
