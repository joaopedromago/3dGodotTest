extends Node

class_name CameraService

var player: CharacterBody3D
var twist_pivot: Node3D
var pitch_pivot: Node3D
var player_mesh: Node3D
var twist_input := 0.0
var pitch_input := 0.0
var player_status: Dictionary


func _init(
	player_arg: CharacterBody3D,
	twist_pivot_arg: Node3D,
	pitch_pivot_arg: Node3D,
	player_mesh_arg: Node3D,
	player_status_arg: Dictionary
):
	player = player_arg
	twist_pivot = twist_pivot_arg
	pitch_pivot = pitch_pivot_arg
	player_mesh = player_mesh_arg
	player_status = player_status_arg


func process(delta: float):
	_handle_camera_input(delta)
	_update_camera_movement()
	_handle_lock_camera()
	_perform_look_at()


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

	twist_input = 0.0
	pitch_input = 0.0


func _handle_lock_camera():
	if Input.is_action_just_pressed("camera_lock"):
		if player_status.lock_at:
			player_status.lock_at.emit_signal("set_lock_off")
			player_status.lock_at = null
			player_status.is_locker_in = false
			return
		var enemies = player.get_tree().get_nodes_in_group("Enemies")
		var nearest_enemy: Node3D
		var nearest_enemy_distance: float = 25

		for enemy in enemies:
			var distance = enemy.position.distance_to(player.position)
			if nearest_enemy_distance > distance:
				nearest_enemy_distance = distance
				nearest_enemy = enemy

		if nearest_enemy:
			player_status.lock_at = nearest_enemy
			player_status.is_locker_in = true
			player_status.lock_at.emit_signal("set_lock_on")
			_set_camera_to_target()
		else:
			var player_rotation = player_mesh.rotation
			twist_pivot.rotation = Vector3(
				player_rotation.x,
				deg_to_rad(rad_to_deg(player_rotation.y) - 180),
				player_rotation.z
			)
			pitch_pivot.rotation = Vector3(deg_to_rad(-10), 0, 0)


func _set_camera_to_target():
	var direction = Utils.get_direction_to(player.position, player_status.lock_at.position)

	var player_rotation = player_mesh.rotation
	twist_pivot.rotation = Vector3(twist_pivot.rotation.x, direction, twist_pivot.rotation.z)
	pitch_pivot.rotation = Vector3(deg_to_rad(-10), 0, 0)


func _perform_look_at():
	if player_status.lock_at:
		var enemy_position = player_status.lock_at.get_node("TargetMesh").global_transform.origin
		player.look_at(Vector3(enemy_position.x, 0, enemy_position.z), Vector3.UP)
