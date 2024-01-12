extends Node

var mouse_sensitivity := 0.001
var joystick_camera_sensitivity := 5

var min_camera_angle_x = -90
var max_camera_angle_x = 60

var speed = 200
var running_speed = 500
var rolling_speed = 1000
var jump_strength = 4

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
