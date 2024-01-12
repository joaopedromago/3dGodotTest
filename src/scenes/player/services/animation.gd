extends Node

class_name AnimationService

var player_animation: AnimationPlayer


func _init(player_animation_arg: AnimationPlayer):
	player_animation = player_animation_arg


func idle():
	player_animation.play("idle")


func perform_dodge():
	player_animation.play("roll")


func run_forward():
	player_animation.play("run_forward")


func walk_forward():
	player_animation.play("walk_forward")


func jump():
	player_animation.play("jump_up")

func perform_roll():
	player_animation.play("roll")

func perform_fall():
	player_animation.play("fall_down")
	
func is_on_animation() -> bool:
	return player_animation.is_playing()