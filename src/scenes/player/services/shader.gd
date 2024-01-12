extends Node

class_name ShaderService

var player: CharacterBody3D
var body_mesh: MeshInstance3D


func _init(player_arg: CharacterBody3D, body_mesh_arg: MeshInstance3D):
	player = player_arg
	body_mesh = body_mesh_arg


func change_mesh_opacity(value: float):
	var material: ShaderMaterial = body_mesh.get_mesh().get_material()

	# TODO: fix no shadow problem
	material.set_shader_parameter("transparency", value)
