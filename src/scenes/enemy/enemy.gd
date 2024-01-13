extends Node3D

signal set_lock_on
signal set_lock_off

@onready var target_mesh := $TargetMesh

func _on_set_lock_on():
	target_mesh.visible = true


func _on_set_lock_off():
	target_mesh.visible = false
