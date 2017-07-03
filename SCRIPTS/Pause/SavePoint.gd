extends Panel

# Constants
enum { SAVEPOINT_SAVE, SAVEPOINT_WORLD }

# Instance members
onready var Options = get_node("Options").get_children()
onready var Menu    = [
	get_node("SaveMenu"),
]

var cursor_idx = 0

######################
### Core functions ###
######################
func _ready():
	connect("draw", self, "_show")

	# Connecting main options
	for i in range(0, Options.size()):
		Options[i].connect("pressed", self, "_pressed", [i])
		if i < Menu.size(): # FIXME: temp code
			Menu[i].connect("hide", self, "_dismissed_menu")

	set_process_input(true)

func _input(event):
	# TODO: Fix when holding cancel form menu
	# and going back : it closes
	if event.is_action("ui_cancel"):
		queue_free()

func _dismissed_menu():
	for i in range(0, Options.size()):
		Options[i].set_focus_mode(FOCUS_ALL)
	Options[cursor_idx].grab_focus()
	set_process_input(true)

#######################
### Signal routines ###
#######################
func _show():
	KHR2.pause_game(true)
	Options[0].grab_focus()

func _hide():
	KHR2.pause_game(false)

func _pressed(button_idx):
	set_process_input(false)
	cursor_idx = button_idx

	if button_idx >= Menu.size():
		return # FIXME: temp code

	# General rules
	for i in range(0, Options.size()):
		Options[i].set_focus_mode(FOCUS_NONE)

	if Menu[button_idx].is_hidden():
		Menu[button_idx].anims.play("Fade In")
