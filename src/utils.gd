extends Node

func get_direction_to(position_from: Vector3, position_to: Vector3):
	return (position_to - position_from).y
