extends Node

class_name PhysicsService

var player: CharacterBody3D


func _init(player_arg: CharacterBody3D):
	player = player_arg


func process(delta: float):
	_handle_gravity(delta)


func _handle_gravity(delta: float):
	player.velocity.y += (Application.gravity * -1) * delta
