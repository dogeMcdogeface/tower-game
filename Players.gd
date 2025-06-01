extends Node

var max_players = 6
var DEVICE_KEYBOARD_ID


const TAP_RESOLVE_DELAY := 0.2  # Time to wait before triggering n-tap actions
var tap_states := {}

var actions = {
	"player_left" : 1,
	"player_left_dash": 2,
	"player_right": 1,
	"player_right_dash": 2,
	"player_down": 1,
	"player_rotate": 1,
	"player_action1": 1,
	"player_action2": 2
}

func _ready():

	DEVICE_KEYBOARD_ID = max_players-1
	for action in actions:
		for i in range(max_players):
			InputMap.add_action(str(i)+action)
			tap_states[str(i) + action] = { "count": 0, "timer": 0.0, "resolved": false }



func _process(delta):
	for i in range(max_players):
		for action in actions:
			var compound_action_name = (str(i)+action)
			var tap_count =  actions[action]
			var ev = InputEventAction.new()
			# Set as ui_left, pressed.
			ev.action = compound_action_name
			ev.pressed = false
			if detect_tap(compound_action_name, tap_count, delta):
				ev.pressed = true

			Input.parse_input_event(ev)


func _unhandled_input(event):
	if event is InputEventKey:
		event.set_device(DEVICE_KEYBOARD_ID)

	for i in range(max_players):
		if event.device != i: continue
		for action in actions:
			var compound_action_name = (str(i)+action)
			var tap_count =  actions[action]
			var state = tap_states[compound_action_name]
			
			if event.is_action_pressed(action):
				state.count += 1
				state.timer = 0.0
				state.resolved = false





func detect_tap(action_name: String, required_taps: int, delta: float) -> bool:
	var state = tap_states[action_name]
	# Increment timer
	state.timer += delta
	# Handle tap
	if state.count == required_taps and state.timer >= TAP_RESOLVE_DELAY and not state.resolved:
		state.resolved = true
		state.count = 0
		state.timer = 0.0
		return true
	if state.timer > TAP_RESOLVE_DELAY:
		state.count = 0
		state.timer = 0.0
		state.resolved = false
		return false
	return false
