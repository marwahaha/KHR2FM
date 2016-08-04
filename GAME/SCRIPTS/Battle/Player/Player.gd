extends "res://GAME/SCRIPTS/Battle/Battler.gd"

# Export values
export(int, 1, 20) var player_speed = 5

# Global variables
#var ComboTimer

######################
### Core functions ###
######################
func _ready():
	#ComboTimer = get_node("ComboTimer")

	# Adding "Guard"
	Actions.guard = Battle_Action.new("Guard", "cancel")
	Actions.guard.set_event("pressed", true)
	Actions.guard.set_event("echo", false)

	# Adding "Attack"
	Actions.attack = Battle_Action.new("Attack", "enter", 3)
	Actions.attack.set_timer(get_node("ComboTimer"))
	Actions.attack.set_event("pressed", true)
	Actions.attack.set_event("echo", false)

	for act in Actions:
		# Connecting Actions' signals
		Data.anims.connect("finished", Actions[act], "_end_action")
		var action_name = act.capitalize()
		Actions[act].connect("combo", self, "action_play")
		Actions[act].connect("finished", self, "play_idle")

	# Player gains control
	set_process_input(true)

func _input(event):
	# Handling Actions
	if !Status.lock:
		for act in Actions:
			if Actions[act].check_event(event):
				action_lock()
				Actions[act].take_event(event)
				return

		# Simple Input check
		var left  = Input.is_action_pressed("ui_left")
		var right = Input.is_action_pressed("ui_right")

		# déterminer la priorité de direction
		if left && right:
			left  = is_facing("left")
			right = !left

		# Indiquer la direction finale
		if left || right:
			if left:    face("left")
			elif right: face("right")
			Motion = player_speed
		else:
			Motion = 0
			play_anim("Still")
	else:
		Motion = 0
