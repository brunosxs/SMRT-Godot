extends KinematicBody2D

export (String) var chapter = "INTRO"
export (String) var dialog = "NPC1"
export (int) var start_at = 0

export (bool) var is_player
var can_talk = true
var area
onready var SMRT = get_parent().get_node("CanvasLayer/dialog")
func _ready():
	set_fixed_process(true)
	area = get_node("Area2D")
	area.connect("body_enter", self, "contact")
	SMRT.connect("dialog_control", self, "do_things")
	area

func _fixed_process(delta):
	if is_player:
		if Input.is_action_pressed("player_right"):
			set_pos(Vector2(get_pos().x + 1, get_pos().y))
		elif Input.is_action_pressed("player_left"):
			set_pos(Vector2(get_pos().x - 1, get_pos().y))
		elif Input.is_action_pressed("player_up"):
			set_pos(Vector2(get_pos().x, get_pos().y-1))
		elif Input.is_action_pressed("player_down"):
			set_pos(Vector2(get_pos().x, get_pos().y+1))
	

func contact(body):
	print("STARTED!")
	if body extends load("res://examples/interact/character.gd"):
		if is_player and can_talk and not body.is_player: # Check if body.is_player so the dialog won't start with the char player itself.
			can_talk = false
			print("NAME OF THE BODY: ",body.get_name())
			SMRT.show_text(body.chapter, body.dialog, body.start_at)
#		 	This one is a very simple example... wait until SMRT
#			tells the dialog is over before connecting to manage the body_exit signal	
			yield(SMRT, "finished")
			area.connect("body_exit", self, "no_contact")
	
func no_contact(body):
	if body extends load("res://examples/interact/character.gd"):
		if is_player and not can_talk:
			can_talk = true
			area.disconnect("body_exit", self, "no_contact")

# The signal dialog_control sends an array that has the following info:
# answer: if a question was answered, it will give the index of the button selected, otherwise it is null
# chapter: the chapter playing
# dialog: the dialog
# last_text_index: the index of the last text
# total_text: the number of texts in a dialog	
# With this info, it is possible to have finner control and make complex
# interactions between the world and the dialog.
func do_things(info):
	print(":D")