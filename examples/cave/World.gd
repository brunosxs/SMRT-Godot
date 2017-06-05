extends Node2D



func _ready():
	Globals.set("chapter", "intro") # At the start, we set the chapter to intro, so the chars will use this chapter as a base. This will be changed depending on our answer to go or not to go adventuring.
	Globals.set("dialog", get_node("CanvasLayer/dialog")) # We put a global reference to the dialog.
	Globals.set("transition", get_node("CanvasLayer/transition")) # And a simple transition effect, used during the cutscene of the dialog "after_going_there"
	
	pass
