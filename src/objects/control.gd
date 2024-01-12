extends Control

@onready var fps_info := $FpsInfo
@onready var menu := $Menu

var show_fps := false
var menu_open := false


func _ready():
	_update_fps_visibility()
	_update_menu_visibility()


func _process(delta: float):
	if show_fps:
		fps_info.text = "FPS: " + str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("change_menu_mode"):
		menu_open = !menu_open
		_update_menu_visibility()


func _on_show_fps_toggled(toggled_on: bool):
	show_fps = toggled_on
	_update_fps_visibility()


func _update_fps_visibility():
	fps_info.visible = show_fps


func _update_menu_visibility():
	menu.visible = menu_open
