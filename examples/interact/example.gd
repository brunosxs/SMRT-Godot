
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var buttons
onready var SMRT = get_node("CanvasLayer/dialog")
var bubble_pos = true
func _ready():
#	SMRT.show_text("single_text","HEYA FRIEND! THIS IS A SINGLE TEXT BOX YOU CAN CALL!")
	SMRT.connect("dialog_control", self, "do_things")
	ProjectSettings.set("money", 1000)
	connect_buttons()
	
	pass

func connect_buttons():
	buttons = get_node("VBoxContainer")
	var i = 0
	for b in buttons.get_children():
		b.connect("pressed", self, "selected_option",[i])
		i+=1

func selected_option(btn):
	get_node("VBoxContainer/Button").group.get_pressed_button()
	buttons.get_child(btn).release_focus()
	if not SMRT.on_dialog:
		if btn == 0:
			SMRT.show_text("INTRO","OLD MAN", 0)
			print("Pressed button 0")
		elif btn == 1:
			SMRT.show_text("INTRO", "Freddie",0)
			print("Pressed button 1")
		elif btn == 2:
			print("Pressed button 2")
#			Updating the global playerName	
			ProjectSettings.set("playerName", get_node("Panel/LineEdit").get_text())
#			Firing the dialog
			SMRT.show_text("INTRO", "dynamic")

func do_things(info):
	print("SMRT returned the following: ",info)
	if info.answer == 2:
		print("Dunwanna hear it...")
		SMRT.on_dialog = false