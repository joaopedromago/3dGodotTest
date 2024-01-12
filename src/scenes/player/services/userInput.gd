extends Node

class_name UserInputService


func process():
	_handle_mouse_mode()


func _handle_mouse_mode():
	if Input.is_action_just_pressed("change_camera_mode"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
