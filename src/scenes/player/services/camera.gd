extends Node

class_name CameraService

var player: CharacterBody3D
var twist_pivot: Node3D
var pitch_pivot: Node3D
var body_mesh: MeshInstance3D
var shader_service
var twist_input := 0.0
var pitch_input := 0.0


func _init(
	player_arg: CharacterBody3D,
	twist_pivot_arg: Node3D,
	pitch_pivot_arg: Node3D,
	body_mesh_arg: MeshInstance3D,
	shader_service_arg
):
	player = player_arg
	twist_pivot = twist_pivot_arg
	pitch_pivot = pitch_pivot_arg
	body_mesh = body_mesh_arg
	shader_service = shader_service_arg


func process(delta: float):
	_handle_camera_input(delta)
	_update_camera_movement()


func handle_mouse_motion_input(event: InputEvent):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		twist_input = -event.relative.x * Application.mouse_sensitivity
		pitch_input = -event.relative.y * Application.mouse_sensitivity


func _handle_camera_input(delta: float):
	var input_vector = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if input_vector.x != 0 or input_vector.y != 0:
		twist_input = -input_vector.x * Application.joystick_camera_sensitivity * delta
		pitch_input = -input_vector.y * Application.joystick_camera_sensitivity * delta


func _update_camera_movement():
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,
		deg_to_rad(Application.min_camera_angle_x),
		deg_to_rad(Application.max_camera_angle_x)
	)

	var current_x_angle = rad_to_deg(pitch_pivot.rotation.x)

	if current_x_angle > Application.max_camera_angle_x - 10:
		shader_service.change_mesh_opacity(0.15)
	else:
		shader_service.change_mesh_opacity(1.0)

	twist_input = 0.0
	pitch_input = 0.0
