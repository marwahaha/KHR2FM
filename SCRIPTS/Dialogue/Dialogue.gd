extends Control

# Constants
const ANIM_TIME = 0.35
enum DIALOGUE_TEXT_FX { TEXT_NONE, TEXT_SCROLL }

# Export values
export(String, FILE, "tscn") var next_scene = ""
export(String, FILE, "csv") var csv_path
export(int, "Top", "Middle", "Bottom") var position = 2
export(int, "None", "Scroll") var text_effect = 1

# Signals
signal finished

# Instance members
onready var CastLeft  = get_node("CastLeft")
onready var CastRight = get_node("CastRight")
onready var CastAnim  = get_node("CastAnim")
onready var Bubble    = get_node("SkinPos/Bubble")
onready var TextNode  = Bubble.get_node("TextContainer")

# Text effect nodes
var TextEffect

# "Private" members
var index = -1
var first = 0
var last  = 0
var current_speaker = null

######################
### Core functions ###
######################
func _enter_tree():
	# Initializing Translator
	Translator.set_csv(csv_path)

	# Setting Pause screen
	KHR2.set_pause(preload("res://SCENES/Menus/CutscenePause.tscn"))

func _exit_tree():
	# De-initializing Translator
	Translator.close()

	# Setting Pause screen
	KHR2.set_pause(null)

func _ready():
	# Initializing signals
	CastAnim.connect("tween_complete", self, "_on_CastAnim_complete")
	# Initializing Text effect nodes signals
	TextNode.get_node("TextScroll").connect("cleared", self, "_next_line")

	# Setting Dialogue properties
	set_alignment(position)
	set_text_effect(text_effect)

	# Setting potential next scene to be loaded at the end of the Dialogue
	if !next_scene.empty():
		SceneLoader.queue_scene(next_scene)

func _input(event):
	# Pressed, non-repeating Input check
	if event.is_pressed() && !event.is_echo():
		if event.is_action("ui_accept"):
			confirm()

	# Pressed, repeating Input check
	elif event.is_pressed() && event.is_echo():
		if event.is_action("fast-forward"):
			confirm()

	# Touch events
	elif event.type == InputEvent.SCREEN_TOUCH:
		confirm()

#######################
### Signal routines ###
#######################
func _on_CastAnim_complete(object, key):
	if object.is_type("Avatar"):
		var avatar = object

		# If object's opacity is 0, it's been dismissed
		if key == "set_opacity" && avatar.get_opacity() == 0:
			avatar.hide()
			avatar.set_opacity(1.0)

func _next_line():
	if is_loaded(): # Fetch next line
		var lineID = current_speaker.get_name().to_upper() + "_%02d" % index
		index += 1
		write(lineID)
	else: # No more lines, silence current speaker
		silence(current_speaker)

###############
### Methods ###
###############
### Overloading methods
func get_type():
	return "Dialogue"

func is_type(type):
	return type == get_type()

# Sets Bubble alignment
func set_alignment(value):
	position = value
	get_node("SkinPos").set_alignment(value)

# Sets the text effect to apply when writing. Must be a TextNode child, properly indexed
func set_text_effect(value):
	text_effect = value
	TextEffect = TextNode.get_child(value-1) if value > 0 else null

# Tells if there are still lines on hold.
func is_loaded():
	return first <= index && index <= last

func set_box(idx):
	Bubble.set_box(idx)

# Writes text on the Dialogue box
func write(text):
	# Writing line to textbox
	TextNode.set_text(text)
	if text_effect == TEXT_NONE:
		# If Bubble is visible, hide it for the Fade effect to work
		if Bubble.is_visible():
			Bubble.hide_box()
			yield(Bubble, "hidden")
		TextNode.set_visible_characters(-1)

	# If Bubble is hidden, show it
	if Bubble.is_hidden():
		Bubble.show_box()
		yield(Bubble, "shown")

	# Applying text effect
	if text_effect != TEXT_NONE:
		TextEffect.start()

	# Enabling input detection
	if !is_processing_input():
		set_process_input(true)

# Confirmation from the part of the
func confirm():
	if text_effect == TEXT_NONE:
		call_deferred("_next_line")
	else:
		TextEffect.confirm()

# Makes a character speak.
func speak(character, begin, end=begin):
	# Check indexes
	if (end - begin) < 0 || begin < 0:
		print("Dialogue: Invalid indexes.")
		silence(character)
		return

	# Setting text iteration values
	index = begin
	first = begin
	last  = end
	current_speaker = character

	# If character's invisible, make grand appearance
	if character.has_sprite():
		if (character.is_hidden() || character.get_opacity() == 0) && !character.stay_hidden:
			display(character)
			yield(CastAnim, "tween_complete")

	# Centering hook (if necessary)
	if Bubble.get_box() != -1:
		Bubble.set_hook()
		Bubble.set_hook_pos(character.get_center())

	# Finally, get the speaker's line
	call_deferred("_next_line")

# Resets values and silences a given character, or hides the box
func silence(character=null):
	current_speaker = null

	if character == null || text_effect == TEXT_NONE:
		if Bubble.is_visible():
			Bubble.hide_box()
			yield(Bubble, "hidden")

	if character != null:
		character.call_deferred("emit_signal", "finished")

	if is_processing_input():
		# Resetting values
		set_process_input(false)
		index = -1
		TextNode.set_visible_characters(0)
		Bubble.set_hook(-1)

		emit_signal("finished")

# Displays only ONE Avatar
func display(character):
	# Setting character visibility
	character.set_opacity(0)
	character.show()

	CastAnim.interpolate_method(
		character.sprite, "set_offset",
		character.get_off_bounds(), Vector2(),
		ANIM_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	CastAnim.interpolate_method(
		character, "set_opacity",
		0.0, 1.0,
		ANIM_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN
	)

	CastAnim.start()

# Dismisses a specified Avatar, or all of them if NULL
func dismiss(character=null):
	silence(character)

	var to_dismiss = Array()
	if character != null:
		to_dismiss.push_back(character)
	else:
		to_dismiss = get_tree().get_nodes_in_group("Avatar")

	for character in to_dismiss:
		CastAnim.interpolate_method(
			character.sprite, "set_offset",
			Vector2(), character.get_off_bounds(),
			ANIM_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN
		)
		CastAnim.interpolate_method(
			character, "set_opacity",
			1.0, 0.0,
			ANIM_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN
		)

	CastAnim.start()

# Dismisses all present characters and hides everything
func close():
	if Bubble.is_visible():
		Bubble.hide_box()

	dismiss()
	yield(CastAnim, "tween_complete")

	emit_signal("finished")
