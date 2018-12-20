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

# init script that sets everything up
# Nothing (that I think) worth mentioning here
tool
extends EditorPlugin

var show_editor_btn
var editor_tscn = preload("res://addons/SMRT/editor.tscn")
var editor_btn
var editor
var selection

func _init():
	editor_btn = ToolButton.new()

func _ready():
	editor_btn.set_button_icon(preload("icon.png"))
	editor_btn.set_text("SMRT-Editor")
	editor_btn.connect("pressed",self,"_open_editor")
	editor_btn.visible = true

func _enter_tree():
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU,editor_btn)
	add_custom_type("SMRT-Dialog","Control",preload("res://addons/SMRT/instance_dialog.gd"),preload("icon.png"))

func _exit_tree():
# TODO:
# As the release of this plugin, there is no oposite function 
# to "add_control_to_container" so for now it is not possible to remove a control from a container,
# only the custom type
	editor_btn.queue_free()
	remove_custom_type("SMRT-Dialog")
	

func _open_editor():
	if (editor == null):
		editor = editor_tscn.instance()
		add_child(editor)
	editor.popup_centered()
	print("OPENING EDITOR!")
	print("===============")


func _selection_changed():
	for select in selection.get_selected_nodes():
		if select is preload("res://addons/SMRT/dialog.gd"):
			editor_btn.visible = true
			return
	editor_btn.visible = false
