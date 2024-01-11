extends RigidBody3D

const speed = 2400
const jump_strength = 24

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	_perform_jump()
	_perform_character_movement(delta)
	_update_camera_movement()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_handle_mouse_motion_input(event)

func _handle_mouse_motion_input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		twist_input = - event.relative.x * mouse_sensitivity
		pitch_input = - event.relative.y * mouse_sensitivity

func _perform_jump():
	if Input.is_action_just_pressed("jump"):
		pass
		# TODO: perform jump
		#var velocity = Vector3.ZERO
		#velocity.y = jump_strength
		#move_and_slide(velocity, Vector3.UP)
	
func _perform_character_movement(delta: float):
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	apply_central_force(twist_pivot.basis * input * speed * delta)
	
func _update_camera_movement():
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-45), deg_to_rad(45))
	
	twist_input = 0.0
	pitch_input = 0.0
