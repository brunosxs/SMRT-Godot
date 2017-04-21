tool

extends Control

# WORKAROUND (06/08/2016)
# As Godot's plugin system doesn't allow us to create or instance scenes with child nodes as
# custom types, this script does the dirty job for us...



var dialog = preload("res://addons/SMRT/dialog.tscn") #reference to the dialog scene

func _ready():
	var n = dialog.instance(true) #instance a new scene
	get_parent().add_child(n) #add the scene to out parent, remember we are a recently created Control
	if (get_parent().get_owner()):
		n.set_owner(get_parent().get_owner())
	else:
		n.set_owner(get_parent())
	call_deferred("queue_free")


