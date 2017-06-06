extends KinematicBody2D


var direction = Vector2(0,0)
export var dialog_name = "FRIEND_TALK"
export var start_at_message = 0
var can_interact = true

func _ready():
	get_node("interactive_area").connect("body_enter",self, "on_body_enter")
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
			smrt.disconnect("dialog_control",self,"on_dialog")
			Globals.get("player").set_fixed_process(true) # And finally, re-enable the player
			

func on_dialog(info):
#	info is a dictionary that sends the following:
#	answer: if a question was answered, it will give the index of the button selected, otherwise it is null
#	chapter: the chapter currently active
#	dialog: the dialog currently active
#	last_text_index: the index of the last text that was displayed
#	total_text: the number of texts in the currently active dialog
	
	var smrt = Globals.get("dialog") # Let's grab the dialog system into a 4 letter var
	
	# Check for an answer:
	if info.chapter == "intro": # it is good practice to also check what chapter and...
		if info.dialog == "friend_talk": # the dialog we're in
			if info.answer == 0: # There is only one question on this dialog, we check if the player answered "Of course, I am fearless!"
				smrt.stop() # We kindly ask SMRT to stop
				yield(get_tree(),"idle_frame") # and wait one frame for it to patch things up and quit nicelly
				smrt.show_text("intro","friend_talk_positive") # to finally follow it with a new dialog
				if test_move(Vector2(128,0)): # We will make the npc go out of the path
					move(Vector2(-128,0))
				else:
					move(Vector2(128,0))
				print("changed dialog name from ", get_name())
				dialog_name = "friend_talk_positive" # We also change the dialog the npc will talk from now on so when the player interact with it from now on, it will show a new answer.
		elif info.dialog == "great_adventure":
			var transition = Globals.get("transition") # Grab the transition node
			if info.last_text_index == 0: # When the first text finishes
				transition.play("fade") # we play a fade-to-black animation
			elif info.last_text_index == info.total_text: # when the last dialog has finished
				transition.play_backwards("fade")  # we play the same animation, backwards
				Globals.set("chapter","after_going_there") # change the chapter
				yield(transition,"finished") # wait for the transition to end
				
				