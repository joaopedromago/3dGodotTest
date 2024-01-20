extends Node

class_name MovementService

var animation_service: AnimationService

var player: CharacterBody3D
var twist_pivot: Node3D
var pitch_pivot: Node3D
var player_mesh: Node3D
var running_timer := 0
var last_fall_speed := 0.0
var speed: float
var player_status: Dictionary


func _init(
	player_arg: CharacterBody3D,
	twist_pivot_arg: Node3D,
	pitch_pivot_arg: Node3D,
	player_mesh_arg: Node3D,
	animation_service_arg: AnimationService,
	player_status_arg: Dictionary
):
	player = player_arg
	twist_pivot = twist_pivot_arg
	pitch_pivot = pitch_pivot_arg
	player_mesh = player_mesh_arg
	player_status = player_status_arg

	animation_service = animation_service_arg

	speed = Application.speed


func process(delta: float):
	_handle_jump_landing()
	_handle_jump()
	_handle_fall()
	_handle_crouch()
	_animate_character_on_move()

func physics_process(delta):
	_handle_run(delta)
	_handle_movement(delta)

func _handle_crouch():
	if _is_on_action() and !_is_running():
		return

	if Input.is_action_just_pressed("crouch") and (not _is_running()):
		player_status.is_crouching = !player_status.is_crouching
		print()
		if player_status.is_crouching:
			player.get_node("Shape").position.y = player.get_node("Shape").position.y / 2
			player.get_node("Shape").scale.y = player.get_node("Shape").scale.y / 2
			pass
		else:
			player.get_node("Shape").position.y = 0.75
			player.get_node("Shape").scale.y = 1
			pass


func _handle_run(delta: float):
	if player_status.is_rolling and not animation_service.is_on_animation():
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
	if _is_on_action() or player_status.is_falling:
		return

	var variations = speed * delta

	var input_vector = (
		Input.get_vector("move_left", "move_right", "move_forward", "move_back") * variations
	)

	var move_direction

	move_direction = twist_pivot.global_transform.basis

	player.velocity = (
		move_direction * Vector3(input_vector[0], player.velocity.y, input_vector[1])
	)


func _handle_jump():
	if Input.is_action_just_pressed("jump"):
		if not player.is_on_floor() and not player_status.has_double_jump:
			return
		if player.is_on_floor():
			player_status.has_double_jump = true
			animation_service.jump()
			if player_status.is_crouching:
				_perform_jump(Application.jump_strength * 1.5)
				player_status.is_crouching = false
			else:				
				_perform_jump(Application.jump_strength)
		elif player_status.has_double_jump == true:
			player_status.has_double_jump = false
			animation_service.jump()
			_perform_jump(Application.jump_strength / 2)


func _handle_jump_landing():
	if player.get_slide_collision_count() > 0 and player.is_on_floor() and _is_on_action():
		player_status.is_jumping = false
		player_status.has_double_jump = false
		speed = Application.running_speed


func _handle_fall():
	var fall_speed = player.velocity.y * -1
	if fall_speed > 7:
		player_status.is_falling = true
		animation_service.perform_fall()
	else:
		player_status.is_falling = false

	if player_status.is_falling:
		last_fall_speed = clampf(fall_speed, fall_speed, Application.gravity * 10)
	elif last_fall_speed > 0:
		print("Falled from ", last_fall_speed)
		last_fall_speed = 0
		_perform_roll(true)


func _animate_character_on_move():
	var looking_direction = twist_pivot.basis

	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var angle_rad = atan2(input_vector.x, input_vector.y)

	if (
		(input_vector.x != 0 or input_vector.y != 0)
		and (not _is_on_action() or player_status.is_falling)
	):
		if player_status.lock_at:
			var movement_x = roundf(input_vector.x)
			var movement_y = roundf(input_vector.y)
			if movement_x > 0:
				if movement_y > 0:
					animation_service.walk_forward_right()
				elif movement_y < 0:
					animation_service.walk_backward_right()
				else:
					animation_service.walk_right()
			elif movement_x < 0:
				if movement_y > 0:
					animation_service.walk_forward_left()
				elif movement_y < 0:
					animation_service.walk_backward_left()
				else:
					animation_service.walk_left()
			else:
				if movement_y > 0:
					animation_service.walk_forward()
				elif movement_y < 0:
					animation_service.walk_backward()

			var direction = Utils.get_direction_to(player.position, player_status.lock_at.position)
			player_mesh.rotation = Vector3(player_mesh.rotation.x, 0, player_mesh.rotation.z)
			player_mesh.rotate_y(direction + deg_to_rad(180))
			return
		elif _is_running() and not player_status.is_falling:
			animation_service.run_forward()
		elif not player_status.is_falling:
			animation_service.walk_forward()
		player_mesh.set_basis(looking_direction)
		player_mesh.scale.x = 0.008
		player_mesh.scale.y = 0.008
		player_mesh.scale.z = 0.008
		player_mesh.rotate_y(angle_rad)
	elif not _is_on_action():
		animation_service.idle()


func _change_speed(new_speed: float, over_limit := false):
	if over_limit:
		speed = new_speed
	else:
		speed = clampf(new_speed, Application.speed, Application.running_speed)


func _perform_jump(velocity: float):
	player_status.is_jumping = true
	player.velocity.y = velocity


func _is_running():
	return speed > Application.speed


func _is_on_action():
	return player_status.is_jumping or player_status.is_rolling or player_status.is_falling


func _perform_roll(fall: bool = false):
	if player.velocity.x == 0 and player.velocity.z == 0:
		return

	player_status.is_rolling = true
	_change_speed(Application.rolling_speed)
	if fall:
		animation_service.perform_fall_roll()
	else:
		animation_service.perform_roll()


func _stop_roll():
	player_status.is_rolling = false
	_change_speed(Application.speed)
