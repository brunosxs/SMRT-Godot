extends KinematicBody2D


var walk_speed = 500
var direction = Vector2(0,0)
export var dialog_name = "FRIEND_TALK"
export var start_at_message = 0
var can_interact = true

func _ready():
	get_node("interactible_area").connect("body_enter",self, "on_body_enter")
	pass


func on_body_enter(body):
	if body == Globals.get("player"): # Check if the character that entered is the player
		if dialog_name != null or dialog_name != "" and can_interact: # check if the npc has something to say and we can interact with
			can_interact = false # make the npc non-interactive during the talk
			# using some variables to shorten the burden of writing
			var smrt = Globals.get("dialog")
			var chapter = Globals.get("chapter")
			Globals.get("player").set_fixed_process(false) # We disable the player while the dialog happen
			smrt.show_text(chapter, dialog_name, start_at_message) # Start the dialog
			# we can connect to the signal 'dialog_control' and do different things based on the current state of the dialog
			if not smrt.is_connected("dialog_control",self,"on_dialog"):
				smrt.connect("dialog_control",self,"on_dialog")
			
			yield(smrt,"finished") # wait for smrt to emit the finished signal so we can continue
			can_interact = true # re-enable the npc interactiveness
			Globals.get("player").set_fixed_process(true) # And finally, re-enable the player
			

func on_dialog(info):
#	info is a dictionary that sends the following info:
#	answer: if a question was answered, it will give the index of the button selected, otherwise it is null
#	chapter: the chapter currently active
#	dialog: the dialog currently active
#	last_text_index: the index of the last text
#	total_text: the number of texts in the currently active dialog
	
	var smrt = Globals.get("dialog") # Let's grab the dialog system into a 4 letter var
	# Check for an answer:
	if info.chapter == "INTRO": # it is good practice to also check what chapter and...
		if info.dialog == "FRIEND_TALK": # the dialog we're in
			if info.answer == 0: # There is only one question on this dialog, we check if the player answered "Of course, I am fearless!"
				smrt.stop() # We kindly ask SMRT to stop
				yield(get_tree(),"idle_frame") # and wait one frame for it to patch things up and quit nicelly
				smrt.show_text("INTRO","FRIEND_TALK_POSITIVE") # to finally follow it with a new dialog
				dialog_name = "FRIEND_TALK_POSITIVE" # We also change the dialog the npc will talk from now on so when the player interact with it from now on, it will show a new answer.