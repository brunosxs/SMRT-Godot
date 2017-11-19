
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
onready var buttons = get_node("VButtonArray")
onready var SMRT = get_node("CanvasLayer/dialog")
var bubble_pos = true
func _ready():
#	SMRT.show_text("single_text","HEYA FRIEND! THIS IS A SINGLE TEXT BOX YOU CAN CALL!")
	buttons.connect("button_selected", self, "selected_option")
	SMRT.connect("dialog_control", self, "do_things")
	Globals.set("money", 1000)
	
	pass
	
func selected_option(btn):
	buttons.release_focus()
	if not SMRT.on_dialog:
		if btn == 0:
			SMRT.show_text("INTRO","OLD MAN", 0)
		elif btn == 1:
			SMRT.show_text("INTRO", "Freddie",0)
		elif btn == 2:
#			Updating the global playerName	
			Globals.set("playerName", get_node("Panel/LineEdit").get_text())
#			Firing the dialog
			SMRT.show_text("INTRO", "dynamic")

func do_things(info):
	print("SMRT returned the following: ",info)
	if info.answer == 2:
		print("Dunwanna hear it...")
		SMRT.on_dialog = false