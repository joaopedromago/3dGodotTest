extends Node3D


@onready var walking_enemy = $Enemies/WalkingEnemy

func _ready():
	walking_enemy.emit_signal("activate_walking_animation")
