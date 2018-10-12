extends KinematicBody2D

export (String) var chapter = "INTRO"
export (String) var dialog = "NPC1"
export (int) var start_at = 0
var speed = 6
export (bool) var is_player
var can_talk = true
var area
var SMRT
func _ready():
	area = get_node("InteractiveArea")
	area.connect("body_entered", self, "contact")

func _physics_process(delta):
	if is_player:
		if Input.is_action_pressed("ui_right"):
			position.x +=speed
		if Input.is_action_pressed("ui_left"):
			position.x -=speed
		if Input.is_action_pressed("ui_up"):
			position.y -=speed
		if Input.is_action_pressed("ui_down"):
			position.y +=speed
	

func contact(body):
	if not SMRT:
		SMRT = get_parent().get_parent().SMRT
	if body is get_script():
		if is_player and can_talk and not body.is_player: # Check if body.is_player so the dialog won't start with the char player itself.
			can_talk = false
			print("NAME OF THE BODY: ",body.get_name())
			SMRT.show_text(ProjectSettings.get_setting("chapter"), body.dialog, body.start_at)
#		 	This one is a very simple example... wait until SMRT
#			tells the dialog is over before connecting to manage the body_exit signal	
			yield(SMRT, "finished")
			area.connect("body_exited", self, "no_contact")
	
func no_contact(body):
	if body is get_script():
		if is_player and not can_talk:
			can_talk = true
			area.disconnect("body_exited", self, "no_contact")

# The signal dialog_control sends an array that has the following info:
# answer: if a question was answered, it will give the index of the button selected, otherwise it is null
# chapter: the chapter playing
# dialog: the dialog
# last_text_index: the index of the last text
# total_text: the number of texts in a dialog	
# With this info, it is possible to have finner control and make complex
# interactions between the world and the dialog.
func do_things(info):
	pass
	