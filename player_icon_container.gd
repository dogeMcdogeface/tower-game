extends MarginContainer

var assignedPlayer:Player


@onready var player_actions = {
	"player_left": $HBoxContainer/GridContainer/Button1,
	"player_left_dash": $HBoxContainer/GridContainer/Button2,
	"player_right": $HBoxContainer/GridContainer/Button3,
	"player_right_dash": $HBoxContainer/GridContainer/Button4,
	"player_rotate": $HBoxContainer/GridContainer/Button5,
	"player_down": $HBoxContainer/GridContainer/Button6,
	"player_action1": $HBoxContainer/GridContainer/Button7,
	"player_action2": $HBoxContainer/GridContainer/Button8,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !assignedPlayer:
		modulate = Color(0.463, 0.463, 0.463)
		$background.modulate= 0
		$HBoxContainer/VBoxContainer/Label_name.text = ""
		$HBoxContainer/VBoxContainer/Label_controller.text = ""
		$HBoxContainer/Icon_ready_no.hide()
		$HBoxContainer/Icon_ready_yes.hide()
		return
	
	var targetInput = assignedPlayer.targetInput
	modulate = Color.WHITE
	if assignedPlayer.ready:
		$background.modulate = assignedPlayer.color
		$HBoxContainer/Icon_ready_no.hide()
		$HBoxContainer/Icon_ready_yes.show()
	else:
		$background.modulate = 0
		$HBoxContainer/Icon_ready_no.show()
		$HBoxContainer/Icon_ready_yes.hide()
		
	$HBoxContainer/VBoxContainer/Label_name.text = assignedPlayer.name
	
	if (targetInput == PlayerInput.DEVICE_KEYBOARD_ID):
		$HBoxContainer/VBoxContainer/Label_controller.text = "keyboard"
	else:
		$HBoxContainer/VBoxContainer/Label_controller.text = Input.get_joy_name(targetInput)
	
	for action in player_actions:
		player_actions[action].button_pressed = PlayerInput.target_is_action_pressed(action, targetInput)
