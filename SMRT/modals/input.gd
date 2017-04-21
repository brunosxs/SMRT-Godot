tool
extends WindowDialog

var input
var label
var control_buttons
var messages

func _ready():
	add_user_signal("text")
	input = get_node("VBoxContainer/LineEdit")
	label = get_node("VBoxContainer/Label")
	control_buttons = get_node("VBoxContainer/HButtonArray")
	input.connect("text_entered",self,"enter_pressed")
	control_buttons.connect("button_selected", self, "btn_pressed")
	messages = get_node("VBoxContainer/Label 2")
	input.connect("text_changed",self,"check_regex")
	popup_centered(get_size())
	
	pass

func enter_pressed(text):
	prepare_and_send(input.get_text())


func check_regex(text):
	var regex = RegEx.new()
	regex.compile("\\s")
#	if regex.find(text) >= 0:
#		
#		messages.set_text("White spaces are not allowed")
#	else:
#		messages.set_text("")

func btn_pressed(btn_index):
	if btn_index == 0:
		prepare_and_send(input.get_text())
		hide()
		queue_free()



func prepare_and_send(text):
	text = str(input.get_text())
	if text != "" and text != null:
		emit_signal("text", text)
		hide()

	else:
		return "cancel_error"
	queue_free()