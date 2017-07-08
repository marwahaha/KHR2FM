extends YSort

export(String) var world_name = ""
export(String) var location = ""

func _enter_tree():
	KHR2.set_pause(preload("res://SCENES/Pause/SimplePause.tscn"))

func _exit_tree():
	KHR2.set_pause(null)

func _ready():
	Globals.set("World", world_name)
	Globals.set("Location", location)
