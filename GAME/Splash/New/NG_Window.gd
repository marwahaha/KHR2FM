extends Panel

# Signals
signal finished

# Button index
enum { OPTION_DIFFICULTY_NORMAL, OPTION_DIFFICULTY_CRITICAL }

onready var anims   = get_node("Anims")
onready var Options = get_node("Window/Options")

######################
### Core functions ###
######################
func _ready():
	# Connecting main options
	for i in range(0, Options.get_child_count()):
		var button = Options.get_child(i)
		button.connect("pressed", self, "_pressed_new", [i])

	connect("draw", self, "_show_up")

#######################
### Signal routines ###
#######################
func _show_up():
	# Making sure the first Option is selected
	Options.get_child(0).grab_focus()

	set_process_input(true)

func _pressed_new(button_idx):
	# Set up a new game with the given difficulty
	var difficulties = [ "Normal", "Critical" ]
	SaveManager.new_game(difficulties[button_idx])

	if button_idx == OPTION_DIFFICULTY_CRITICAL:
		pass # TODO: ask for EXP_Zero

	# Issue a new game
	emit_signal("finished")
