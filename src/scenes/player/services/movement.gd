extends Node

class_name MovementService

var player: CharacterBody3D
var twist_pivot: Node3D
var pitch_pivot: Node3D
var body_mesh: MeshInstance3D
var has_double_jump := false


func _init(
	player_arg: CharacterBody3D,
	twist_pivot_arg: Node3D,
	pitch_pivot_arg: Node3D,
	body_mesh_arg: MeshInstance3D
):
	player = player_arg
	twist_pivot = twist_pivot_arg
	pitch_pivot = pitch_pivot_arg
	body_mesh = body_mesh_arg


func process(delta: float):
	_perform_character_movement(delta)
	_change_character_direction(delta)
	_perform_jump()


func _perform_character_movement(delta: float):
	var variations = Application.speed * delta

	var input_vector = (
		Input.get_vector("move_left", "move_right", "move_forward", "move_back") * variations
	)

	player.velocity = (
		twist_pivot.global_transform.basis
		* Vector3(input_vector[0], player.velocity.y, input_vector[1])
	)


func _change_character_direction(delta: float):
	var looking_direction = twist_pivot.basis

	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var angle_rad = atan2(input_vector.x * -1, input_vector.y * -1)

	if input_vector.x != 0 or input_vector.y != 0:
		body_mesh.set_basis(looking_direction)
		body_mesh.rotate_y(angle_rad)


func _perform_jump():
	if Input.is_action_just_pressed("jump"):
		if not player.is_on_floor() and not has_double_jump:
			return
		if player.is_on_floor():
			has_double_jump = true
		elif has_double_jump == true:
			has_double_jump = false
		player.velocity.y = Application.jump_strength
