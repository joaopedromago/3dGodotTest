extends Node

class_name AnimationService

var player_animation: AnimationPlayer
var player_status: Dictionary

func _init(player_animation_arg: AnimationPlayer, player_status_arg: Dictionary):
	player_animation = player_animation_arg
	player_status = player_status_arg


func idle():
	if player_status.is_crouching:
		player_animation.play("crouch_idle")
	else:
		player_animation.play("idle")


func perform_dodge():
	player_animation.play("roll")


func run_forward():
	if player_status.is_crouching:
		player_animation.play("crouch_forward")
	else:
		player_animation.play("run_forward")


func walk_forward():
	if player_status.is_crouching:
		player_animation.play("crouch_forward")
	else:
		player_animation.play("walk_forward")
	
	
func walk_forward_right():
	if player_status.is_crouching:
		player_animation.play("crouch_forward_right")
	else:
		player_animation.play("walk_forward_right")
	
	
func walk_forward_left():
	if player_status.is_crouching:
		player_animation.play("crouch_forward_left")
	else:
		player_animation.play("walk_forward_left")


func walk_backward():
	if player_status.is_crouching:
		player_animation.play("crouch_backward")
	else:
		player_animation.play("walk_backward")
	
	
func walk_backward_right():
	if player_status.is_crouching:
		player_animation.play("crouch_backward_right")
	else:
		player_animation.play("walk_back_right")
	
	
func walk_backward_left():
	if player_status.is_crouching:
		player_animation.play("crouch_backward_left")
	else:
		player_animation.play("walk_back_left")

func walk_right():
	if player_status.is_crouching:
		player_animation.play("crouch_right")
	else:
		player_animation.play("walk_right")
	
	
func walk_left():
	if player_status.is_crouching:
		player_animation.play("crouch_left")
	else:
		player_animation.play("walk_left")

func jump():
	player_animation.play("jump_up")

func perform_roll():
	player_animation.play("roll")

func perform_fall():
	player_animation.play("fall_down")
	
func is_on_animation() -> bool:
	return player_animation.is_playing()
