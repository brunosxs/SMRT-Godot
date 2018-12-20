#------------------------------------------------------------------------------
# Copyright 2016 brunosxs
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of 
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to 
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ------------------------------------------------------------------------------

tool
extends WindowDialog

var input
var label
var control_buttons
var messages

func _ready():
	add_user_signal("text")
	input = get_node("PanelContainer/VBoxContainer/LineEdit")
	label = get_node("PanelContainer/VBoxContainer/Label")
	control_buttons = get_node("PanelContainer/VBoxContainer/Button")
	input.connect("text_entered",self,"enter_pressed")
	control_buttons.connect("pressed", self, "btn_pressed")
	messages = get_node("PanelContainer/VBoxContainer/Label2")
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

func btn_pressed():
	prepare_and_send(input.get_text())
	hide()
	queue_free()

func set_text(text):
	input.text = text

func prepare_and_send(text):
	text = str(input.get_text())
	if text != "" and text != null:
		emit_signal("text", text)
		hide()

	else:
		return "cancel_error"
	queue_free()