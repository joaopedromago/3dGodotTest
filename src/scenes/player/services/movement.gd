extends Node

class_name MovementService

var animation_service: AnimationService

var player: CharacterBody3D
var twist_pivot: Node3D
var pitch_pivot: Node3D
var player_mesh: Node3D
var has_double_jump := false
var is_running := false
var speed: float
var running_timer: Timer


func _init(
	player_arg: CharacterBody3D,
	twist_pivot_arg: Node3D,
	pitch_pivot_arg: Node3D,
	player_mesh_arg: Node3D,
	animation_service_arg: AnimationService
):
	player = player_arg
	twist_pivot = twist_pivot_arg
	pitch_pivot = pitch_pivot_arg
	player_mesh = player_mesh_arg

	animation_service = animation_service_arg

	running_timer = Timer.new()

	speed = Application.speed


func process(delta: float):
	_handle_run_dodge()
	_handle_movement(delta)
	_handle_jump()
	_change_character_direction(delta)


# TODO: add climb feature
# TODO: add crouch feature with R analog click
# TODO: jumping while crouch is higher than jumping while standing


func _handle_run_dodge():
	if Input.is_action_pressed("run_dodge") and !is_running:
		running_timer.start(311111.0)
		is_running = true
		speed = speed * 1.5
	if Input.is_action_just_released("run_dodge"):
		var a = running_timer.time_left
		running_timer.stop()
		print("stop", a)
		is_running = false
		speed = Application.speed


func _perform_dodge():
	print("rolling")
	#animation_service.roll()


func _handle_movement(delta: float):
	var variations = speed * delta

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

	var angle_rad = atan2(input_vector.x, input_vector.y)
	var is_on_floor = player.is_on_floor()

	if input_vector.x != 0 or input_vector.y != 0:
		if is_running and is_on_floor:
			animation_service.run_forward()
		elif is_on_floor:
			animation_service.walk_forward()
		player_mesh.set_basis(looking_direction)
		player_mesh.rotate_y(angle_rad)
	elif is_on_floor:
		animation_service.idle()


func _handle_jump():
	if Input.is_action_just_pressed("jump"):
		if not player.is_on_floor() and not has_double_jump:
			return
		if player.is_on_floor():
			has_double_jump = true
			_perform_jump(Application.jump_strength)
		elif has_double_jump == true:
			has_double_jump = false
			_perform_jump(Application.jump_strength / 2)


func _perform_jump(velocity: float):
	animation_service.jump_then_fall()
	player.velocity.y = velocity
