extends SpringArm3D


func _ready():
	var player: CharacterBody3D = get_owner()
	
	add_excluded_object(player.get_rid())
