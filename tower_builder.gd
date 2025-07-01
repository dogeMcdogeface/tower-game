extends Node2D

@export var targetInput = 0

var game_active = true

@onready var blockNode = $Blocks
var active_block:RigidBody2D = null
@export var fall_speed = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	pass


func _process(delta: float) -> void:
	
	if(!game_active):return
	
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
	pass



var block_index = 0
func spawn_block():
	if(block_index >= GameDirector.current_block_list_length):
		game_active = false
		return
	var block = (GameDirector.current_block_list[block_index]).instantiate()
	block_index += 1
	blockNode.add_child(block)
	return block




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
		if target_is_action_just_pressed(action):
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
			print(targetInput, action)


# Handle rotation
	if target_is_action_just_pressed("player_rotate"):
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
		print(targetInput, "player_rotate")


	if target_is_action_pressed("player_down"):
		final_fall_speed = fall_speed * 2
		print(targetInput, "player_down")
	if target_is_action_just_pressed("player_action1"):
		print(targetInput, "player_action1")
	if target_is_action_just_pressed("player_action2"):
		print(targetInput, "player_action2")

	# Constant falling
	active_block.set_axis_velocity(Vector2.DOWN * final_fall_speed )


func target_is_action_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed(str(targetInput)+action)
func target_is_action_pressed(action: String) -> bool:
	return Input.is_action_pressed(str(targetInput)+action)
