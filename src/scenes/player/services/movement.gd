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
var is_falling := false
var is_crouching := false
var running_timer := 0
var last_fall_speed := 0.0
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
	_handle_fall()
	_handle_crouch()
	_animate_character_on_move(delta)



# TODO: add climb feature

func _handle_crouch():
	# TODO: add crouch feature
	if _is_on_action():
		return
	
	if Input.is_action_just_pressed("crouch") and (not _is_running()):
		is_crouching = !is_crouching
		if is_crouching:
			# fix hitbox
			pass
		else:
			# revert hitbox
			pass

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


func _handle_movement(delta: float):
	if _is_on_action() or is_falling:
		return

	var variations = speed * delta

	var input_vector = (
		Input.get_vector("move_left", "move_right", "move_forward", "move_back") * variations
	)

	player.velocity = (
		twist_pivot.global_transform.basis
		* Vector3(input_vector[0], player.velocity.y, input_vector[1])
	)


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


func _handle_fall():
	var fall_speed = player.velocity.y * -1
	if fall_speed > 5:
		is_falling = true
		animation_service.perform_fall()
	else:
		is_falling = false

	if is_falling:
		last_fall_speed = clampf(fall_speed, fall_speed, Application.gravity * 10)
	elif last_fall_speed > 0:
		print("Falled from ", last_fall_speed)
		last_fall_speed = 0
		_perform_roll()


func _animate_character_on_move(delta: float):
	var looking_direction = twist_pivot.basis

	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var angle_rad = atan2(input_vector.x, input_vector.y)

	if (input_vector.x != 0 or input_vector.y != 0) and (not _is_on_action() or is_falling):
		if _is_running() and not is_falling:
			animation_service.run_forward()
		elif not is_falling:
			animation_service.walk_forward()
		player_mesh.set_basis(looking_direction)
		player_mesh.rotate_y(angle_rad)
	elif not _is_on_action():
		animation_service.idle()


func _change_speed(new_speed: float, over_limit := false):
	if over_limit:
		speed = new_speed
	else:
		speed = clampf(new_speed, Application.speed, Application.running_speed)


func _perform_jump(velocity: float):
	is_jumping = true
	player.velocity.y = velocity


func _is_running():
	return speed > Application.speed


func _is_on_action():
	return is_jumping or is_rolling or is_falling


func _perform_roll():
	print("triggered")
	if player.velocity.x == 0 and player.velocity.z == 0:
		return
	print("rolled")

	is_rolling = true
	_change_speed(Application.rolling_speed)
	animation_service.perform_roll()


func _stop_roll():
	is_rolling = false
	_change_speed(Application.speed)
