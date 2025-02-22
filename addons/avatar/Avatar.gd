tool
extends Control

# Signals
signal finished

# Export values
export(NodePath)     var dialogue_node = NodePath("..")
export(SpriteFrames) var face_sprites   setget set_face_sprites
export(int, 0, 64)   var frame = 0      setget set_frame
export(bool)         var flip_frame = false setget set_flip
export(bool)         var stay_hidden = false # Forces visibility status

# Settings that no one should touch
const SLOT = "default"

# Instance members
var Dialogue
var sprite = Sprite.new()

########################
### Export functions ###
########################
func set_face_sprites(frames):
	face_sprites = frames
	set_frame(0)

func set_frame(idx):
	if face_sprites == null:
		return
	if 0 <= idx && idx < face_sprites.get_frame_count(SLOT):
		frame = idx
		sprite.set_texture(face_sprites.get_frame(SLOT, idx))

######################
### Core functions ###
######################
func _init(name="Avatar"):
	set_name(name)

func _enter_tree():
	# Add it to Avatar group
	if not is_in_group("Avatar"):
		add_to_group("Avatar")

	# Update Dialogue reference
	if get_node(dialogue_node).is_type("Dialogue"):
		Dialogue = get_node(dialogue_node)

	# Adding children nodes
	if not is_a_parent_of(sprite):
		add_child(sprite)

	# Setting up
	set_draw_behind_parent(true)
	set_size(Vector2(1, 1))

###############
### Methods ###
###############
# Overloading methods
func get_type():
	return "Avatar"

func is_type(type):
	return type == get_type()

# Editor methods
func is_flipped():
	return sprite.is_flipped_h()

func set_flip(value):
	flip_frame = value
	sprite.set_flip_h(value)

# Helpers for Dialogue
func has_sprite():
	return sprite.get_texture() != null

func get_center():
	return get_global_pos().x

func get_off_bounds():
	var ret = Vector2(sprite.get_texture().get_size().x, 0)
	# Drag animation from left or right depending on the situation
	if !is_flipped():
		ret.x *= -1
	return ret

# Methods from Dialogue node
func speak(begin, end=begin):
	Dialogue.speak(self, begin, end)

func display():
	Dialogue.display(self)

func dismiss():
	Dialogue.dismiss(self)

func silence():
	Dialogue.silence(self)

func set_side(right):
	var left_side  = Dialogue.CastLeft
	var right_side = Dialogue.CastRight

	# Fitting avatar in the Dialogue window
	if Dialogue.is_a_parent_of(self):
		Dialogue.remove_child(self)
	elif left_side.is_a_parent_of(self) && right:
		left_side.remove_child(self)
	elif right_side.is_a_parent_of(self) && not right:
		right_side.remove_child(self)

	if right:
		right_side.add_child(self)
	else:
		left_side.add_child(self)

	# Flipping the character's sprite by default (will always reset whenever necessary)
	set_flip(right)
