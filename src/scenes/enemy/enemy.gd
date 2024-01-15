extends Node3D

signal set_lock_on
signal set_lock_off
signal activate_walking_animation

var is_walking := false
var time := 1.0

@onready var target_mesh := $TargetMesh

func _physics_process(delta):
	if is_walking: 
		if time < 0:
			time -= 1
		else:
			time += 1
		var walking_tiles = time * delta / 10
		
		if position.x > 10:
			time = -1
		elif position.x < -11: 
			time = 1
		position.x += walking_tiles
	else:
		time = 0

func _on_set_lock_on():
	target_mesh.visible = true


func _on_set_lock_off():
	target_mesh.visible = false


func _on_activate_walking_animation():
	is_walking = true
