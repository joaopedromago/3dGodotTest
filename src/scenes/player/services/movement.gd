extends Node

class_name MovementService

var player: CharacterBody3D
var twist_pivot: Node3D
var pitch_pivot: Node3D
var player_mesh: Node3D
var has_double_jump := false
var is_running := false
var speed: float

func _init(
	player_arg: CharacterBody3D,
	twist_pivot_arg: Node3D,
	pitch_pivot_arg: Node3D,
	player_mesh_arg: Node3D
):
	player = player_arg
	twist_pivot = twist_pivot_arg
	pitch_pivot = pitch_pivot_arg
	player_mesh = player_mesh_arg
	
	speed = Application.speed


func process(delta: float):
	_check_character_speed()
	_perform_character_movement(delta)
	_change_character_direction(delta)
	_perform_jump()
	
	
# TODO: add climb feature
# TODO: add crouch feature with R analog click
# TODO: jumping while crouch is higher than jumping while standing

func _check_character_speed():
	if Input.is_action_just_pressed("run_dodge") and !is_running:
		is_running = true
		speed = speed * 1.5
	if Input.is_action_just_released("run_dodge"):
		is_running = false
		speed = Application.speed
	if Input.is_action_just_pressed("run_dodge"):
		print("rolling")
		# TODO: validar rolamento

func _perform_character_movement(delta: float):
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

	if input_vector.x != 0 or input_vector.y != 0:
		if is_running:
			player_mesh.get_node("AnimationPlayer").play("run_forward")			
		else:
			player_mesh.get_node("AnimationPlayer").play("walk_forward")			
		player_mesh.set_basis(looking_direction)
		player_mesh.rotate_y(angle_rad)
	else:
		player_mesh.get_node("AnimationPlayer").play("idle")

func _perform_jump():
	if Input.is_action_just_pressed("jump"):
		if not player.is_on_floor() and not has_double_jump:
			return
		if player.is_on_floor():
			has_double_jump = true
			player.velocity.y = Application.jump_strength
		elif has_double_jump == true:
			has_double_jump = false
			player.velocity.y = Application.jump_strength / 2
