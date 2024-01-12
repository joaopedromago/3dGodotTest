extends CharacterBody3D

var CameraService = preload("res://src/scenes/player/services/camera.gd")
var MovementService = preload("res://src/scenes/player/services/movement.gd")
var PhysicsService = preload("res://src/scenes/player/services/physics.gd")
var ShaderService = preload("res://src/scenes/player/services/shader.gd")
var UserInputService = preload("res://src/scenes/player/services/userInput.gd")
var AnimationService = preload("res://src/scenes/player/services/animation.gd")

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var player_mesh := $Mesh

var camera_service: CameraService
var movement_service: MovementService
var physics_service: PhysicsService
var shader_service: ShaderService
var user_input_service: UserInputService
var animation_service: AnimationService


func _ready():
	# TODO: set signals for change animation
	animation_service = AnimationService.new(player_mesh.get_node("AnimationPlayer"))
	shader_service = ShaderService.new(self, player_mesh)
	camera_service = CameraService.new(self, twist_pivot, pitch_pivot, player_mesh, shader_service)
	movement_service = MovementService.new(self, twist_pivot, pitch_pivot, player_mesh, animation_service)
	physics_service = PhysicsService.new(self)
	user_input_service = UserInputService.new()

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float):
	user_input_service.process()
	camera_service.process(delta)
	movement_service.process(delta)
	move_and_slide()


func _physics_process(delta: float):
	physics_service.process(delta)


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		camera_service.handle_mouse_motion_input(event)
