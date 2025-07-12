class_name TowerBuilder extends Node2D

var _assigned_player: Player
var target_input = -1
var assigned_player: Player:
	set(value):
		_assigned_player = value
		if value:
			target_input = value.target_input
		else:
			target_input = null
	get:
		return _assigned_player



var round_active = true
@onready var blockNode = $Blocks
var active_block:RigidBody2D = null
@export var fall_speed = 10

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
	pass





func spawn_block():
	if block_list.is_empty():
		stop_game()
		return
	var res = block_list.pop_back()
	var block:Block = res.instantiate()
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
