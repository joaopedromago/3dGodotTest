extends Node

class_name ProjectService

func change_v_sync_value(value: String):
	ProjectSettings.set_setting("display/window/vsync/vsync_mode", value)
	ProjectSettings.save()
