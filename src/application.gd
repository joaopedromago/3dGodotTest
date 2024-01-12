extends Node

var mouse_sensitivity := 0.001
var joystick_camera_sensitivity := 5

var min_camera_angle_x = -90
var max_camera_angle_x = 60

var speed = 500
var jump_strength = 7

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
