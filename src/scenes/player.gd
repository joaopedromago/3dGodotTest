extends CharacterBody3D


var twist_input := 0.0
var pitch_input := 0.0

var is_jumping = false
var has_double_jump = false

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var body_mesh := $BodyMesh


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	_handle_camera_input(delta)
	_change_character_direction(delta)
	_perform_jump()
	_perform_character_movement(delta)
	_update_camera_movement()
	move_and_slide()


func _physics_process(delta: float):
	velocity.y += (Application.gravity * -1) * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_handle_mouse_motion_input(event)


func _handle_mouse_motion_input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		twist_input = -event.relative.x * Application.mouse_sensitivity
		pitch_input = -event.relative.y * Application.mouse_sensitivity
		
func _handle_camera_input(delta: float) -> void:
	var input_vector = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if input_vector.x != 0 or input_vector.y != 0:
		twist_input = -input_vector.x * Application.joystick_camera_sensitivity * delta
		pitch_input = -input_vector.y * Application.joystick_camera_sensitivity * delta


func _perform_jump():
	if Input.is_action_just_pressed("jump"):
		if not is_on_floor() and not has_double_jump:
			return
		if is_on_floor():
			is_jumping = true
			has_double_jump = true
		elif has_double_jump == true:
			has_double_jump = false
		velocity.y = Application.jump_strength


func _perform_character_movement(delta: float):
	var variations = Application.speed * delta
	
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back") * variations
	
	velocity = twist_pivot.global_transform.basis * Vector3(input_vector[0], velocity.y, input_vector[1])
	

func _change_character_direction(delta: float):
	var looking_direction = twist_pivot.basis
	
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	var angle_rad = atan2(input_vector.x * -1, input_vector.y * -1)
	
	if(input_vector.x != 0 or input_vector.y != 0):
		body_mesh.set_basis(looking_direction)
		body_mesh.rotate_y(angle_rad)
		

func _update_camera_movement():
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(Application.min_camera_angle_x), deg_to_rad(Application.max_camera_angle_x))

	var current_x_angle = rad_to_deg(pitch_pivot.rotation.x)
	
	if current_x_angle > Application.max_camera_angle_x - 10:
		_change_mesh_opacity(0.15)
	else:
		_change_mesh_opacity(1.0)
	
	twist_input = 0.0
	pitch_input = 0.0

func _change_mesh_opacity(value: float):
	var material: ShaderMaterial = body_mesh.get_mesh().get_material()
	
	# TODO: fix no shadow problem
	material.set_shader_parameter("transparency", value)
