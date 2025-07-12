extends Control

var target_input: int = -1

@onready var label_name = find_child("Label_name")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target_input == PlayerInput.DEVICE_KEYBOARD_ID:
		label_name.text = "KEYBOARD"
	else:
		label_name.text = Input.get_joy_name(target_input)
	pass
