extends Node

class_name MovementService

var animation_service: AnimationService

var player: CharacterBody3D
var twist_pivot: Node3D
var pitch_pivot: Node3D
var player_mesh: Node3D
var has_double_jump := false
var is_jumping := false
var is_rolling := false
var running_timer := 0
var speed: float

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

	speed = Application.speed


func process(delta: float):
	_handle_run(delta)
	_handle_movement(delta)
	_handle_jump_landing()
	_handle_jump()
	_animate_character_on_move(delta)


# TODO: add climb feature
# TODO: add crouch feature with R analog click
# TODO: jumping while crouch is higher than jumping while standing

func _handle_run(delta: float):
	if is_rolling and not animation_service.is_on_animation():
			_stop_roll()
	if _is_on_action():
		return
	if Input.is_action_pressed("run_dodge"):
		running_timer += 1
		_change_speed(Application.running_speed)
	if Input.is_action_just_released("run_dodge"):
		var time_running = running_timer * delta
		_change_speed(Application.speed)
		if time_running < 0.2:
			_perform_roll()
		running_timer = 0
		
func _change_speed(new_speed: float, over_limit := false):
	if over_limit:
		speed = new_speed
	else:
		speed = clampf(new_speed, Application.speed, Application.running_speed)
	
	
func _handle_movement(delta: float):
	if _is_on_action():
		return
		
	var variations = speed * delta

	var input_vector = (
		Input.get_vector("move_left", "move_right", "move_forward", "move_back") * variations
	)

	player.velocity = (
		twist_pivot.global_transform.basis
		* Vector3(input_vector[0], player.velocity.y, input_vector[1])
	)


func _animate_character_on_move(delta: float):
	var looking_direction = twist_pivot.basis

	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var angle_rad = atan2(input_vector.x, input_vector.y)

	if (input_vector.x != 0 or input_vector.y != 0) and not _is_on_action():
		if _is_running():
			animation_service.run_forward()
		else:
			animation_service.walk_forward()
		player_mesh.set_basis(looking_direction)
		player_mesh.rotate_y(angle_rad)
	elif not _is_on_action():
		animation_service.idle()

func _handle_jump():
	if Input.is_action_just_pressed("jump"):
		if not player.is_on_floor() and not has_double_jump:
			return
		if player.is_on_floor():
			has_double_jump = true
			animation_service.jump()
			_perform_jump(Application.jump_strength)
		elif has_double_jump == true:
			has_double_jump = false
			animation_service.perform_roll()
			_perform_jump(Application.jump_strength / 2)

func _handle_jump_landing():
	if player.get_slide_collision_count() > 0 and player.is_on_floor() and _is_on_action():
		is_jumping = false
		has_double_jump = false	
		speed = Application.running_speed
		
func _perform_jump(velocity: float):
	is_jumping = true
	player.velocity.y = velocity

func _is_running():
	return speed > Application.speed

func _is_on_action():
	return is_jumping or is_rolling

func _perform_roll():
	if player.velocity.x == 0 and player.velocity.z == 0:
		return
		 
	is_rolling = true
	_change_speed(Application.rolling_speed)
	animation_service.perform_roll()

func _stop_roll():
	is_rolling = false
	_change_speed(Application.speed)
