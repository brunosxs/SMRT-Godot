extends Node2D



func _ready():
	Globals.set("chapter", "INTRO")
	Globals.set("dialog", get_node("CanvasLayer/dialog"))
	pass
