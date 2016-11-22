tool
extends Control

# Export values
export(int, "Character", "Narrator") var type = 0
export(SpriteFrames) var face_sprites   setget set_face_sprites
export(int, 0, 64)   var frame = 0      setget set_frame
export(bool)         var flip_h = false setget set_flip_h

# Settings that no one should touch
const SLOT = "default"

# Instance members
onready var name = get_name()
var Avatar = Sprite.new()

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
		Avatar.set_texture(face_sprites.get_frame(SLOT, idx))

#######################
### Signal routines ###
#######################

######################
### Core functions ###
######################
func _enter_tree():
	Avatar.set_centered(false)
	add_child(Avatar)
	set_draw_behind_parent(true)
	set_size(Vector2(1, 1))

###############
### Methods ###
###############
func get_size():
	if face_sprites == null:
		return get_size()
	return Avatar.get_texture().get_size()

func get_center():
	return int(Avatar.get_texture().get_size().x) >> 1

func get_type():
	return "Character"

func is_type(istype):
	return istype == get_type()

func set_flip_h(value):
	if Avatar == null:
		return
	flip_h = value
	Avatar.set_flip_h(value)
