extends Node

# Instance members
onready var Message = get_node("Message")
onready var Killer = get_node("Killer")

# Tooltip arrays
var background_tooltips = [
	"Loads in the background, then erases it (shows nothing)",
	"Loads in the background, then shows it on top of the current scene",
	"Loads in the background, then switches to it",
	"Loads 2 scenes in the background, then switches to the first"
]
var foreground_tooltips = [
	"Loads in the foreground.",
]

var path = "DebugRoom/DialogueTest.tscn"

######################
### Core functions ###
######################
func _ready():
	# Setting Timer for background killing
	Killer.connect("timeout", self, "_kill_background")

	# Setting buttons
	var Background = get_node("Background")
	var Foreground = get_node("Foreground")

	Background.connect("button_selected", self, "_on_background_press")
	Foreground.connect("button_selected", self, "_on_foreground_press")

	# Setting buttons & tooltips (I prefer doing this by code)
	for i in range(background_tooltips.size()):
		Background.add_button(String(i), background_tooltips[i])
	for i in range(foreground_tooltips.size()):
		Foreground.add_button(String(i), foreground_tooltips[i])

func _on_background_press(button_idx):
	var method = "background" + String(button_idx)
	Message.set_text("Testing " + method + "…")
	call(method)
	Message.set_text("Success on " + method)

	# Preparing timer
	Killer.start()

func _on_foreground_press(button_idx):
	var method = "foreground" + String(button_idx)
	Message.set_text("Testing " + method + "…")
	call(method)
	Message.set_text("Success on " + method)

func _kill_background():
	Message.set_text("Killed background loading.")
	SceneLoader.erase_scene(path)

######################
### Test functions ###
######################
# Background tests
func background0():
	SceneLoader.load_scene(path, true)
	SceneLoader.erase_scene(path)

func background1():
	SceneLoader.load_scene(path, true)
	SceneLoader.show_scene(path)

func background2():
	SceneLoader.load_scene(path, true)
	SceneLoader.show_scene(path, true)

func background3():
	SceneLoader.load_scene("DebugRoom/DialogueTest.tscn", true)
	SceneLoader.load_scene("STORY/Intro/Battle_Yuugure.tscn", true)
	SceneLoader.show_scene("DebugRoom/DialogueTest.tscn", true)

# Foreground tests
func foreground0():
	SceneLoader.load_scene("STORY/Intro/Battle_Yuugure.tscn", false)
