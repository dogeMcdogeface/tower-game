extends Node

const MAX_DEVICES = 6
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
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	DEVICE_KEYBOARD_ID = MAX_DEVICES-1
	for action in actions:
		for i in range(MAX_DEVICES):
			InputMap.add_action(str(i)+action)
			tap_states[str(i) + action] = { "count": 0, "timer": 0.0, "resolved": false }



func _process(delta):
	return


func _on_joy_connection_changed(device: int, connected: bool):
	print("event ", device, " ", connected)



func _unhandled_input(event):
	if event is InputEventAction: return
	if event is InputEventKey:
		event.set_device(DEVICE_KEYBOARD_ID)

	for i in range(MAX_DEVICES):
		if event.device != i: continue
		for action in actions:
			var compound_action_name = (str(i)+action)
			var ev = InputEventAction.new()

			ev.action = compound_action_name
			ev.pressed = false
			if event.is_action_pressed(action, false, true):
				ev.pressed = true
			Input.parse_input_event(ev)



func target_is_action_just_pressed(action: String, targetInput:int) -> bool:
	return Input.is_action_just_pressed(str(targetInput)+action)
func target_is_action_pressed(action: String, targetInput:int) -> bool:
	return Input.is_action_pressed(str(targetInput)+action)
