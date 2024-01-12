extends Node

class_name ShaderService

var player: CharacterBody3D
var player_mesh: Node3D


func _init(player_arg: CharacterBody3D, player_mesh_arg: Node3D):
	player = player_arg
	player_mesh = player_mesh_arg


func change_player_opacity(value: float):
	# TODO: change player opacity
	pass
