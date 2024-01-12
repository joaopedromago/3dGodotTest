extends Control

@onready var fps_info := $AppInfo/FpsInfo

func _process(delta):
	fps_info.text = "FPS: " + str(Engine.get_frames_per_second())
